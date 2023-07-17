module Twitch

using Dates
using UUIDs
using Sockets
using DocStringExtensions

include("definitions.jl")
include("parser.jl")

"""
$(SIGNATURES)

Receiver for chat messages (see example)

# Arguments
- `addr::AbstractString`: Chat server address, e.g. irc.chat.twitch.tv
- `port::Integer`: Chat server port (mostly 6667)
- `user::AbstractString`: Twitch username
- `oauth::AbstractString`: Twitch oauth token, format: 'oauth:...'
- `channel::AbstractString`: Twitch channel chat which should be joined
- `c::Condition`: Condition which indicates state changes
- `queue::Channel{T}`: Queue of received messages (still raw format)
"""

function chatreceiver(  addr::AbstractString,
                        port::Integer,
                        user::AbstractString,
                        oauth::AbstractString,
                        channel::AbstractString,
                        c::Condition,
                        queue::Channel{T} ) where { T <: AbstractString }
    @info "Reading for channel $(channel) started..."
    client = connect(addr, port)
    isconnected = false
    println(client, "NICK $(user)\n")
    println(client, "PASS $(oauth)\n")
    println(client, "JOIN #$(channel)\n")
    #Request additional infos
    println(client, "CAP REQ :twitch.tv/commands twitch.tv/tags")
    try
        while isopen(client)
            resp = readline(client, keep=true)
            @debug "Raw response: $(resp)"
            if startswith(resp, "PING")
                println(client, "PONG")
                continue
            elseif contains(resp, "RECONNECT") || isempty(resp)
                break
            elseif ~isconnected && contains(resp, "366")
                @info "Task for logging $(channel) is connected."
                notify(c)
                isconnected = true
            elseif isconnected
                put!(queue, resp)
            end
        end
    catch e
        @debug "Reading for $(channel) yields a problem -> $(e)"
        notify(c)
    end
    @info "Chat reader for channel $(channel) finished."
    close(client)
end

end # module Twitch
