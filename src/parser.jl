"""
$(SIGNATURES)

Interpret return from chat server

# Arguments
- `response::AbstractString`: Raw response string

"""
function response(response::AbstractString)
    response = strip(response)
    if occursin("PRIVMSG", response)
        return message(response)
    elseif occursin("CLEAR", response)
        return action(response)
    end
    nothing
end

function _parseheader(rawheader::AbstractString)
    fields = Dict()
    for line in split(rawheader, ';')
        kvsplit = split(line, '=')
        if ~isempty(kvsplit[2])
            fields[kvsplit[1]] = kvsplit[2]
        end
    end
    Set(keys(fields)), fields
end

"""
$(SIGNATURES)

Interpret message string

# Arguments
- `msg::AbstractString`: Raw message string

"""
function message(msg::AbstractString)
    regex = r"(.*?) :(.*?)!(.*?)@(.*?)\.tmi\.twitch.tv PRIVMSG #(.*?) \:(.*)$"
    msgparts = collect(match(regex, msg))
    k, fields = _parseheader(msgparts[1])
    messageid = UUID(fields["id"])
    if "reply-parent-msg-id" in k
        replyid = UUID(fields["reply-parent-msg-id"])
    else
        replyid = messageid
    end
    ismod = parse(Bool, fields["mod"])
    isreturning = parse(Bool, fields["returning-chatter"])
    roomid = parse(Int64, fields["room-id"])
    issubscriber = parse(Bool, fields["subscriber"])
    timestamp = unix2datetime(parse(Int64, fields["tmi-sent-ts"]) * 1e-3) #Millisecond timestamp
    isturbouser = parse(Bool, fields["turbo"])
    isvip = false
    if "vip" in k
        isvip = parse(Bool, fields["vip"][1])
    end
    userid = parse(Int64, fields["user-id"])
    nickname = msgparts[2]
    channel = msgparts[5]
    message = msgparts[6]
    Message(messageid, replyid, nickname, userid, channel, roomid, message, timestamp, ismod, issubscriber, isreturning, isturbouser, isvip)
end

"""
$(SIGNATURES)

Interpret actions string, e.g. information about timeout or ban

# Arguments
- `msg::AbstractString`: Raw message string

"""
function action(msg::AbstractString)
    
    if contains(msg, "CLEARMSG")
        action = deleted
        tmp = split(msg[2:end], " :tmi.twitch.tv CLEARMSG ")
    else
        action = ban
        tmp = split(msg[2:end], " :tmi.twitch.tv CLEARCHAT ")
    end
    k, fields = _parseheader(tmp[1])

    timestamp = unix2datetime(parse(Int64, fields["tmi-sent-ts"]) * 1e-3) #Millisecond timestamp

    messageid = UUID(0) 
    if "target-msg-id" in k && ~isempty(fields["target-msg-id"])
        messageid = UUID(fields["target-msg-id"])
    end

    duration = -1 
    if "ban-duration" in k
        duration = parse(Int64, fields["ban-duration"])
    end

    channelroomid = -1
    if "room-id" in k
        channelroomid = parse(Int64, fields["room-id"])
    end

    regex = r"#(.*?) :(.*?)$"
    a = collect(match(regex, tmp[2]))
    channelname = a[1]
    
    viewernick = ""
    if "login" in k
        viewernick = fields["login"]
    elseif ~("target-msg-id" in keys(fields))
        viewernick = strip(a[2])
    end
   
    vieweruid = -1
    if "target-user-id" in k
        vieweruid = parse(Int64, fields["target-user-id"])
    end

    if duration > 0
        action = timeout
    end

    Notice(messageid, viewernick, vieweruid, channelname, channelroomid, action, duration, timestamp)
end
