#!/usr/bin/env julia

using Twitch

function main()
    server_addr = "irc.chat.twitch.tv"
    server_port = 6667

    usernick = "justinfan1234"
    oauth = "kappa"

    c = Condition()
    message_queue = Channel{AbstractString}(10000)

    t = @task ChatCount.chatreceiver(  server_addr,
                                       server_port,
                                       usernick,
                                       oauth,
                                       c,
                                       "twitch",
                                       message_queue )
    schedule(t)

    while true

        while isready(message_queue)
            resp = take!(message_queue)
            data = response(resp)
            # ... do something
        end
        
        sleep(1)
    end

    schedule(t, InterruptExeception(), error=true)
end

main()
