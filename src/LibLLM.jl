module LLM

include("./LibRSS.jl")

using Dates, JSON3
using .RSS

AGENT_ROOT = expanduser("~/hep-agent")
# PI_FLAGS = ""

public AGENT_ROOT, PI_FLAGS

export prepare_job, run_pi_job

function prepare_job(items, job_dir::String)
    mkpath(joinpath(job_dir, "input"))
    mkpath(joinpath(job_dir, "work"))
    mkpath(joinpath(job_dir, "output"))

    open(joinpath(job_dir, "input", "papers.json"), "w") do io
        gen_json(items, io)
    end
end

function log_pi_event!(log_io::IO, line::String, in_thinking::Ref{Bool})
    ev = try
        JSON3.read(line)
    catch
        println(log_io, "[RAW] ", line)
        flush(log_io)
        return false
    end

    etype = get(ev, :type, "")

    # Thinking & Main
    if etype == "message_update"
        sub = get(ev, :assistantMessageEvent, nothing)
        isnothing(sub) && return false
        stype = get(sub, :type, "")

        if stype == "thinking_start"
            in_thinking[] = true
            print(log_io, "\n[THINK] ")
        elseif stype == "thinking_delta"
            print(log_io, get(sub, :delta, ""))
        elseif stype == "thinking_end"
            in_thinking[] = false
            println(log_io, "\n[/THINK]")
        elseif stype == "text_delta"
            print(log_io, get(sub, :delta, ""))
        elseif stype == "text_end"
            println(log_io)
        end
        flush(log_io)

    # Tool call
    elseif etype == "tool_execution_start"
        tname = get(ev, :toolName, "unknown")
        args = get(ev, :args, "")
        println(log_io, "\n[TOOL START] $tname -> $args")
        flush(log_io)

    elseif etype == "tool_execution_end"
        tname = get(ev, :toolName, "unknown")
        is_err = get(ev, :isError, false)
        println(log_io, "[TOOL END]   $tname (error=$is_err)")
        flush(log_io)

    # Agent End
    elseif etype == "agent_end"
        println(log_io, "\n[AGENT_END] Workflow completed.")
        flush(log_io)
        return true
    end

    return false
end

function run_pi_job(job_dir::String, topic::String; timeout::Int = 3600)
    if isfile("$job_dir/output/report.pdf")
        @info "Report is done. Skip calling the agent."
        return true
    end

    prompt = """
    Execute the daily arXiv research workflow for topic '$topic' in job directory '$job_dir'.
    Follow all instructions in 'AGENTS.md', and topic specific instructions in 'topics/$(topic).md'.
    Read '$job_dir/input/papers.json', investigate the top papers, and write '$job_dir/output/report.pdf' and '$job_dir/output/status.json'.
    """

    log_path = joinpath(job_dir, "agent.log")
    cmd = Cmd(`pi --thinking max -p --no-session $prompt`, dir = AGENT_ROOT)

    open(log_path, "w") do log_io
        proc = run(pipeline(cmd; stdin = IOBuffer(""), stdout = log_io, stderr = log_io); wait = false)

        start_t = time()
        while process_running(proc)
            if time() - start_t > timeout
                kill(proc)

                @error "Pi agent timeout after $(timeout)s for $topic (see $log_path)"
                return false
            end
            sleep(2)
        end

        if proc.exitcode != 0
            @error "Pi agent exited with code $(proc.exitcode) for $topic (see $log_path)"
            return false
        end

        return true
    end
end

end