# hydro_richpresence

Discord Rich Presence for FiveM. The client samples player state on a slow interval and only sends a new Discord payload when its text changes. The server pushes accurate player counts on joins, leaves, and a low-frequency fallback refresh.

## Setup

1. Create a Discord application and copy its Application ID into `Config.Discord.appId` in `config.lua`.
2. Upload image assets in the Discord application's Rich Presence Art Assets page. Set the matching asset keys in `largeAsset` and `smallAsset`.
3. Replace the example connect address and Discord invite in `Config.Discord.buttons`. Discord supports at most two buttons.
4. Add `ensure hydro_richpresence` to the server configuration.

The connect button should use `fivem://connect/host:port`. Asset keys must match the keys uploaded to the application. Presence text, server name, and intervals can be adjusted in `config.lua`.

---

### Support Discord
<a href='https://discord.gg/xjjt5PNezq'>![Discord Shield](https://discordapp.com/api/guilds/1226950530098790540/widget.png?style=banner3)</a>
