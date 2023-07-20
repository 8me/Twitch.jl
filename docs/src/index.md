<img style="height:9em;" alt="Twitch.jl" src="assets/logo.svg"/>

## Introduction

This package is aimed to provide a convenient possibility to connect to the APIs provided by the 
livestreaming plattform Twitch. 

### Chat Server Interface

Chat Server Todos:
- [x] Parse messages
- [x] Connect and read messages
- [ ] Interface for active communication, i.e. sending messages

In order to connect to the chat the `chatreceiver` is employed and run within a
`task`:

```julia

addr = "irc.chat.twitch.tv"
port = 6667
user = "justinfan8912"
oauth = "dummy"
channel = "xqc"
c = Condition()
message_queue = Channel{AbstractString}(10000)

t = @task Twitch.chatreceiver(addr, port, user, oauth, channel, c, message_queue)
schedule(t)
```

The received messages are in the current version written to the `message_queue` in raw string
format. The messages can be accessed and parsed as follows:

```julia

if isready(message_queue)
    raw = !take(message_queue)
    resp = Twitch.response(raw)
end
```

The `resp` now contains a `Twitch.Message` or `Twitch.Notice` struct. 
As the name implies `Twitch.Message` contains the information of a chat message.
If some actions, e.g. bans or time-outs, occurs, the information is stored
within a `Twitch.Notice`.

### Helix API 

Helix API Todos
- [ ] Moderation commands, e.g. ban
