import dimscord, asyncdispatch, times, options, dimscmd

let discord = newDiscordClient(readFile("token.txt"))

var cmd = discord.newHandler()

proc onReady(s: Shard, r: Ready) {.event(discord).} =
    echo "Ready as " & $r.user

proc messageCreate (s: Shard, msg: Message) {.event(discord).} =
    discard await cmd.handleMessage("et!", s, msg)

proc interactionCreate(s: Shard, i: Interaction) {.event(discord).} =
    let data = i.data.get
    if data.custom_id == "pingClickSendNew":
        var msg = "Pong! latency " & $s.latency() & "ms."
        let response = InteractionResponse(
                kind: irtChannelMessageWithSource,
                data: some InteractionApplicationCommandCallbackData(
                    content: msg
                )
            )
        await discord.api.createInteractionResponse(i.id, i.token, response)
cmd.addChat("ping") do ():
    var row = newActionRow()
    row &= newButton(
        label = "Refresh",
        idOrUrl = "pingClickSendNew",
        emoji = Emoji(name: some "🏓")
    )
    discard await discord.api.sendMessage(
        msg.channel_id,
        "Pong! latency " & $s.latency() & "ms, click the button to check again.",
        components = @[row]
    )

waitFor discord.startSession()