# Left 4 Fun
You want to change something in the game like increasing/decreasing the number of infected or you want to be able to crawl when you are incapped?

You want to increase the melee range and actually hit someone when you swing your axe or you want to jump high with lower gravity?


### Modding system
This addon allows you to define different "variations" (mods) of the normal gameplay and switch to any of them whenever you want with a simple chat command.

It's like making your own mutations but without the need to know how to make mutations and, unlike the real mutations, it doesn't create it's own game mode, it mods the existing game modes. So you can mod the normal coop, survival, versus and the other base game modes and even the existing mutations.


All you have to do is create a text file with all the CVAR changes you want to make, then type:
```
!l4f settings mod yourmodname
```
Done. From now on, whenever you host a game, the mod will be automatically loaded.

You can switch to another mod whenever you want with the same command or you can go back to vanilla with:
```
!l4f settings mod none
```
The game CVARS you can change can be found [HERE](https://developer.valvesoftware.com/wiki/List_of_Left_4_Dead_2_console_commands_and_variables).

The addon also has its own "extra" CVARS you can add to your mod text file. These extra CVARS (you can find [HERE](https://steamcommunity.com/workshop/filedetails/discussion/1722866167/1679190184058848834/)) add new functionalities, like auto revive/respawn, buy system with money pickups, double jump, zombie drops, and lots more.

More details on how to make your L4F mods can be found [HERE](https://steamcommunity.com/workshop/filedetails/discussion/1722880882/1679190184058967857/).

You can even try the sample mods i already made. You can find them [HERE](https://steamcommunity.com/sharedfiles/filedetails/?id=1722880882).

You can play them but you can also open the addon's .VPK file with [GCFScape](https://developer.valvesoftware.com/wiki/GCFScape), see how they are made and modify them.


### Bug fixes and QoL improvements
L4F also fixes a few game bugs and adds some "Quality of Life" improvements, like:
- When you start reloading your weapon, the previous bullets aren't removed until the reload animation is finished. This means that if the reload is interrupted, you aren't left with 0 bullets in your weapon.
- You don't automatically drop your M60 when it's empty.
- Survivors who join/leave the game during the escape sequence of a campaign are no longer reported as DEAD in the credit screen.
And more.


### Admin commands
The addon comes with its own admin commands (kick, ban, spawn things, fun commands and many other commands you can find [HERE](https://steamcommunity.com/workshop/filedetails/discussion/1722866167/1679190184058888315/)).

But it's also 100% compatible with [Admin System](https://steamcommunity.com/sharedfiles/filedetails/?id=214630948).

Left 4 Fun shares the same admins file with all my other addons, so a Left 4 Fun admin is also admin on Left 4 Bots and Left 4 Grief.


## Addon settings
The list of L4F settings can be found [HERE](https://gist.github.com/smilz0/6d5a52fd472026c573398227cf448278).

You can change the settings by editing the file `ems/left4fun/cfg/host_settings.txt` or ingame with the following commands:
- Via chat: `!l4f settings [setting] [value]`
- Via console: `l4f,settings,[setting],[value]`


### Compatibility
This addon is 100% compatible with my other addons [Left 4 Bots](https://steamcommunity.com/sharedfiles/filedetails/?id=2279814689) and [Left 4 Grief](https://steamcommunity.com/sharedfiles/filedetails/?id=2250557219).

It should also be compatible with most of the addons of the workshop.


### Useful links
- [Addon Commands](https://steamcommunity.com/workshop/filedetails/discussion/1722866167/1679190184058888315/)
- [Addon Settings](https://gist.github.com/smilz0/6d5a52fd472026c573398227cf448278)
- [Visual Menu for L4F](https://steamcommunity.com/sharedfiles/filedetails/?id=1722880008)
- [L4F Sample Mods](https://steamcommunity.com/sharedfiles/filedetails/?id=1722880882)
