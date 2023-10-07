::Left4Fun.Settings <-
{
	// Level of server hints that will be sent to all the admins online
	// Possible values:
	//	0: all (all the hints will be shown)
	//	1: info (same as above)
	//	2: warning (only hints of level 'warning' and 'alert' will be shown)
	//	3: alert (only hints of level 'alert' will be shown)
	//	4: none (no hints will be shown)
	admin_hints_level = ST_NOTICE.ALL
	
	// At the end of a campaign the players of this category (excluding the players in the trolls list) will successfully escape even if they are incapacitated or dead
	// Possible values:
	//	0: all (enabled for everyone)
	//	1: users (enabled for non-admins only)
	//	2: admins (enabled for admins only)
	//	3: none (disabled)
	always_win = ST_USER.NONE

	// Friendly fire damage from survivor bots will be multiplied by this factor
	bot_friendlyfire_damagefactor = 1

	// [1: true/0: false] Enable/Disable the godmode for the incapped survivor who is being revived which means that the revive process will not be interrupted
	// by the infected hitting the downed survivor even if the reviver is a human (basically it will be like when the reviver is a bot)
	god_on_revive = 0
	
	// God mode
	// Possible values:
	//	0: all (enabled for everyone)
	//	1: users (enabled for non-admins only)
	//	2: admins (enabled for admins only)
	//	3: none (disabled)
	godmode = ST_USER.NONE
	
	// Minimum log level for the addon's log lines into the console
	// 0 = No log
	// 1 = Only [ERROR] messages are logged
	// 2 = [ERROR] and [WARNING]
	// 3 = [ERROR], [WARNING] and [INFO]
	// 4 = [ERROR], [WARNING], [INFO] and [DEBUG]
	loglevel = 3

	// [1: true/0: false] If true, it prevents the auto drop of the M60 when the ammo in the clip reaches 0
	m60_fix = 1

	// Name of the mod to load on the next chapter/map/restart
	// NOTE: Name must be the name of the mod file without the "_modename.txt" part (use none to load no mod)
	mod = "none"
	
	// [1: true/0: false] If true, it allows the survivors to pick up and carry certain props (only networked objects are affected, most props are handled client side and cannot be picked up)
	pickup_objects = 0
	
	// [1: true/0: false] Enable/Disable the CSGO style reload for the primary weapons
	// Basically, when you reload, the weapon will keep the remaining ammo in it's clip until the reload animation ends
	// This means that if you interrupt the reload (for example you switch to another weapon and then switch back), you can still fire the remaining ammo in the clip without
	// being forced to reload (just like when you reload the pistols)
	reload_fix = 0
	
	// Any incoming damage to a player who has been added to the trolls list is multiplied by this number (including the ricochet damage from the "Left 4 Grief" addon)
	troll_damagefactor = 1.5
}
