module RSS

using HTTP
using EzXML
using Dates
using JSON3

export fetch_rss, gen_json

"""
Fetch RSS Contents
"""
function fetch_rss(url::String)
    try
        response = HTTP.get(url)
        
        if response.status == 200
            # Parse XML data
            doc = parsexml(String(response.body))
            root_node = root(doc)
            
            # Get channel title
            channel_title_node = findfirst("//channel/title", root_node)
            channel_title = channel_title_node !== nothing ? nodecontent(channel_title_node) : "Unknown Channel"
            
            @info "Channel: $channel_title"
            @info "Current Time: " * Dates.format(now(), "yyyy-mm-dd HH:MM:SS")
            
            # Find all items
            items = findall("//channel/item", root_node)
            count = length(items)
            
            if count == 0
                @info "No item found."
            end
            
            items_vec = []
            for i in 1:count
                item = items[i]
                
                title_node = findfirst("./title", item)
                link_node = findfirst("./link", item)
                pubdate_node = findfirst("./pubDate", item)
                description_node = findfirst("./description", item)
                annoucetype_node = findfirst("./arxiv:announce_type", item)
                creators_node = findfirst("./dc:creator", item)
                
                
                # Extract information
                title = title_node !== nothing ? nodecontent(title_node) : missing
                link = link_node !== nothing ? nodecontent(link_node) : missing
                pubdate = pubdate_node !== nothing ? nodecontent(pubdate_node) : missing
                description = description_node !== nothing ? nodecontent(description_node) : missing
                creators = creators_node !== nothing ? nodecontent(creators_node) : missing

                a_t = annoucetype_node !== nothing ? nodecontent(annoucetype_node) : missing
                
                if a_t != "new" && a_t != "cross"
                    @info "Omitted by Announce Type" a_t
                    continue
                end
                
                push!(items_vec, (title = title, link = link, pubdate = pubdate, description = description, creators = creators))
            end

            return items_vec
        else
            @error "HTTP error" response.status
            return []
        end
    catch e
        @error e
        return []
    end
end

"""
Generate JSON from papers
"""
function gen_json(items, io)

    papers = map(items) do item
        m = match(r"(\d{4}\.\d{4,5})", item.link)
        arxiv_id = isnothing(m) ? "" : m.captures[1]
        (; arxiv_id, item.title, item.link, item.pubdate, item.creators, item.description)
    end

    JSON3.pretty(io, papers)
end

end