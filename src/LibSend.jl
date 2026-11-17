module Send

using Telegram

public TG_CLIENT

TG_TOKEN = ENV["TG_TOKEN"]
TG_CHATID = ENV["TG_CHATID"]

TG_CLIENT = TelegramClient(TG_TOKEN; chat_id = TG_CHATID, use_globally = false)

function send_to_tg(report_path::String, topic::String, report_name::String)
    open(report_path, "r") do io
        Telegram.sendDocument(TG_CLIENT; document = "$report_name.pdf" => io, caption = "Daily Digest for $topic")
    end
end

end