//------------------------------------------------------
//     Author : smilzo
//     https://steamcommunity.com/id/smilz0
//------------------------------------------------------

Msg("Including left4fun...\n");

if (!IncludeScript("left4lib_utils"))
	error("[L4F][ERROR] Failed to include 'left4lib_utils', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");
if (!IncludeScript("left4lib_timers"))
	error("[L4F][ERROR] Failed to include 'left4lib_timers', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");
if (!IncludeScript("left4lib_concepts"))
	error("[L4F][ERROR] Failed to include 'left4lib_concepts', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");
if (!IncludeScript("left4lib_hooks"))
	error("[L4F][ERROR] Failed to include 'left4lib_hooks', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");
if (!IncludeScript("left4lib_simplehud"))
	error("[L4F][ERROR] Failed to include 'left4lib_simplehud', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");

IncludeScript("left4fun_requirements");

// User type setting
enum ST_USER {
  ALL,
  USERS,
  ADMINS,
  NONE
}

// Notice level setting
enum ST_NOTICE {
  ALL,
  INFO,
  WARNING,
  ALERT,
  NONE
}

// Supershove type cvar
enum CV_SUPERSHOVETYPE {
  PUSH,
  STAGGER
}

// hostfile "yourdifferenthostfilename.txt" (in server.cfg for dedicated servers - in autoexec.cfg for listen servers)
const BASENAME_CVAR = "hostfile"; // sv_contact [^0-9a-zA-Z]

const HINTCOLOR_WHITE = "255 255 255";
const HINTCOLOR_RED = "255 0 0";
const HINTCOLOR_GREEN = "0 255 0";
const HINTCOLOR_BLUE = "0 0 255";
const HINTCOLOR_YELLOW = "255 200 30";

const PRINTCOLOR_NORMAL = "\x01";
const PRINTCOLOR_CYAN = "\x03";
const PRINTCOLOR_ORANGE = "\x04";
const PRINTCOLOR_GREEN = "\x05";

const L4FPICKUP_GIFT_MODEL = "models/items/l4d_gift.mdl";
const L4FPICKUP_GIFT_PTYPE = "gift";
const L4FPICKUP_MONEY_MODEL = "models/props_collectables/money_wad.mdl";
const L4FPICKUP_MONEY_PTYPE = "money";

// Log levels
const LOG_LEVEL_NONE = 0; // Log always
const LOG_LEVEL_ERROR = 1;
const LOG_LEVEL_WARN = 2;
const LOG_LEVEL_INFO = 3;
const LOG_LEVEL_DEBUG = 4;

//Convars.SetValue("precache_all_survivors", "1");

