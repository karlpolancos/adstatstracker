getgenv().TrackerSettings = {
  Webhook = "<webhook url>/messages/<message id>", -- change webhook url to your copied webhook url and copy the id of the message you sent on that channel (use discohook.org to send first message)
  delay = 15,
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/karlpolancos/adstatstracker/main/main.lua"))()
