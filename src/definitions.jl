@enum MODACTION begin
    timeout = 1
    deleted = 2
    ban = 3
end

struct Message
    messageid::UUID
    replyid::UUID
    viewernick::AbstractString
    vieweruid::Int64
    channelname::AbstractString
    channelroomid::Int64
    msg::AbstractString
    timestamp::DateTime
    ismod::Bool
    issubscriber::Bool
    isreturning::Bool
    isturbouser::Bool
    isvip::Bool
end

struct Notice
    messageid::UUID
    viewernick::AbstractString
    vieweruid::Int64
    channelname::AbstractString
    channelroomid::Int64
    action::MODACTION
    timeout::Int64
    timestamp::DateTime
end
