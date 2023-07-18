using Twitch
using UUIDs
using Dates

testmsg = """@room-id=1234567;target-user-id=78910111213;tmi-sent-ts=167900689445 :tmi.twitch.tv CLEARCHAT #justinfan1 :justinfan2\r\n"""

resp = Twitch.response(testmsg)

@test resp.messageid == UUID("00000000-0000-0000-0000-000000000000")
@test resp.viewernick == "justinfan2"
@test resp.action == Twitch.ban
@test resp.timestamp == Dates.DateTime("1975-04-28T07:04:49.445")

testmsg = """@ban-duration=6005;room-id=234;target-user-id=264350303;tmi-sent-ts=1679006889001 :tmi.twitch.tv CLEARCHAT #justinfan3 :justinfan4\r\n"""

resp = Twitch.response(testmsg)

@test resp.messageid == UUID("00000000-0000-0000-0000-000000000000")
@test resp.viewernick == "justinfan4"
@test resp.timeout == 6005
@test resp.action == Twitch.timeout
@test resp.timestamp == Dates.DateTime("2023-03-16T22:48:09.001")

testmsg = """@badge-info=;badges=premium/1;color=#DAA520;display-name=jUsTiNFAn;emotes=501:112-113;first-msg=0;flags=;id=771172a8-8cbc-486a-89a1-9faf13f81a86;mod=1;returning-chatter=0;room-id=1234556;subscriber=0;tmi-sent-ts=1679267124076;turbo=0;user-id=144806774;user-type= :justinfan!justinfan@justinfan.tmi.twitch.tv PRIVMSG #justinfan5 :@justinfan6 lorem ipsum ;)"""

resp = Twitch.response(testmsg)

@test resp.messageid == UUID("771172a8-8cbc-486a-89a1-9faf13f81a86")
@test resp.viewernick == "justinfan"
@test resp.channelname == "justinfan5"
@test resp.timestamp == Dates.DateTime("2023-03-19T23:05:24.076")
@test resp.ismod
@test ~resp.isreturning
