include("./LibRSS.jl")
include("./LibLLM.jl")

using .LLM, .RSS
using Dates

const AGENT_ROOT = LLM.AGENT_ROOT

function run_daily_digest()
    today_str = Dates.format(today(), "yyyy-mm-dd")
    tasks = [
        ("bsm", "https://rss.arxiv.org/rss/hep-ph"),
        ("lat", "https://rss.arxiv.org/rss/hep-lat")
    ]

    asyncmap(tasks; ntasks = 2) do (topic, url)
        items = fetch_rss(url)
        if isempty(items)
            @info "No new items for $topic on $today_str (weekend/holiday?)."
            return
        end

        job_dir = joinpath(AGENT_ROOT, "jobs", today_str, topic)
        prepare_job(items, job_dir)

        try
            @info "Starting Pi agent for $topic ($(length(items)) raw items)..."
            run_pi_job(job_dir, topic)
            @info "Successfully run $topic digest!"
        catch e
            @error "Job failed for $topic" exception=(e, catch_backtrace())
        end
    end

end

## % Run Pi

run_daily_digest()

## % Send