//if (!("Left4Fun" in getroottable()))
//{
	::Left4Fun <-
	{
		Initialized = false
		BaseName = "l4f"
		ModeName = ""
		MapName = ""
		Admins = {}
		Bans = {}
		Settings =
		{
			mod = "none"
			godmode = ST_USER.NONE // TODO: maybe handle this with m_fFlags & ~(1 << 14)); // FL_GODMODE
			god_on_revive = 0
			troll_damagefactor = 1.5
			bot_friendlyfire_damagefactor = 1
			always_win = ST_USER.NONE
			admin_hints_level = ST_NOTICE.ALL
			admin_commands = 1
			pickup_objects = 0
			reload_fix = 0
			m60_fix = 1
			loglevel = 3
		}
		Events = {}
		SurvivorsSpawned = {}
		PlayersInStartArea = {}
		PlayersInSafeSpot = {}
		ModeStarted = false
		Trolls = {}
		VsMaxTeamSwitches = -1
		DirectorVar = null
		OnlineAdmins = []
		OnlineTrolls = []
		VoteAbortedOn = 0
		VoteKickCaster = -1
		TanksToSpawn = -1
		WitchesToSpawn = -1
		ZombieSelectionUserid = -1
		TankWasOnFire = false
		InfectedLimits = {}
		Bank = {}
		BankBackup = {}
		MoneyEarned = 0
		MoneySpent = 0
		WeaponsToConvert = {}
		WeaponsToRemove = []
		ZombiesToConvert = {}
		DefaultItems = []
		SanitizeList = []
		RemoveWeaponSpawns = false
		DirectorVarsToLoad = {}
		GunGameConfig = {}
		ZombieDropsConfig = {}
		UtilitiesFired = {}
		ClassesToReplaceWithMoney =
		{
			weapon_first_aid_kit_spawn = 800
			weapon_first_aid_kit = 800
			weapon_defibrillator_spawn = 800
			weapon_defibrillator = 800
			weapon_pain_pills_spawn = 400
			weapon_pain_pills = 400
			weapon_adrenaline_spawn = 400
			weapon_adrenaline = 400
			
			weapon_upgradepack_incendiary_spawn = 500
			weapon_upgradepack_incendiary = 500
			weapon_upgradepack_explosive_spawn = 500
			weapon_upgradepack_explosive = 500
			upgrade_laser_sight = 600
			
			upgrade_spawn = 0
			
			weapon_molotov_spawn = 0
			weapon_molotov = 0
			weapon_pipe_bomb_spawn = 0
			weapon_pipe_bomb = 0
			weapon_vomitjar_spawn = 0
			weapon_vomitjar = 0
			
			weapon_chainsaw_spawn = 0
			weapon_chainsaw = 0
			weapon_rifle_m60_spawn = 0
			weapon_rifle_m60 = 0
			weapon_grenade_launcher_spawn = 0
			weapon_grenade_launcher = 0
			
			weapon_pistol_spawn = 0
			weapon_pistol = 0
			weapon_pistol_magnum_spawn = 0
			weapon_pistol_magnum = 0
			weapon_smg_spawn = 0
			weapon_smg = 0
			weapon_smg_silenced_spawn = 0
			weapon_smg_silenced = 0
			weapon_smg_mp5_spawn = 0
			weapon_smg_mp5 = 0
			weapon_pumpshotgun_spawn = 0
			weapon_pumpshotgun = 0
			weapon_shotgun_chrome_spawn = 0
			weapon_shotgun_chrome = 0
			weapon_rifle_spawn = 0
			weapon_rifle = 0
			weapon_rifle_desert_spawn = 0
			weapon_rifle_desert = 0
			weapon_rifle_ak47_spawn = 0
			weapon_rifle_ak47 = 0
			weapon_rifle_sg552_spawn = 0
			weapon_rifle_sg552 = 0
			weapon_autoshotgun_spawn = 0
			weapon_autoshotgun = 0
			weapon_shotgun_spas_spawn = 0
			weapon_shotgun_spas = 0
			weapon_hunting_rifle_spawn = 0
			weapon_hunting_rifle = 0
			weapon_sniper_military_spawn = 0
			weapon_sniper_military = 0
			weapon_sniper_awp_spawn = 0
			weapon_sniper_awp = 0
			weapon_sniper_scout_spawn = 0
			weapon_sniper_scout = 0
			
			weapon_spawn = 0
			weapon_melee_spawn = 0
			weapon_ammo_spawn = 0
		}
		SaferoomMoney = {}
		SaferoomAmmoToRestore = null
		ForbiddenCvarsOnLoad = [ "name", "name2" "password", "rcon.*", "host.*", "motdfile", "mem.*", "servercfgfile", "sv_.*" ]
		ExceptionsOnForbiddenCvarsOnLoad = [ "sv_accelerate", "sv_airaccelerate", "sv_alltalk", "sv_fallen_survivor_health_multiplier", "sv_friction", "sv_glowenable", "sv_gravity", "sv_healing_gnome_replenish_rate", "sv_infected_.*", "sv_infinite_primary_ammo", "sv_wateraccelerate", "sv_waterfriction" ]
		MeleeWeapon = [ "fireaxe", "baseball_bat", "cricket_bat", "crowbar", "frying_pan", "golfclub", "electric_guitar", "katana", "machete", "tonfa", "hunting_knife", "riotshield", "pitchfork", "shovel" ]
		PrimaryWeaponLevel1 = [ "weapon_smg", "weapon_smg_silenced", "weapon_pumpshotgun", "weapon_shotgun_chrome", "weapon_smg_mp5" ]
		PrimaryWeaponLevel2 = [ "weapon_rifle", "weapon_rifle_desert", "weapon_rifle_ak47", "weapon_autoshotgun", "weapon_shotgun_spas", "weapon_hunting_rifle", "weapon_sniper_military", "weapon_rifle_sg552", "weapon_sniper_awp", "weapon_sniper_scout" ]
		UnavailableMelee = {}
		RescueVehicleLeaving = false
		RescuedSurvivorsFixed = false
		Locations = {
						checkpointA = null
						checkpointB = null
						finale = null
						rescueVehicle = null
					}
		SpawningExtraSurvivors = {}
		JoiningUserids = []
		ModelsToPrecache = ["models/infected/witch.mdl", "models/infected/witch_bride.mdl", L4FPICKUP_GIFT_MODEL, L4FPICKUP_MONEY_MODEL]
		SoundsToPrecache = ["UI/gift_drop.wav", "UI/littlereward.wav", "EDIT_MARK.Enable", "EDIT_MARK.Disable"]
		ReloadFixWeps = [ "weapon_smg", "weapon_smg_silenced", "weapon_smg_mp5", "weapon_rifle", "weapon_rifle_desert", "weapon_rifle_ak47", "weapon_rifle_sg552", "weapon_hunting_rifle", "weapon_sniper_military", "weapon_rifle_m60", "weapon_sniper_awp", "weapon_sniper_scout" ]
	}

	// cmd buy items
	::Left4Fun.BuyItems_Spawn <-
	{
		pile = 1200
		laser = 600
		barrel = 130
		mg1 = 2500
		mg2 = 2500
	}
	// TODO: buy props_fortifications ?

	::Left4Fun.BuyItems_Give <-
	{
		// AMMO
		ammo = { weapon = "ammo", price = 300 }
		// HEALTH
		kit = { weapon = "weapon_first_aid_kit", price = 800 }
		defib = { weapon = "weapon_defibrillator", price = 1200 }
		pills = { weapon = "weapon_pain_pills", price = 400 }
		adrenaline = { weapon = "weapon_adrenaline", price = 400 }
		// UTILITY
		molotov = { weapon = "weapon_molotov", price = 100 }
		pipe = { weapon = "weapon_pipe_bomb", price = 100 }
		bile = { weapon = "weapon_vomitjar", price = 100 }
		// TIER 2 PRIMARY
		ak = { weapon = "weapon_rifle_ak47", price = 2000 }
		m16 = { weapon = "weapon_rifle", price = 2000 }
		scar = { weapon = "weapon_rifle_desert", price = 2000 }
		spas = { weapon = "weapon_shotgun_spas", price = 2000 }
		m4 = { weapon = "weapon_autoshotgun", price = 2000 }
		hunting = { weapon = "weapon_hunting_rifle", price = 2000 }
		sniper = { weapon = "weapon_sniper_military", price = 2000 }
		sg = { weapon = "weapon_rifle_sg552", price = 2000 }
		awp = { weapon = "weapon_sniper_awp", price = 2000 }
		scout = { weapon = "weapon_sniper_scout", price = 2000 }
		// TIER 1 PRIMARY
		pump = { weapon = "weapon_pumpshotgun", price = 900 }
		chrome = { weapon = "weapon_shotgun_chrome", price = 900 }
		silenced = { weapon = "weapon_smg_silenced", price = 900 }
		smg = { weapon = "weapon_smg", price = 900 }
		mp5 = { weapon = "weapon_smg_mp5", price = 900 }
		// SPECIAL
		saw = { weapon = "weapon_chainsaw", price = 1200 }
		gl = { weapon = "weapon_grenade_launcher", price = 1500 }
		m60 = { weapon = "weapon_rifle_m60", price = 1500 }
		// PISTOL
		pistol = { weapon = "weapon_pistol", price = 300 }
		magnum = { weapon = "weapon_pistol_magnum", price = 500 }
		// MELEE
		axe = { weapon = "fireaxe", price = 400 }
		baseball = { weapon = "baseball_bat", price = 400 }
		cricket = { weapon = "cricket_bat", price = 400 }
		crowbar = { weapon = "crowbar", price = 400 }
		frying = { weapon = "frying_pan", price = 400 }
		guitar = { weapon = "electric_guitar", price = 400 }
		stick = { weapon = "tonfa", price = 400 }
		golf = { weapon = "golfclub", price = 500 }
		katana = { weapon = "katana", price = 500 }
		machete = { weapon = "machete", price = 500 }
		knife = { weapon = "hunting_knife", price = 500 }
		shield = { weapon = "riotshield", price = 500 }
		fork = { weapon = "pitchfork", price = 500 }
		shovel = { weapon = "shovel", price = 500 }
		// UPGRADE
		incendiary = { weapon = "weapon_upgradepack_incendiary", price = 500 }
		explosive = { weapon = "weapon_upgradepack_explosive", price = 500 }
		// EXTRA
		firework = { weapon = "weapon_fireworkcrate", price = 100 }
		oxygen = { weapon = "weapon_oxygentank", price = 60 }
		propane = { weapon = "weapon_propanetank", price = 60 }
		gas = { weapon = "weapon_gascan", price = 10000 }
	}

	::Left4Fun.Log <- function (level, text)
	{
		if (level > Left4Fun.Settings.loglevel)
			return;
		
		if (level == LOG_LEVEL_DEBUG)
			printl("[L4F][DEBUG] " + text);
		else if (level == LOG_LEVEL_INFO)
			printl("[L4F][INFO] " + text);
		else if (level == LOG_LEVEL_WARN)
			error("[L4F][WARNING] " + text + "\n");
		else if (level == LOG_LEVEL_ERROR)
			error("[L4F][ERROR] " + text + "\n");
		else
			error("[L4F][" + level + "] " + text + "\n");
	}

	// Left4Fun main initialization function
	::Left4Fun.Initialize <- function (modename, mapname)
	{
		if (Left4Fun.Initialized)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun already initialized");
			return;
		}
		
		Left4Fun.ModeName = modename;
		Left4Fun.MapName = mapname;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun initialization - modename: " + modename + " - mapname: " + mapname);
		
		local c = 0;
		
		Left4Fun.BaseName = Left4Utils.ExtractFileName(Convars.GetStr(BASENAME_CVAR));
		if (!Left4Fun.BaseName)
			Left4Fun.BaseName = "l4f";
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Loading settings...");
		Left4Utils.LoadSettingsFromFile("left4fun/cfg/" + Left4Fun.BaseName + "_settings.txt", "Left4Fun.Settings.", Left4Fun.Log);
		Left4Utils.SaveSettingsToFile("left4fun/cfg/" + Left4Fun.BaseName + "_settings.txt", ::Left4Fun.Settings, Left4Fun.Log);
		Left4Utils.PrintSettings(::Left4Fun.Settings, Left4Fun.Log, "[Settings] ");
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Loading admins...");
		::Left4Fun.Admins = Left4Utils.LoadAdminsFromFile("left4fun/cfg/" + Left4Fun.BaseName + "_admins.txt", Left4Fun.Log);
		Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + Left4Fun.Admins.len() + " admins");
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Loading trolls...");
		::Left4Fun.Trolls = Left4Utils.LoadAdminsFromFile("left4fun/cfg/" + Left4Fun.BaseName + "_trolls.txt", Left4Fun.Log);
		Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + Left4Fun.Trolls.len() + " trolls");
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Loading bans...");
		::Left4Fun.Bans = Left4Utils.LoadAdminsFromFile("left4fun/cfg/" + Left4Fun.BaseName + "_bans.txt", Left4Fun.Log);
		Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + Left4Fun.Bans.len() + " bans");
		
		local fileName = Left4Fun.GetModFileToLoad();
		if (fileName != null && fileName != "")
		{
			Left4Fun.Log(LOG_LEVEL_INFO, "Loading cvars from mod file: " + fileName);
			c = Left4Fun.LoadCvars(fileName);
			Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + c + " cvars");
		}
		else
			Left4Fun.Log(LOG_LEVEL_INFO, "No mod file to load");
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Loading persistent cvars...");
		c = Left4Fun.LoadCvars("left4fun/cfg/" + Left4Fun.BaseName + "_persistentcvars.txt", true);
		Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + c + " persistent cvars");
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Loading store...");
		c = Left4Fun.LoadStore();
		Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + c + " store items");
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Loading pickups to replace with money...");
		if (!Left4Fun.LoadReplaceWithMoney())
			Left4Fun.SaveReplaceWithMoney();
		
		if (Left4Fun.L4FCvars.gungame)
		{
			Left4Fun.Log(LOG_LEVEL_INFO, "Loading GunGame config...");
			c = Left4Fun.LoadGunGameConfig(mapname);
			Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + c + " GunGame configs");
		}

		if (Left4Fun.L4FCvars.zombiedrops)
		{
			Left4Fun.Log(LOG_LEVEL_INFO, "Loading ZombieDrops config...");
			c = Left4Fun.LoadZombieDropsConfig(mapname);
			Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + c + " ZombieDrops configs");
		}
		
		if (Left4Fun.L4FCvars.survivor_abilities)
		{
			Left4Fun.Log(LOG_LEVEL_INFO, "Loading SurvivorAbilities types...");
			c = SurvivorAbilities.LoadTypes();
			Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + c + " SurvivorAbilities types");
			
			Left4Fun.Log(LOG_LEVEL_INFO, "Loading SurvivorAbilities character defaults...");
			c = SurvivorAbilities.LoadCharacterDefaults();
			Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + c + " SurvivorAbilities character defaults");
		}
		
		if (Left4Fun.Settings.mod && Left4Fun.Settings.mod != "none")
		{
			fileName = "left4fun/mods/" + Left4Fun.Settings.mod;
			Left4Fun.Log(LOG_LEVEL_INFO, "Loading mod script from file: " + fileName);
			try
			{
				if (IncludeScript(fileName, g_ModeScript))
				{
					Left4Fun.Log(LOG_LEVEL_INFO, "Mod script file loaded");
					
					g_MapScript.AddDefaultsToTable("MapState", g_MapScript, "MutationState", g_ModeScript);
					::SessionState <- g_ModeScript.MutationState;

					SessionState.MapName <- mapname;
					SessionState.ModeName <- modename;

					// If not specified, start active by default
					if (!("StartActive" in SessionState))
						SessionState.StartActive <- true;

					g_MapScript.AddDefaultsToTable("MutationOptions", g_ModeScript, "DirectorOptions", g_ModeScript);
					g_MapScript.AddDefaultsToTable("MapOptions", g_MapScript, "DirectorOptions", g_ModeScript);
					::SessionOptions <- g_ModeScript.DirectorOptions;
				}
				else
					Left4Fun.Log(LOG_LEVEL_INFO, "Mod script file does not exist");
			}
			catch(exception)
			{
				Left4Fun.Log(LOG_LEVEL_ERROR, "Error loading mod script file: " + exception);
			}
		}
		else
			Left4Fun.Log(LOG_LEVEL_INFO, "No mod script file to load");
		
		foreach (model in ::Left4Fun.ModelsToPrecache)
			Left4Utils.PrecacheModel(model);
		
		foreach (sound in ::Left4Fun.SoundsToPrecache)
			Left4Utils.PrecacheSound(sound);
		
		Left4Fun.Initialized = true;
	}
//}

// Left4Fun sub scripts
IncludeScript("survivor_abilities"); // this must go before left4fun_notifications
IncludeScript("left4fun_cvars");
IncludeScript("left4fun_events");
IncludeScript("left4fun_functions");
IncludeScript("left4fun_commands");
IncludeScript("left4fun_admin");
