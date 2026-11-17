include("./LibRSS.jl")
include("./LibLLM.jl")
include("./LibSend.jl")

using .LLM, .RSS, .Send
using Dates

const AGENT_ROOT = LLM.AGENT_ROOT

tasks = [
    ("bsm", "https://rss.arxiv.org/rss/hep-ph", "Beyond Standard Model Phenomenology"),
    ("lat", "https://rss.arxiv.org/rss/hep-lat", "Lattice Field Theory")
]

today_str = Dates.format(now(UTC) - Hour(5), "yyyy-mm-dd")


function run_daily_digest()

    asyncmap(tasks; ntasks = 2) do (topic, url, _)
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

function send_all_reports()
    
    for (topic, url, description) in tasks
        report_path = joinpath(AGENT_ROOT, "jobs", today_str, topic, "output/report.pdf")
        try
        send_to_tg(report_path, description, "$(topic)_$(today_str).pdf")
        catch e
            @warn "Send report failed."
        end
    end

end

## % Run Pi

run_daily_digest()

## % Send

send_all_reports()