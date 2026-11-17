module Send

using Telegram
using ConfigEnv

export send_to_tg

dotenv()

function send_to_tg(report_path::String, topic::String, report_name::String)
    open(report_path, "r") do io
        Telegram.sendDocument(document = "$report_name" => io, caption = "Daily Digest for $topic")
    end
end

end