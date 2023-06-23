//------------------------------------------------------
//     Author : smilzo
//     https://steamcommunity.com/id/smilz0
//------------------------------------------------------

Msg("Including left4fun...\n");

if (!IncludeScript("left4lib_users"))
	error("[L4F][ERROR] Failed to include 'left4lib_users', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");
if (!IncludeScript("left4lib_timers"))
	error("[L4F][ERROR] Failed to include 'left4lib_timers', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");
if (!IncludeScript("left4lib_concepts"))
	error("[L4F][ERROR] Failed to include 'left4lib_concepts', please make sure the 'Left 4 Lib' addon is installed and enabled!\n");
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

::Left4Fun <-
{
	Initialized = false
	BaseName = "l4f"
	ModeName = ""
	MapName = ""
	Difficulty = "" // easy, normal, hard, impossible
	Bans = {}
	Settings =
	{
		// [true/false] Enable/Disable certain admin conmmands that can conflict with the same admin commands from Admin System. Disable this if you use Admin System
		admin_commands = 1
		
		// Level of server hints that will be sent to all the admins online
		// Possible values:
		//	all (all the hints will be shown)
		//	info (same as above)
		//	warning (only hints of level 'warning' and 'alert' will be shown)
		//	alert (only hints of level 'alert' will be shown)
		//	none (no hints will be shown)
		admin_hints_level = ST_NOTICE.ALL
		
		// At the end of a campaign the players of this category (excluding the players in the trolls list) will successfully escape even if they are incapacitated or dead
		// Possible values:
		//	none (disabled)
		//	admins (enabled for admins only)
		//	users (enabled for non-admins only)
		//	all (enabled for everyone)
		always_win = ST_USER.NONE

		// Friendly fire damage from survivor bots will be multiplied by this factor
		bot_friendlyfire_damagefactor = 1

		// [true/false] Enable/Disable the godmode for the incapped survivor who is being revived which means that the revive process will not be interrupted
		// by the infected hitting the downed survivor even if the reviver is a human (basically it will be like when the reviver is a bot)
		god_on_revive = 0
		
		// God mode
		// Possible values:
		//	none (disabled)
		//	admins (enabled for admins only)
		//	users (enabled for non-admins only)
		//	all (enabled for everyone)
		godmode = ST_USER.NONE // TODO: maybe handle this with m_fFlags & ~(1 << 14)); // FL_GODMODE
		
		// Minimum log level for the addon's log lines into the console
		// 0 = No log
		// 1 = Only [ERROR] messages are logged
		// 2 = [ERROR] and [WARNING]
		// 3 = [ERROR], [WARNING] and [INFO]
		// 4 = [ERROR], [WARNING], [INFO] and [DEBUG]
		loglevel = 3

		// [true/false] If true, it prevents the auto drop of the M60 when the ammo in the clip reaches 0
		m60_fix = 1

		// Name of the mod to load on the next chapter/map/restart
		// NOTE: Name must be the name of the mod file without the "_modename.txt" part (use none to load no mod)
		mod = "none"
		
		// [true/false] If true, it allows the survivors to pick up and carry certain props (only networked objects are affected, most props are handled client side and cannot be picked up)
		pickup_objects = 0
		
		// [true/false] Enable/Disable the CSGO style reload for the primary weapons
		// Basically, when you reload, the weapon will keep the remaining ammo in it's clip until the reload animation ends
		// This means that if you interrupt the reload (for example you switch to another weapon and then switch back), you can still fire the remaining ammo in the clip without
		// being forced to reload (just like when you reload the pistols)
		reload_fix = 0
		
		// Any incoming damage to a player who has been added to the trolls list is multiplied by this number (including the ricochet damage from the "Left 4 Grief" addon)
		troll_damagefactor = 1.5
	}
	Events = {}
	SurvivorsSpawned = {}
	PlayersInStartArea = {}
	PlayersInSafeSpot = {}
	ModeStarted = false
	VsMaxTeamSwitches = -1
	DirectorVar = null
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
	//JoiningUserids = []
	ModelsToPrecache = ["models/infected/witch.mdl", "models/infected/witch_bride.mdl", L4FPICKUP_GIFT_MODEL, L4FPICKUP_MONEY_MODEL]
	SoundsToPrecache = ["UI/gift_drop.wav", "UI/littlereward.wav", "EDIT_MARK.Enable", "EDIT_MARK.Disable"]
	ReloadFixWeps = [ "weapon_smg", "weapon_smg_silenced", "weapon_smg_mp5", "weapon_rifle", "weapon_rifle_desert", "weapon_rifle_ak47", "weapon_rifle_sg552", "weapon_hunting_rifle", "weapon_sniper_military", "weapon_rifle_m60", "weapon_sniper_awp", "weapon_sniper_scout" ]
	ReloadFixClips = {}
	ScriptedVocalizers = []
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
::Left4Fun.Initialize <- function ()
{
	if (Left4Fun.Initialized)
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun already initialized");
		return;
	}
	
	Left4Fun.ModeName = SessionState.ModeName;
	Left4Fun.MapName = SessionState.MapName;
	Left4Fun.Difficulty = Convars.GetStr("z_difficulty").tolower();

	Left4Fun.Log(LOG_LEVEL_DEBUG, "Initializing for game mode: " + Left4Fun.ModeName + " - map name: " + Left4Fun.MapName + " - difficulty: " + Left4Fun.Difficulty);
	
	local c = 0;
	
	Left4Fun.BaseName = Left4Utils.ExtractFileName(Convars.GetStr(BASENAME_CVAR));
	if (!Left4Fun.BaseName)
		Left4Fun.BaseName = "l4f";
	
	Left4Fun.Log(LOG_LEVEL_INFO, "Loading settings...");
	Left4Utils.LoadSettingsFromFile("left4fun/cfg/" + Left4Fun.BaseName + "_settings.txt", "Left4Fun.Settings.", Left4Fun.Log);
	Left4Utils.SaveSettingsToFile("left4fun/cfg/" + Left4Fun.BaseName + "_settings.txt", ::Left4Fun.Settings, Left4Fun.Log);
	Left4Utils.PrintSettings(::Left4Fun.Settings, Left4Fun.Log, "[Settings] ");
	
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
	c = Left4Fun.LoadReplaceWithMoney();
	Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + c + " pickups to replace with money");
	
	if (Left4Fun.L4FCvars.gungame) // TODO
	{
		Left4Fun.Log(LOG_LEVEL_INFO, "Loading GunGame config...");
		c = Left4Fun.LoadGunGameConfig(Left4Fun.MapName);
		Left4Fun.Log(LOG_LEVEL_INFO, "Loaded " + c + " GunGame configs");
	}

	if (Left4Fun.L4FCvars.zombiedrops)
	{
		Left4Fun.Log(LOG_LEVEL_INFO, "Checking ZombieDrops default file...");
		Left4Fun.CheckZombieDropsDefault();
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Loading ZombieDrops config...");
		c = Left4Fun.LoadZombieDropsConfig(Left4Fun.MapName);
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

				SessionState.MapName <- Left4Fun.MapName;
				SessionState.ModeName <- Left4Fun.ModeName;

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

class ::Left4Fun.ScriptedVocalizer
{
	constructor(scriptFileName)
	{
		_scriptFileName = scriptFileName;
		_script = [];
		
		local lines = Left4Utils.FileToStringList(_scriptFileName);
		if (lines)
		{
			foreach (line in lines)
			{
				local tmp = split(Left4Utils.StripComments(line), ",");
				if (tmp.len() == 4) // delay,actor,scene,duration
				{
					local entry = { delay = tmp[0].tofloat(), actor = tmp[1], scene = tmp[2], duration = tmp[3].tofloat() };
					//Left4Utils.PrintTable(entry);
					_script.append(entry);
				}
			}
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "new ScriptedVocalizer() - File: " + _scriptFileName + " - Lines: " + _script.len());
	}
	
	function Start()
	{
		if (_started && !_paused)
			return;
		
		Left4Timers.AddTimer(null, _script[_idx].delay, @(params) params.instance.PlayScene(), { instance = this });
		
		_started = true;
		_paused = false;
	}
	
	function Stop()
	{
		if (!_started)
			return;
		
		_started = false;
		_paused = false;
		
		_idx = 0;
	}
	
	function Pause()
	{
		if (!_started)
			return;
		
		_paused = true;
	}
	
	function PlayScene()
	{
		if (_survivor || !_started || _paused || _idx >= _script.len())
			return;
		
		local entry = _script[_idx];
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "ScriptedVocalizer.PlayScene - idx: " + _idx + " - Delay: " + entry.delay + " - Actor: " + entry.actor + " - Scene: " + entry.scene + " - Duration: " + entry.duration);
		
		_survivor = Left4Utils.GetSurvivorFromActor(entry.actor);
		if (!_survivor)
			return;
		
		Left4Utils.SpeakScene(_survivor, entry.scene, entry.actor);
		
		Left4Timers.AddTimer(null, _script[_idx].duration, @(params) params.instance.StopScene(), { instance = this });
	}
	
	function StopScene()
	{
		if (_survivor)
			DoEntFire("!self", "CancelCurrentScene", "", 0, null, _survivor);
		_survivor = null;
		
		if (!_started || _paused)
			return;
		
		if (++_idx < _script.len())
			Left4Timers.AddTimer(null, _script[_idx].delay < 0.01 ? 0.01 : _script[_idx].delay, @(params) params.instance.PlayScene(), { instance = this });
		else
			Stop();
	}
	
	_scriptFileName = null;
	_started = false;
	_paused = false;
	_script = null;
	_idx = 0;
	_survivor = null;
}

// Left4Fun sub scripts
IncludeScript("survivor_abilities"); // this must go before left4fun_notifications
IncludeScript("left4fun_cvars");
IncludeScript("left4fun_events");
IncludeScript("left4fun_functions");
IncludeScript("left4fun_commands");
IncludeScript("left4fun_admin");

Left4Fun.Initialize();
