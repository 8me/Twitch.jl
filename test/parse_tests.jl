using Twitch
using UUIDs
using Dates

testmsg = """@room-id=1234567;target-user-id=78910111213;tmi-sent-ts=167900689445 :tmi.twitch.tv CLEARCHAT #justinfan1 :justinfan2\r\n"""

resp = Twitch.response(testmsg)

@test resp.messageid == UUID("00000000-0000-0000-0000-000000000000")
@test resp.viewernick == "justinfan2"
@test resp.action == Twitch.ban
@test resp.timestamp == Dates.DateTime("1975-04-28T07:04:49.445")
