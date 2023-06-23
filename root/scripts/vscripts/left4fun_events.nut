//------------------------------------------------------
//     Author : smilzo
//     https://steamcommunity.com/id/smilz0
//------------------------------------------------------

Msg("Including left4fun_events...\n");

::Left4Fun.OnConcept <- function (concept, query)
{
	if (!Left4Fun.ModeStarted && "gamemode" in query)
	{
		Left4Fun.ModeStarted = true;
		Left4Fun.OnModeStart();
		if ("OnModeStart" in DirectorScript.GetDirectorOptions())
			DirectorScript.GetDirectorOptions().OnModeStart();
	}
	
	if (concept == "PlayerPickup")
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "PlayerPickup - who: " + query.who);
		
		local who = Left4Utils.GetSurvivorFromActor(query.who);
		if (who && who.IsValid() && ("IsSurvivor" in who) && who.IsSurvivor())
		{
			local weapon = Left4Utils.GetInventoryItemInSlot(who, INV_SLOT_PRIMARY);
			if (weapon && weapon.IsValid() && Left4Fun.ReloadFixWeps.find(weapon.GetClassname()) != null)
			{
				Left4Fun.ReloadFixClips[weapon.GetEntityIndex()] <- NetProps.GetPropInt(weapon, "m_iClip1");
				
				Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun.ReloadFixClips.len() = " + Left4Fun.ReloadFixClips.len());
			}
		}
	}
	
	// TODO: TEST
	if (concept != "SceneCancelled" && ("who" in query))
	{
		local who = Left4Utils.GetSurvivorFromActor(query.who);
		if (who && who.IsValid() && Left4Users.GetOnlineUserLevel(who.GetPlayerUserId()) < L4U_LEVEL.User)
			DoEntFire("!self", "CancelCurrentScene", "", 0.01, null, who);
	}
}

::Left4Fun.Events.OnGameEvent_server_cvar <- function (params)
{
	local cvarname = Left4Fun.GetParam("cvarname", params);
	local cvarvalue = Left4Fun.GetParam("cvarvalue", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnServerCvarChanged - cvar: " + cvarname + " - value: " + cvarvalue);
}

::Left4Fun.Events.OnGameEvent_map_transition <- function (params)
{
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnMapEnd");
	
	Left4Utils.StartDirector();
	SurvivorAbilities.CleanupAbilities();
	Left4Fun.RestoreCvars();
	
	if (Left4Fun.L4FCvars.money)
	{
		if (!Left4Fun.L4FCvars.money_reset)
			Left4Fun.SaveBank();
		
		if (Left4Fun.L4FCvars.money_replacepickups)
			Left4Fun.SaveSaferoomMoney(); // TODO: need to find a way to clean this when starting a new campaign
	}
	
	Left4Fun.CleanExtraSurvivors();	
}

::Left4Fun.Events.OnGameEvent_round_end <- function (params)
{
	local winner = Left4Fun.GetParamInt("winner", params);
	local reason = Left4Fun.GetParamInt("reason", params);
	local message = Left4Fun.GetParam("message", params);
	local time = Left4Fun.GetParamFloat("time", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnRoundEnd - winner: " + winner + " - reason: " + reason + " - message: " + message);
	
	Left4Utils.StartDirector();
	SurvivorAbilities.CleanupAbilities();
	Left4Fun.RestoreCvars();
	
	if (reason != 3 && Left4Fun.L4FCvars.money && !Left4Fun.L4FCvars.money_reset)
	{
		Left4Fun.Bank = g_ModeScript.DuplicateTable(Left4Fun.BankBackup);
		Left4Fun.SaveBank();
	}
	
	Left4Fun.CleanExtraSurvivors();
}

::Left4Fun.Events.OnGameEvent_versus_match_finished <- function (params)
{
	local winners = Left4Fun.GetParamInt("winners", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnVersusMatchFinished - winners: " + winners);
}

::Left4Fun.OnGameplayStart <- function ()
{
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun.OnGameplayStart");
}

::Left4Fun.OnActivate <- function ()
{
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun.OnActivate");
}

::Left4Fun.OnShutdown <- function ()
{
	local reason = ::SessionState.ShutdownReason;
	local nextmap = ::SessionState.NextMap;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnShutdown - reason: " + reason + " - nextmap: " + nextmap);
	
	Left4Utils.StartDirector();
	SurvivorAbilities.CleanupAbilities();
	Left4Fun.RestoreCvars();
	
	Left4Timers.RemoveTimer("SurvivorAbilitiesUpdate");
	Left4Timers.RemoveTimer("BotsBuyThink");
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Total money earned this round: " + Left4Fun.MoneyEarned + " - spent: " + Left4Fun.MoneySpent);
	
	// Change campaign: reason: 3 - nextmap: c2m1_highway
	// Next chapter: reason: 3 - nextmap: c1m2_street
	// Chapter fail: reason: 1 - nextmap: 
	// End of campaign: reason: 4 - nextmap: 
	
	if (reason == 4)
	{
	  Left4Fun.CleanSaferoomMoney();
	  
	  // TODO:
	  //if (IsDedicatedServer() && !Director.IsSinglePlayerGame())
	  //	SendToServerConsole("changelevel c2m1_highway");
	}
}

::Left4Fun.Events.OnGameEvent_server_pre_shutdown <- function (params)
{
	local reason = Left4Fun.GetParam("reason", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnGameEvent_server_pre_shutdown - reason: " + reason);
}

::Left4Fun.Events.OnGameEvent_server_shutdown <- function (params)
{
	local reason = Left4Fun.GetParam("reason", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnGameEvent_server_shutdown - reason: " + reason);
}

::Left4Fun.Events.OnGameEvent_round_start <- function (params)
{
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnRoundStart");
	
	// Apparently, when scriptedmode is enabled and this director option isn't set, there is a big stutter (for the host)
	// when a witch is chasing a survivor and that survivor enters the saferoom. Simply having a value for this key, removes the stutter
	if (!("AllowWitchesInCheckpoints" in DirectorScript.GetDirectorOptions()))
		DirectorScript.GetDirectorOptions().AllowWitchesInCheckpoints <- false;
	
	::ConceptsHub.SetHandler("Left4Fun", Left4Fun.OnConcept);
	
	Left4Fun.LoadDirectorVars();
}

::Left4Fun.OnModeStart <- function ()
{
	local baseGameMode = Director.GetGameModeBase();
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnModeStart - " + Left4Fun.ModeName + " (" + baseGameMode + ")");
	
	//Left4Fun.Log(LOG_LEVEL_DEBUG, "GetSurvivorSet: " + Director.GetSurvivorSet() + " - GetMapName: " + Director.GetMapName() + " - GetGameModeBase: " + Director.GetGameModeBase());
	
	//Left4Fun.InitHud();
	
	// Load the list of melee weapons we are not allowed to use on this map
	Left4Fun.UnavailableMelee = {};
	local newMeleeList = [];
	
	local tbl = { classname = "env_sprite", model = "vgui/hud/icon_arrow_plain.vmt" };
	PrecacheEntityFromTable(tbl);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "MeleeWeapon count: " + Left4Fun.MeleeWeapon.len());
	foreach (wep in Left4Fun.MeleeWeapon)
	{
		local e = g_ModeScript.SpawnMeleeWeapon(wep, Vector(0, -10000, 0), QAngle(0, 0, 0));
		if (e)
		{
			DoEntFire("!self", "Kill", "", 0.1, e, e);
			newMeleeList.push(wep);
		}
		else
		{
			Left4Fun.UnavailableMelee[wep] <- 0;
			Left4Fun.Log(LOG_LEVEL_DEBUG, "OnModeStart - Added " + wep + " to the unavailable melee weapon list");
		}
	}
	
	Left4Fun.MeleeWeapon <- newMeleeList;
	Left4Fun.Log(LOG_LEVEL_DEBUG, "MeleeWeapon count: " + Left4Fun.MeleeWeapon.len());
	
	if (Left4Fun.L4FCvars.money && !Left4Fun.L4FCvars.money_reset)
		Left4Fun.LoadBank();
	
	Left4Fun.RestoreExtraSurvivors();
	
	//Left4Fun.LoadDirectorVars();
	
	if (Left4Fun.L4FCvars.render_hasCommon)
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "Starting RenderCommons timer...");
		Left4Timers.AddTimer("RenderCommons", 0.2, Left4Fun.RenderCommons, { }, true);
	}
	
	if ("BoomerLimit" in DirectorScript.GetDirectorOptions())
	{
		Left4Fun.InfectedLimits[Z_BOOMER] <- DirectorScript.GetDirectorOptions().BoomerLimit;
		Left4Fun.Log(LOG_LEVEL_DEBUG, "BoomerLimit taken from DirectorOptions: " + Left4Fun.InfectedLimits[Z_BOOMER]);
	}
	else if (baseGameMode == "versus")
	{
		Left4Fun.InfectedLimits[Z_BOOMER] <- Convars.GetStr("z_versus_boomer_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "BoomerLimit taken from z_versus_boomer_limit: " + Left4Fun.InfectedLimits[Z_BOOMER]);
	}
	else
	{
		Left4Fun.InfectedLimits[Z_BOOMER] <- Convars.GetStr("z_boomer_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "BoomerLimit taken from z_boomer_limit: " + Left4Fun.InfectedLimits[Z_BOOMER]);
	}
	
	if ("ChargerLimit" in DirectorScript.GetDirectorOptions())
	{
		Left4Fun.InfectedLimits[Z_CHARGER] <- DirectorScript.GetDirectorOptions().ChargerLimit;
		Left4Fun.Log(LOG_LEVEL_DEBUG, "ChargerLimit taken from DirectorOptions: " + Left4Fun.InfectedLimits[Z_CHARGER]);
	}
	else if (baseGameMode == "versus")
	{
		Left4Fun.InfectedLimits[Z_CHARGER] <- Convars.GetStr("z_versus_charger_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "ChargerLimit taken from z_versus_charger_limit: " + Left4Fun.InfectedLimits[Z_CHARGER]);
	}
	else
	{
		Left4Fun.InfectedLimits[Z_CHARGER] <- Convars.GetStr("z_charger_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "ChargerLimit taken from z_charger_limit: " + Left4Fun.InfectedLimits[Z_CHARGER]);
	}
	
	if ("HunterLimit" in DirectorScript.GetDirectorOptions())
	{
		Left4Fun.InfectedLimits[Z_HUNTER] <- DirectorScript.GetDirectorOptions().HunterLimit;
		Left4Fun.Log(LOG_LEVEL_DEBUG, "HunterLimit taken from DirectorOptions: " + Left4Fun.InfectedLimits[Z_HUNTER]);
	}
	else if (baseGameMode == "versus")
	{
		Left4Fun.InfectedLimits[Z_HUNTER] <- Convars.GetStr("z_versus_hunter_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "HunterLimit taken from z_versus_hunter_limit: " + Left4Fun.InfectedLimits[Z_HUNTER]);
	}
	else
	{
		Left4Fun.InfectedLimits[Z_HUNTER] <- Convars.GetStr("z_hunter_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "HunterLimit taken from z_hunter_limit: " + Left4Fun.InfectedLimits[Z_HUNTER]);
	}
	
	if ("JockeyLimit" in DirectorScript.GetDirectorOptions())
	{
		Left4Fun.InfectedLimits[Z_JOCKEY] <- DirectorScript.GetDirectorOptions().JockeyLimit;
		Left4Fun.Log(LOG_LEVEL_DEBUG, "JockeyLimit taken from DirectorOptions: " + Left4Fun.InfectedLimits[Z_JOCKEY]);
	}
	else if (baseGameMode == "versus")
	{
		Left4Fun.InfectedLimits[Z_JOCKEY] <- Convars.GetStr("z_versus_jockey_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "JockeyLimit taken from z_versus_jockey_limit: " + Left4Fun.InfectedLimits[Z_JOCKEY]);
	}
	else
	{
		Left4Fun.InfectedLimits[Z_JOCKEY] <- Convars.GetStr("z_jockey_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "JockeyLimit taken from z_jockey_limit: " + Left4Fun.InfectedLimits[Z_JOCKEY]);
	}
	
	if ("SmokerLimit" in DirectorScript.GetDirectorOptions())
	{
		Left4Fun.InfectedLimits[Z_SMOKER] <- DirectorScript.GetDirectorOptions().SmokerLimit;
		Left4Fun.Log(LOG_LEVEL_DEBUG, "SmokerLimit taken from DirectorOptions: " + Left4Fun.InfectedLimits[Z_SMOKER]);
	}
	else if (baseGameMode == "versus")
	{
		Left4Fun.InfectedLimits[Z_SMOKER] <- Convars.GetStr("z_versus_smoker_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "SmokerLimit taken from z_versus_smoker_limit: " + Left4Fun.InfectedLimits[Z_SMOKER]);
	}
	else
	{
		Left4Fun.InfectedLimits[Z_SMOKER] <- Convars.GetStr("z_smoker_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "SmokerLimit taken from z_smoker_limit: " + Left4Fun.InfectedLimits[Z_SMOKER]);
	}
	
	if ("SpitterLimit" in DirectorScript.GetDirectorOptions())
	{
		Left4Fun.InfectedLimits[Z_SPITTER] <- DirectorScript.GetDirectorOptions().SpitterLimit;
		Left4Fun.Log(LOG_LEVEL_DEBUG, "SpitterLimit taken from DirectorOptions: " + Left4Fun.InfectedLimits[Z_SPITTER]);
	}
	else if (baseGameMode == "versus")
	{
		Left4Fun.InfectedLimits[Z_SPITTER] <- Convars.GetStr("z_versus_spitter_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "SpitterLimit taken from z_versus_spitter_limit: " + Left4Fun.InfectedLimits[Z_SPITTER]);
	}
	else
	{
		Left4Fun.InfectedLimits[Z_SPITTER] <- Convars.GetStr("z_spitter_limit").tointeger();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "SpitterLimit taken from z_spitter_limit: " + Left4Fun.InfectedLimits[Z_SPITTER]);
	}
	
	if (Left4Fun.L4FCvars.money)
	{
		Left4Timers.AddTimer("BotsBuyThink", 5, Left4Fun.BotsBuyThink, { }, true);
		
		if (Left4Fun.L4FCvars.money_replacepickups)
		{
			Left4Fun.LoadSaferoomMoney();
			Left4Timers.AddTimer("DelayedReplacePickupsWithMoney", 0.5, Left4Fun.DelayedReplacePickupsWithMoney, { }, false);
		}
	}
	
	if (Left4Fun.L4FCvars.money_hud || Left4Fun.L4FCvars.survivor_abilities_hud)
		Left4Fun.ShowHud();
	
	foreach (val in Left4Fun.SanitizeList)
	{
		switch (val)
		{
			case "all":
			{
				Left4Fun.Sanitize(true, true, true, true, true, true, true, true, true, true, true, true);
				break;
			}
			case "weapons":
			{
				Left4Fun.Sanitize(true, false, false, false, false, false, false, false, false, false, false, false);
				break;
			}
			case "weapon_spawns":
			{
				Left4Fun.Sanitize(false, true, false, false, false, false, false, false, false, false, false, false);
				break;
			}
			case "utils":
			{
				Left4Fun.Sanitize(false, false, true, false, false, false, false, false, false, false, false, false);
				break;
			}
			case "util_spawns":
			{
				Left4Fun.Sanitize(false, false, false, true, false, false, false, false, false, false, false, false);
				break;
			}
			case "meds":
			{
				Left4Fun.Sanitize(false, false, false, false, true, false, false, false, false, false, false, false);
				break;
			}
			case "med_spawns":
			{
				Left4Fun.Sanitize(false, false, false, false, false, true, false, false, false, false, false, false);
				break;
			}
			case "health_cabinets":
			{
				Left4Fun.Sanitize(false, false, false, false, false, false, true, false, false, false, false, false);
				break;
			}
			case "upgrades":
			{
				Left4Fun.Sanitize(false, false, false, false, false, false, false, true, false, false, false, false);
				break;
			}
			case "upgrade_spawns":
			{
				Left4Fun.Sanitize(false, false, false, false, false, false, false, false, true, false, false, false);
				break;
			}
			case "extras":
			{
				Left4Fun.Sanitize(false, false, false, false, false, false, false, false, false, true, false, false);
				break;
			}
			case "extra_spawns":
			{
				Left4Fun.Sanitize(false, false, false, false, false, false, false, false, false, false, true, false);
				break;
			}
			case "ammo":
			{
				Left4Fun.Sanitize(false, false, false, false, false, false, false, false, false, false, false, true);
				break;
			}
			default:
			{
				Left4Fun.Log(LOG_LEVEL_WARN, "Invalid sanitize switch : " + val);
			}
		}
	}
	
	Left4Timers.AddTimer("FindMapAreas", 0.1, Left4Fun.DoFindMapAreas, { }, false);
	
	if (Left4Fun.L4FCvars.timed_notice && Left4Fun.L4FCvars.timed_notice != "" && Left4Fun.L4FCvars.timed_notice_interval > 0)
		Left4Timers.AddTimer(null, Left4Fun.L4FCvars.timed_notice_interval, @(params) Left4Fun.ChatNotice(params.text, PRINTCOLOR_ORANGE, true), { text = Left4Fun.L4FCvars.timed_notice }, true);
	
	if (Left4Fun.L4FCvars.survivor_abilities)
	{
		SurvivorAbilities.LastCooldownUpdate = Time();
		
		Left4Timers.AddTimer("SurvivorAbilitiesUpdate", 0.25, Left4Fun.SurvivorAbilitiesUpdate, { }, true);
	}
	
	Left4Fun.ModeStarted = true;
}

::Left4Fun.Events.OnGameEvent_finale_start <- function (params)
{
	local campaign = Left4Fun.GetParam("campaign", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnFinaleStart - " + campaign);
	
	// Fix for 'The Sacrifice' finale script (c7m3_port_finale)
	// The 'DELAY' stages will really last 9999 seconds in certain situations
	if (campaign == "L4D2C7")
	{
		DirectorScript.GetDirectorOptions().A_CustomFinaleValue3 = 99;
		DirectorScript.GetDirectorOptions().A_CustomFinaleValue6 = 99;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "c7m3_port_finale fixed");
	}
}

::Left4Fun.Events.OnGameEvent_player_connect_full <- function (params)
{
	local userid = Left4Fun.GetParamInt("userid", params);
	local player = Left4Fun.GetParamPlayer("userid", params);
	local index = Left4Fun.GetParamInt("index", params);
	
	if (!player || !player.IsValid())
	{
		Left4Fun.Log(LOG_LEVEL_ERROR, "OnGameEvent_player_connect_full - player with userid " + userid + " has an invalid player entity");
		return;
	}
	
	local steamid = player.GetNetworkIDString();
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Player connected full: " + player.GetPlayerName() + " - " + steamid);
	
	if (Left4Fun.IsBanned(player))
	{
		SendToServerConsole("kickid " + steamid + " You are banned from this server");
		Left4Fun.Log(LOG_LEVEL_INFO, "Player has been kicked (he was banned)");
		Left4Fun.ChatNotice(player.GetPlayerName() + " has been kicked with the reason: You are banned from this server", PRINTCOLOR_ORANGE);
		
		return;
	}
	
	// Is this even needed? TODO: check
	foreach (model in ::Left4Fun.ModelsToPrecache)
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "Precaching model '" + model + "' on client " + player.GetPlayerName());
		player.PrecacheModel(model);
	}
	// Is this even needed? TODO: check
	foreach (sound in ::Left4Fun.SoundsToPrecache)
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "Precaching sound '" + sound + "' on client " + player.GetPlayerName());
		player.PrecacheScriptSound(sound);
	}
}

::Left4Fun.Events.OnGameEvent_player_disconnect <- function (params)
{
	local userid = Left4Fun.GetParamInt("userid", params);
	local player = Left4Fun.GetParamPlayer("userid", params);
	local reason = Left4Fun.GetParam("reason", params); // "self", "kick", "ban", "cheat", "error"
	local name = Left4Fun.GetParam("name", params);
	local xuid = Left4Fun.GetParam("xuid", params);
	local steamID = Left4Fun.GetParam("networkid", params);
	local bot = Left4Fun.GetParamBool("bot", params);

	if (!player || !player.IsValid() || IsPlayerABot(player))
		return;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Player left: " + player.GetPlayerName());
	
	if (NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS && (player.IsDead() || player.IsDying()))
		SurvivorAbilities.SurvivorOut(player);
	
	SurvivorAbilities.RemovePreferred(player);
}

::Left4Fun.Events.OnGameEvent_player_spawn <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	
	if (!player || !player.IsValid())
		return;
	
	Left4Timers.AddTimer(null, 0.01, ::Left4Fun.OnPostSpawn, { player = player }, false);
}

::Left4Fun.OnPostSpawn <- function (params)
{
	local player = params["player"];
	if (!player || !player.IsValid())
		return;
	
	//Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun.OnPostSpawn - player: " + player.GetPlayerName());
	
	if (NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS)
	{
		if (Left4Fun.L4FCvars.disable_ledge_hang)
			DoEntFire("!self", "DisableLedgeHang", "", 0, null, player);
		
		SurvivorAbilities.SurvivorIn(player);
		
		if (Left4Fun.L4FCvars.survivor_abilities && Left4Fun.L4FCvars.survivor_abilities_add_onspawn)
		{
			if (SurvivorAbilities.AddPreferredAbility(player) && Left4Fun.L4FCvars.survivor_abilities_notifications)
				Left4Fun.PrintToPlayerChat(player, "Ability started", PRINTCOLOR_GREEN);
			else if (Left4Fun.L4FCvars.survivor_abilities_notifications)
				Left4Fun.Log(LOG_LEVEL_DEBUG, "OnSpawn - player " + player.GetPlayerName() + " already has another active ability");
		}
	}
	
	if (player.GetZombieType() == Z_TANK && Left4Fun.TankWasOnFire)
	{
		Left4Fun.TankWasOnFire = false;
		DoEntFire("!self", "IgniteLifetime", "1000", 0, null, player);
		//Left4Fun.Log(LOG_LEVEL_DEBUG, "Tank ignited");
	}
	
	if (Left4Fun.ModeStarted)
	{
		/*TODO: All this InfectedLimits next_infected stuff must be rewritten better
		local t = NetProps.GetPropInt(player, "m_zombieClass");
		if (t >= 1 && t <= 6)
		{
			if ((Left4Fun.InfectedLimits[t] - ::Left4Utils.GetAlivePlayersByType(t).len()) < 0)
			{
				//Do not kill the player on player_spawn!!!  Left4Fun.DO_next_infected(player);
				return;
			}
		}
		*/
	}
	
	if (NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_INFECTED)
	{
		if (IsPlayerABot(player))
			Left4Timers.AddTimer("DelayedOnSpawn_" + player.GetPlayerUserId(), 0.2, Left4Fun.DelayedOnSpawn, { userid = player.GetPlayerUserId() }, false);
		else
		{
			local userid = player.GetPlayerUserId().tointeger();
			if (userid == Left4Fun.ZombieSelectionUserid)
			{
				Left4Fun.ZombieSelectionUserid = -1;
			  
				NetProps.SetPropInt(player, "m_isCulling", 1);
				Left4Utils.ClientCommand(player, "+use");
			}
		}
	}
	
	if (NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS)
	{
		local charName = Left4Utils.GetCharacterName(player);
		if (charName && charName != "" && !(charName in ::Left4Fun.SurvivorsSpawned))
		{
			Left4Fun.SurvivorsSpawned[charName] <- true;
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "OnStartSpawn - player: " + player.GetPlayerName());
			
			if (Left4Fun.Locations["checkpointA"] == null)
				Left4Fun.Locations["checkpointA"] <- player.GetOrigin();
			
			//Left4Fun.Log(LOG_LEVEL_DEBUG, "OnSurvivorsSpawned - count: " + count);
			
			if (Left4Fun.SurvivorsSpawned.len() == 4 && Left4Fun.L4FCvars.health_onnewchapter > 0)
			{
				foreach (survivor in ::Left4Utils.GetAliveSurvivors())
				{
					survivor.GiveItem("health");
					survivor.SetHealthBuffer(0);
					survivor.SetHealth(Left4Fun.L4FCvars.health_onnewchapter);
					
					Left4Fun.Log(LOG_LEVEL_DEBUG, "OnSurvivorsSpawned - Health of player " + survivor.GetPlayerName() + " has been refilled to " + survivor.GetHealth());
				}
			}
		}
		
		// Resync for reload_fix
		local w = Left4Utils.GetInventoryItemInSlot(player, INV_SLOT_PRIMARY);
		if (w && w.IsValid() && Left4Fun.ReloadFixWeps.find(w.GetClassname()) != null)
		{
			Left4Fun.ReloadFixClips[w.GetEntityIndex()] <- NetProps.GetPropInt(w, "m_iClip1");
				
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun.ReloadFixClips.len() = " + Left4Fun.ReloadFixClips.len());
		}
			//NetProps.SetPropInt(w, "m_iClip2", NetProps.GetPropInt(w, "m_iClip1"));
	}
	else if (NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_L4D1_SURVIVORS)
	{
		if (IsPlayerABot(player))
			Left4Fun.SetupExtraSurvivor(player);
			
		// Resync for reload_fix
		local w = Left4Utils.GetInventoryItemInSlot(player, INV_SLOT_PRIMARY);
		if (w && w.IsValid() && Left4Fun.ReloadFixWeps.find(w.GetClassname()) != null)
		{
			Left4Fun.ReloadFixClips[w.GetEntityIndex()] <- NetProps.GetPropInt(w, "m_iClip1");
				
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun.ReloadFixClips.len() = " + Left4Fun.ReloadFixClips.len());
		}
			//NetProps.SetPropInt(w, "m_iClip2", NetProps.GetPropInt(w, "m_iClip1"));
	}
	
	Left4Fun.ApplyPlayerRenderCVars(player);
}

::Left4Fun.Events.OnGameEvent_witch_spawn <- function (params)
{
	local witchid = Left4Fun.GetParamEntity("witchid", params);
	
	Left4Timers.AddTimer("DelayedOnWitchSpawned_" + UniqueString(), 0.2, Left4Fun.DelayedOnWitchSpawned, { witch = witchid }, false);
	
	Left4Fun.ApplyRenderCVars(witchid, "witch");
}

::Left4Fun.Events.OnGameEvent_ghost_spawn_time <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	local spawntime = Left4Fun.GetParamInt("spawntime", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnGhostSpawnTime - " + player.GetPlayerName() + " - spawntime: " + spawntime);
	
	foreach (tank in ::Left4Utils.GetAlivePlayersByType(Z_TANK))
	{
		//if (IsPlayerABot(tank) && !tank.IsDead() && !tank.IsDying() && tank.GetFrustration() < 90)
		//if (IsPlayerABot(tank) && !tank.IsDead() && !tank.IsDying() && !tank.IsOnFire())
		if (IsPlayerABot(tank) && !tank.IsDead() && !tank.IsDying())
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Found a bot tank to offer");
			
			local pos = tank.GetOrigin();
			local ang = tank.GetAngles();
			Left4Fun.TankWasOnFire = tank.IsOnFire();
			
			local zsh = Convars.GetFloat("z_spawn_health");
			Convars.SetValue("z_spawn_health", tank.GetHealth());
			
			tank.SetOrigin(Vector(0,0,-10000));
			Left4Utils.KillPlayer(tank);
			
			ZSpawn({type = Z_TANK, pos = pos, ang = ang});
			
			Convars.SetValue("z_spawn_health", zsh);
			
			return;
		}
	}
	Left4Fun.Log(LOG_LEVEL_DEBUG, "No bot tank to offer");	
}

::Left4Fun.Events.OnGameEvent_player_death <- function (params)
{
/*
short	userid	user ID who died
long	entityid	entity ID who died, userid should be used first, to get the dead Player. Otherwise, it is not a player, so use this.
short	attacker	user ID who killed
string	attackername	What type of zombie, so we don't have zombie names
long	attackerentid	if killer not a player, the entindex of who killed. Again, use attacker first
string	weapon	weapon name killer used
bool	headshot	signals a headshot
bool	attackerisbot	is the attacker a bot
string	victimname	What type of zombie, so we don't have zombie names
bool	victimisbot	is the victim a bot
bool	abort	did the victim abort
long	type	damage type
float	victim_x	
float	victim_y	
float	victim_z	
*/	
	
	local victim = Left4Fun.GetParamPlayerOrEntity("userid", "entityid", params);
	if (!victim || !victim.IsValid())
		return;

	local attacker = Left4Fun.GetParamPlayerOrEntity("attacker", "attackerentid", params);
	//local weapon = Left4Fun.GetParam("weapon", params);
	
	if (NetProps.GetPropInt(victim, "m_iTeamNum") == TEAM_SURVIVORS)
		SurvivorAbilities.SurvivorOut(victim);
	
	local p = Left4Fun.GetSurvivor(victim);
	if (p)
	{
		local characterName = p.GetPlayerName();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "Survivor dead: " + characterName);
		
		local pl = Left4Users.GetOnlineUserLevel(p.GetPlayerUserId());
		if (pl >= L4U_LEVEL.User && (Left4Fun.L4FCvars.autorespawn == ST_USER.ALL || (Left4Fun.L4FCvars.autorespawn == ST_USER.ADMINS && pl >= L4U_LEVEL.Admin) || (Left4Fun.L4FCvars.autorespawn == ST_USER.USERS && pl < L4U_LEVEL.Admin)))
			Left4Timers.AddTimer(null, Left4Fun.L4FCvars.autorespawn_delay, @(params) Left4Fun.RespawnDeadPlayer(params.userid), { userid = p.GetPlayerUserId() }, false);
	}
	
	if (!Left4Fun.ModeStarted)
		return;
	
	if (!attacker || !attacker.IsValid())
		return;
	
	local t = NetProps.GetPropInt(victim, "m_zombieClass");
	
	//Left4Fun.Log(LOG_LEVEL_DEBUG, "OnDeath - attacker: " + attacker.GetPlayerName() + " - victim: " + victim.GetPlayerName() + " - t: " + t + " - " + victim.GetClassname());
	
	//if (NetProps.GetPropInt(attacker, "m_iTeamNum") != TEAM_SURVIVORS)
	//	return;
		
	//Left4Fun.DebugChatNotice("OnDeath - " + t + " - " + attacker.GetPlayerName());
	
	//Left4Fun.ZombieMoneyDrop(t, victim.GetOrigin(), victim.GetAngles(), victim.GetVelocity());
	//if (t > 0 && t != 9) // common = -1 not 0
	//  Left4Fun.SpawnL4FDrop(L4FPICKUP_GIFT_MODEL, L4FPICKUP_GIFT_PTYPE, 1, victim.GetOrigin() + Vector(0, 0, 50), victim.GetAngles(), victim.GetVelocity());
	
	if (t == -1)
	{
		local c = victim.GetClassname();
		if (c == "infected")
			Left4Fun.DropZombieDropsItem("common", attacker, victim);
		else if (c == "witch")
		{
			//Left4Fun.SpawnL4FDrop(L4FPICKUP_GIFT_MODEL, L4FPICKUP_GIFT_PTYPE, 1, victim.GetOrigin() + Vector(0, 0, 50), victim.GetAngles(), victim.GetVelocity());
			
			if (attacker && NetProps.GetPropInt(attacker, "m_iTeamNum") == TEAM_SURVIVORS)
				Left4Fun.ZombieMoneyEarn(attacker, Z_WITCH);
			
			Left4Fun.DropZombieDropsItem("witch", attacker, victim);
		}
	}
	else if (t >= 1 && t <= 6)
		Left4Fun.DropZombieDropsItem("special", attacker, victim);
	else if (t == Z_TANK)
		Left4Fun.DropZombieDropsItem("tank", attacker, victim);
	
	if (attacker && NetProps.GetPropInt(attacker, "m_iTeamNum") == TEAM_SURVIVORS)
		Left4Fun.ZombieMoneyEarn(attacker, t);	
}

::Left4Fun.Events.OnGameEvent_revive_success <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	local subject = Left4Fun.GetParamPlayer("subject", params);
	
	if (Left4Fun.L4FCvars.adrenalineboost == ST_USER.NONE)
 		return;
	
	local p = Left4Fun.GetSurvivor(player);
	if (p)
	{
		local pl = Left4Users.GetOnlineUserLevel(p.GetPlayerUserId());
		if (pl >= L4U_LEVEL.User && (Left4Fun.L4FCvars.adrenalineboost == ST_USER.ALL || (Left4Fun.L4FCvars.adrenalineboost == ST_USER.ADMINS && pl >= L4U_LEVEL.Admin) || (Left4Fun.L4FCvars.adrenalineboost == ST_USER.USERS && pl < L4U_LEVEL.Admin)))
			p.UseAdrenaline(Left4Fun.L4FCvars.adrenalineboost_duration_onrevive);
	}
	
	local s = Left4Fun.GetSurvivor(subject);
	if (s)
	{
		local sl = Left4Users.GetOnlineUserLevel(s.GetPlayerUserId());
		if (sl >= L4U_LEVEL.User && (Left4Fun.L4FCvars.adrenalineboost == ST_USER.ALL || (Left4Fun.L4FCvars.adrenalineboost == ST_USER.ADMINS && sl >= L4U_LEVEL.Admin) || (Left4Fun.L4FCvars.adrenalineboost == ST_USER.USERS && sl < L4U_LEVEL.Admin)))
			s.UseAdrenaline(Left4Fun.L4FCvars.adrenalineboost_duration_onrevive);
	}
}

::Left4Fun.Events.OnGameEvent_survivor_call_for_help <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	local subject = Left4Fun.GetParamEntity("subject", params);
	
	local p = Left4Fun.GetSurvivor(player);
	if (!p)
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "OnSurvivorCallForHelp on non survivor!!!");
		return;
	}
 	
 	local pl = Left4Users.GetOnlineUserLevel(p.GetPlayerUserId());
	if (pl < L4U_LEVEL.User)
 		return;
 	
 	local characterName = p.GetPlayerName();
 	Left4Fun.Log(LOG_LEVEL_DEBUG, "Survivor calling for help: " + characterName);
  
	if (Left4Fun.L4FCvars.autorespawn == ST_USER.ALL || (Left4Fun.L4FCvars.autorespawn == ST_USER.ADMINS && pl >= L4U_LEVEL.Admin) || (Left4Fun.L4FCvars.autorespawn == ST_USER.USERS && pl < L4U_LEVEL.Admin))
	{
		Left4Utils.RescueSurvivor(p);
 			
		Left4Fun.Log(LOG_LEVEL_DEBUG, characterName + " self rescued");
		Left4Fun.ChatNotice(characterName + " self rescued");
 	}
}

::Left4Fun.Events.OnGameEvent_item_pickup <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	local item = Left4Fun.GetParam("item", params);
	
	if (Left4Users.GetOnlineUserLevel(player.GetPlayerUserId()) < L4U_LEVEL.User)
		return;
	
	if (item == "vomitjar" || item == "pipe_bomb" || item == "molotov")
	{
		local p = Left4Fun.GetSurvivor(player);
		if (!p)
			return;
		
		local userid = p.GetPlayerUserId();
		local count = 0;
		local fired = false;
		
		if ("UtilsRestore_" + userid in ::Left4Timers.Timers)
			Left4Timers.RemoveTimer("UtilsRestore_" + userid);
		else
		{
			if (userid in ::Left4Fun.UtilitiesFired)
			{
				count = Left4Fun.UtilitiesFired[userid].count;
				fired = Left4Fun.UtilitiesFired[userid].fired;
			}
		}
		if (fired)
			count += 1;
		else
			count = 0;
		Left4Fun.UtilitiesFired[userid] <- { count = count, fired = false };
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, player.GetPlayerName() + " picked up " + item + " - count: " + count);
	}
}

::Left4Fun.Events.OnGameEvent_weapon_fire <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	local weapon = Left4Fun.GetParam("weapon", params);
	//local weaponid = Left4Fun.GetParamInt("weaponid", params);
	//local count = Left4Fun.GetParamInt("count", params); // number of bullets
	
	local pl = Left4Users.GetOnlineUserLevel(player.GetPlayerUserId());
	if (pl < L4U_LEVEL.User)
		return;
	
	if (weapon == "molotov" || weapon == "pipe_bomb" || weapon == "vomitjar")
	{
		local userid = player.GetPlayerUserId();
		local count = 0;
		local fired = false;
		local interval = Left4Fun.L4FCvars.utils_restore_interval;
		local max_count = Left4Fun.L4FCvars.utils_max_restores;
		
		if (pl >= L4U_LEVEL.Admin)
		{
			interval = Left4Fun.L4FCvars.utils_restore_interval_adm;
			max_count = Left4Fun.L4FCvars.utils_max_restores_adm;
		}
		
		if (userid in ::Left4Fun.UtilitiesFired)
		{
			Left4Timers.RemoveTimer("UtilsRestore_" + userid);
			count = Left4Fun.UtilitiesFired[userid].count;
		}
		
		if (count >= max_count)
			Left4Fun.UtilitiesFired[userid] <- { count = 0, fired = false };
		else
		{
			Left4Fun.UtilitiesFired[userid] <- { count = count, fired = true };
			Left4Timers.AddTimer("UtilsRestore_" + userid, interval, Left4Fun.UtilityRestore, { playerID = player.GetPlayerUserId(), weapon = weapon }, false);
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, player.GetPlayerName() + " fired " + weapon + " - count: " + count);
		
		return;
	}

	local aw = player.GetActiveWeapon();
	if (aw && aw.GetEntityIndex() in ::Left4Fun.ReloadFixClips)
		Left4Fun.ReloadFixClips[aw.GetEntityIndex()] = NetProps.GetPropInt(aw, "m_iClip1") - 1;
		//NetProps.SetPropInt(aw, "m_iClip2", NetProps.GetPropInt(aw, "m_iClip1") - 1);
	
	if (weapon == "grenade_launcher")
	{
		if (Left4Fun.L4FCvars.gl_airborn_push_force != 0 && (NetProps.GetPropInt(player, "m_fFlags") & 1) == 0)
			player.ApplyAbsVelocityImpulse(player.EyeAngles().Forward() * Left4Fun.L4FCvars.gl_airborn_push_force * -1);
	}
	else if (weapon == "rifle_m60")
	{
		if (Left4Fun.L4FCvars.m60_airborn_push_force != 0 && (NetProps.GetPropInt(player, "m_fFlags") & 1) == 0)
			player.ApplyAbsVelocityImpulse(player.EyeAngles().Forward() * Left4Fun.L4FCvars.m60_airborn_push_force * -1);
		
		if (Left4Fun.Settings.m60_fix && aw && NetProps.GetPropInt(aw, "m_iClip1") <= 1) // m_iClip1 = 1 means that this is the last bullet of the clip
		{
			NetProps.SetPropFloat(aw, "m_flNextPrimaryAttack", Time() + 0.3);  // Stop firing for a while
			NetProps.SetPropInt(aw, "m_iClip1", 2); // This, after the event, becomes 1 and it's meant to prevent the weapon drop
			
			Left4Timers.AddTimer(null, 0.1, Left4Fun.ResetM60Clip, { weapon = aw }, false); // I can't set m_iClip1 to 0 here because the code that drops the weapon runs right after this event, so i reset it a bit later
		}
	}
}

::Left4Fun.Events.OnGameEvent_weapon_reload <- function (params)
{
	if (!Left4Fun.Settings.reload_fix)
		return;
	
	local player = Left4Fun.GetParamPlayer("userid", params);
	local manual = Left4Fun.GetParamInt("manual", params);
	
	local weapon = player.GetActiveWeapon();
	if (!weapon)
		return;
	
	if (Left4Fun.ReloadFixWeps.find(weapon.GetClassname()) == null)
		return;
	
	if (!(weapon.GetEntityIndex() in ::Left4Fun.ReloadFixClips))
	{
		Left4Fun.Log(LOG_LEVEL_WARN, "OnGameEvent_weapon_reload: weapon with id " + weapon.GetEntityIndex() + " of player " + player.GetPlayerName() + " is not in ReloadFixClips!");
		return;
	}
	
	//local clip2 = NetProps.GetPropInt(weapon, "m_iClip2");
	local clip2 = Left4Fun.ReloadFixClips[weapon.GetEntityIndex()];
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnGameEvent_weapon_reload: " + player.GetPlayerName() + " - " + manual + " - clip2: " + clip2);
	
	if (clip2 <= 0)
		return;
	
	NetProps.SetPropInt(weapon, "m_iClip1", clip2);
	
	local ammoType = NetProps.GetPropInt(weapon, "m_iPrimaryAmmoType");
	local ammo = NetProps.GetPropIntArray(player, "m_iAmmo", ammoType) - clip2;
	
	NetProps.SetPropIntArray(player, "m_iAmmo", ammo, ammoType);
}

::Left4Fun.Events.OnGameEvent_weapon_drop <- function (params)
{
	local weapon = null;
	if ("propid" in params)
		weapon = EntIndexToHScript(params["propid"]);
	
	if (!weapon || !weapon.IsValid())
		return;
	
	if (weapon.GetEntityIndex() in ::Left4Fun.ReloadFixClips)
		delete Left4Fun.ReloadFixClips[weapon.GetEntityIndex()];
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun.ReloadFixClips.len() = " + Left4Fun.ReloadFixClips.len());
	
	if (!Left4Fun.Settings.m60_fix || weapon.GetClassname() != "weapon_rifle_m60")
		return;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnGameEvent_weapon_drop - weapon_rifle_m60 dropped");
	
	if (NetProps.GetPropInt(weapon, "m_iClip1") > 0)
		return;

	NetProps.SetPropInt(weapon, "m_iClip1", 1); // m60 with empty clip cannot be picked up
		
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnGameEvent_weapon_drop - dropped weapon_rifle_m60 fixed");
}

::Left4Fun.Events.OnGameEvent_finale_start <- function (params)
{
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnGameEvent_finale_start");
}

::Left4Fun.Events.OnGameEvent_finale_rush <- function (params)
{
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnGameEvent_finale_rush");
}

::Left4Fun.Events.OnGameEvent_finale_escape_start <- function (params)
{
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnGameEvent_finale_escape_start");
}

::Left4Fun.Events.OnGameEvent_finale_vehicle_ready <- function (params)
{
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnGameEvent_finale_vehicle_ready");
}

::Left4Fun.Events.OnGameEvent_finale_win <- function (params)
{
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnGameEvent_finale_win");
}

::Left4Fun.Events.OnGameEvent_finale_vehicle_leaving <- function (params)
{
	local count = Left4Fun.GetParamInt("survivorcount", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnRescueVehicleLeaving - count: " + count);
	
	Left4Fun.RescueVehicleLeaving = true;
	
	if (Left4Fun.RescuedSurvivorsFixed)
		return;
		
	Left4Fun.RescuedSurvivorsFixed = true;
	
	if (Left4Fun.Settings.always_win != ST_USER.NONE)
	{
		foreach (survivor in ::Left4Utils.GetIncapacitatedSurvivors())
		{
			local sl = Left4Users.GetOnlineUserLevel(survivor.GetPlayerUserId());
			if (Left4Fun.Settings.always_win == ST_USER.ALL || (Left4Fun.Settings.always_win == ST_USER.ADMINS && sl >= L4U_LEVEL.Admin) || (Left4Fun.Settings.always_win == ST_USER.USERS && sl < L4U_LEVEL.Admin))
				//survivor.ReviveFromIncap();
				Left4Fun.HelpPlayer(survivor);
		}
		foreach (survivor in ::Left4Utils.GetDeadSurvivors())
		{
			local sl = Left4Users.GetOnlineUserLevel(survivor.GetPlayerUserId());
			if (Left4Fun.Settings.always_win == ST_USER.ALL || (Left4Fun.Settings.always_win == ST_USER.ADMINS && sl >= L4U_LEVEL.Admin) || (Left4Fun.Settings.always_win == ST_USER.USERS && sl < L4U_LEVEL.Admin))
				Left4Fun.RespawnDeadPlayer(survivor.GetPlayerUserId());
		}
	}
	
	foreach (survivor in ::Left4Utils.GetAliveSurvivors())
	{
		if (Left4Users.GetOnlineUserLevel(survivor.GetPlayerUserId()) < L4U_LEVEL.User)
			Left4Utils.KillPlayer(survivor);
	}
	
	// This triggers the finale_vehicle_leaving event itself and it's what saves the names of the rescued survivors (prints "ESCAPED: Name" in the console). I'm calling this to refresh the names.
	local tf = Entities.FindByClassname(null, "trigger_finale");
	if (tf)
		DoEntFire("!self", "FinaleEscapeForceSurvivorPositions", "", 0, null, tf);
}

::Left4Fun.Events.OnGameEvent_player_bot_replace <- function (params)
{
	local player = Left4Fun.GetParamPlayer("player", params);
	local bot = Left4Fun.GetParamPlayer("bot", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Bot " + bot.GetPlayerName() + " replaced player " + player.GetPlayerName());
	
	SurvivorAbilities.SurvivorReplace(bot, player);
	
	if (Left4Fun.RescueVehicleLeaving)
	{
		// Refreshing the names of the escaped survivors to fix the bug introduced by the TLS update.
		local tf = Entities.FindByClassname(null, "trigger_finale");
		if (tf)
			DoEntFire("!self", "FinaleEscapeForceSurvivorPositions", "", 0, null, tf);
	}
}

::Left4Fun.Events.OnGameEvent_bot_player_replace <- function (params)
{
	local bot = Left4Fun.GetParamPlayer("bot", params);
	local player = Left4Fun.GetParamPlayer("player", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Player " + player.GetPlayerName() + " replaced bot " + bot.GetPlayerName());
	
	SurvivorAbilities.SurvivorReplace(player, bot);
	
	if (Left4Fun.RescueVehicleLeaving)
	{
		// Refreshing the names of the escaped survivors to fix the bug introduced by the TLS update.
		local tf = Entities.FindByClassname(null, "trigger_finale");
		if (tf)
			DoEntFire("!self", "FinaleEscapeForceSurvivorPositions", "", 0, null, tf);
	}
}

::Left4Fun.Events.OnGameEvent_player_incapacitated <- function (params)
{
/*
short	userid	person who became incapacitated
short	attacker	user ID who made us incapacitated
long	attackerentid	if attacker not player, entindex of who made us incapacitated
string	weapon	weapon name attacker used
long	type	damage type
*/
	
	local player = Left4Fun.GetParamPlayer("userid", params);
	local attacker = Left4Fun.GetParamPlayerOrEntity("attacker", "attackerentid", params);
	local weapon = Left4Fun.GetParam("weapon", params);
	local dmgType = Left4Fun.GetParamInt("type", params);
	
	if (!player || NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS)
		return;
	
	if (Left4Fun.L4FCvars.survivor_abilities_removeonincap)
	{
		if (SurvivorAbilities.RemoveAbility(player) && Left4Fun.L4FCvars.survivor_abilities_notifications)
			Left4Fun.PrintToPlayerChat(player, "Ability lost", PRINTCOLOR_ORANGE);
	}
	
	local pl = Left4Users.GetOnlineUserLevel(player.GetPlayerUserId());
	if (Left4Fun.L4FCvars.helpme == ST_USER.ALL || (Left4Fun.L4FCvars.helpme == ST_USER.ADMINS && pl >= L4U_LEVEL.Admin) || (Left4Fun.L4FCvars.helpme == ST_USER.USERS && pl < L4U_LEVEL.Admin))
	{
		local itemName = null;
		if (Left4Utils.HasItem(player, "weapon_adrenaline"))
			itemName = "adrenaline";
		else if (Left4Utils.HasItem(player, "weapon_pain_pills"))
			itemName = "pain pills";
		else if (Left4Utils.HasItem(player, "weapon_first_aid_kit"))
			itemName = "first aid kit";
	
		if (itemName)
			Left4Fun.UserHint(player, "You can spend your " + itemName + " to help yourself by typing: !helpme", HINTCOLOR_WHITE, "icon_tip", 7);
	}
	
	if (Left4Fun.L4FCvars.remove_pistol_onincap)
	{
		local inv = {};
		GetInvTable(player, inv);
		if (("slot1" in inv) && inv["slot1"] && (inv["slot1"].GetClassname() == "weapon_pistol" || inv["slot1"].GetClassname() == "weapon_pistol_magnum"))
			inv["slot1"].Kill();
	}
}

::Left4Fun.Events.OnGameEvent_player_ledge_grab <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	local causer = Left4Fun.GetParamPlayer("causer", params);
	
	if (!player)
		return;
	
	if (Left4Fun.L4FCvars.survivor_abilities_removeonincap)
	{
		if (SurvivorAbilities.RemoveAbility(player) && Left4Fun.L4FCvars.survivor_abilities_notifications)
			Left4Fun.PrintToPlayerChat(player, "Ability lost", PRINTCOLOR_ORANGE);
	}
	
	local pl = Left4Users.GetOnlineUserLevel(player.GetPlayerUserId());
	if (Left4Fun.L4FCvars.helpme == ST_USER.ALL || (Left4Fun.L4FCvars.helpme == ST_USER.ADMINS && pl >= L4U_LEVEL.Admin) || (Left4Fun.L4FCvars.helpme == ST_USER.USERS && pl < L4U_LEVEL.Admin))
	{
		local itemName = null;
		if (Left4Utils.HasItem(player, "weapon_adrenaline"))
			itemName = "adrenaline";
		else if (Left4Utils.HasItem(player, "weapon_pain_pills"))
			itemName = "pain pills";
		else if (Left4Utils.HasItem(player, "weapon_first_aid_kit"))
			itemName = "first aid kit";
	
		if (itemName)
			Left4Fun.UserHint(player, "You can spend your " + itemName + " to help yourself by typing: !helpme", HINTCOLOR_WHITE, "icon_tip", 7);
	}
}

::Left4Fun.Events.OnGameEvent_player_use <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	local entity = Left4Fun.GetParamEntity("targetid", params);
	
	if (entity.GetName().find("_l4fpick"))
	{
		if (entity.GetMoveParent() != null)
			Left4Fun.OnL4FPickupGrabbed(player, entity.GetMoveParent());
		else
			Left4Fun.OnL4FPickupGrabbed(player, entity);
	}
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, player.GetPlayerName() + " USE " + entity.GetClassname());
}

::Left4Fun.Events.OnGameEvent_entity_shoved <- function (params)
{
	local entity = Left4Fun.GetParamEntity("entityid", params);
	local attacker = Left4Fun.GetParamPlayer("attacker", params);

	if (!("GetName" in entity))
		return;
	if (!("GetClassname" in entity))
		return;

	//Left4Fun.Log(LOG_LEVEL_DEBUG, entity.GetName() + " (" + entity.GetClassname() + ") shoved by " + attacker.GetPlayerName());
	
	if (entity.GetClassname() != "prop_physics")
		return;
	
	//if (entity.GetName().find("checkpoint_") != null)
	//	return; // Do not push the saferoom doors or they will fly away
	
	local al = Left4Users.GetOnlineUserLevel(attacker.GetPlayerUserId());
	if (Left4Fun.L4FCvars.supershove == ST_USER.NONE || al < L4U_LEVEL.User)
		return;

	if (Left4Fun.L4FCvars.supershove == ST_USER.ADMINS && al < L4U_LEVEL.Admin)
		return;

	if (Left4Fun.L4FCvars.supershove == ST_USER.USERS && al >= L4U_LEVEL.Admin)
		return;

	if (Left4Fun.L4FCvars.supershove_type == CV_SUPERSHOVETYPE.PUSH)
	{
		local v = attacker.GetForwardVector() * 700;
		v.z = 500;
		Left4Timers.AddTimer("DelayedPush_" + UniqueString(), 0.1, Left4Fun.DelayedPush, { entity = entity, velocity = v }, false);
	}	
}

::Left4Fun.Events.OnGameEvent_player_shoved <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	local attacker = Left4Fun.GetParamPlayer("attacker", params);
	
	//Left4Fun.Log(LOG_LEVEL_DEBUG, player.GetPlayerName() + " shoved by " + attacker.GetPlayerName());
	
	local al = Left4Users.GetOnlineUserLevel(attacker.GetPlayerUserId());
	if (al < L4U_LEVEL.User)
		return;
	
	if (Left4Fun.L4FCvars.supershove == ST_USER.NONE)
		return;

	if (Left4Fun.L4FCvars.supershove_onadmin == 0 && Left4Users.GetOnlineUserLevel(player.GetPlayerUserId()) >= L4U_LEVEL.Admin)
		return;

	if (Left4Fun.L4FCvars.supershove == ST_USER.ADMINS && al < L4U_LEVEL.Admin)
		return;

	if (Left4Fun.L4FCvars.supershove == ST_USER.USERS && al >= L4U_LEVEL.Admin)
		return;
	
	if (Left4Fun.L4FCvars.supershove_type == CV_SUPERSHOVETYPE.PUSH)
	{
		local v = attacker.GetForwardVector() * 700;
		v.z = 500;
		Left4Timers.AddTimer("DelayedPush_" + UniqueString(), 0.1, Left4Fun.DelayedPush, { entity = player, velocity = v }, false);
	}
	else
	{
		local c = NetProps.GetPropInt(player, "m_zombieClass");
		if (c == Z_SURVIVOR || c == Z_TANK || player.GetClassname() == "witch")
		{
			player.Stagger(attacker.GetOrigin());
			//EntFire("!activator", "SpeakResponseConcept", "PlayerFriendlyFire", 0, player);
			
			// TODO: Hurt(attacker) ?
		}
	}	
}

::Left4Fun.Events.OnGameEvent_player_jump_apex <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	
	//Left4Fun.DebugChatNotice("OnJumpApex - " + player.GetPlayerName());

	local pl = Left4Users.GetOnlineUserLevel(player.GetPlayerUserId());
	if (Left4Fun.L4FCvars.superjump == ST_USER.NONE || pl < L4U_LEVEL.User)
		return;
	
	if (!IsPlayerABot(player) && (player.GetButtonMask() & (1 << 1)) > 0)
	{
		if (Left4Fun.L4FCvars.superjump == ST_USER.ADMINS && pl < L4U_LEVEL.Admin)
			return;

		if (Left4Fun.L4FCvars.superjump == ST_USER.USERS && pl >= L4U_LEVEL.Admin)
			return;
		
		local v = player.GetVelocity();
		//v.Norm();
		v.z = 500;
		
		player.ApplyAbsVelocityImpulse(v);
	}	
}

::Left4Fun.Events.OnGameEvent_player_jump <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	
	// TODO: settings?
	
	//Left4Fun.DebugChatNotice("OnJump - " + player.GetPlayerName());
	
	if (IsPlayerABot(player))
		return;

	// bhop check
	local vel = player.GetVelocity();
	local h = Left4Fun.HorizontalVelocity(vel);
	if (h > 320 && !player.IsAdrenalineActive())
	{
		vel.x = 0;
		vel.y = 0;
//		player.SetVelocity(vel);
			
		//Left4Fun.AdminChatNotice(ST_NOTICE.WARNING, player.GetPlayerName() + ": " + h);
		Left4Fun.Log(LOG_LEVEL_INFO, "OnJump - player: " + player.GetPlayerName() + " - velocity: " + h);
	}	
}

::Left4Fun.Events.OnGameEvent_friendly_fire <- function (params)
{
	local attacker = Left4Fun.GetParamPlayer("attacker", params);
	local victim = Left4Fun.GetParamPlayer("victim", params);
	local guilty = Left4Fun.GetParamPlayer("guilty", params);
	local dmgType = Left4Fun.GetParamInt("type", params);
	
	if (!Left4Fun.L4FCvars.money)
		return;
	
	if (!guilty)
		guilty = attacker;
	
	//Left4Fun.Log(LOG_LEVEL_DEBUG, "OnFriendlyFire - " + guilty.GetPlayerName());
	
	if (NetProps.GetPropInt(guilty, "m_iTeamNum") != TEAM_SURVIVORS)
		return;
		
	Left4Fun.SubBankItemAmount(guilty, "money", 30);	
}

::Left4Fun.Events.OnGameEvent_charger_charge_start <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnChargerChargeStart - " + player.GetPlayerName());
	
	if (!Left4Fun.L4FCvars.charger_steer_humans && !IsPlayerABot(player) || !Left4Fun.L4FCvars.charger_steer_bots && IsPlayerABot(player))
		return;	
	
	local flags = NetProps.GetPropInt(player, "m_fFlags");
	NetProps.SetPropInt(player, "m_fFlags", flags & ~(1 << 5)); // unset FL_FROZEN

	local wep = NetProps.GetPropEntity(player, "m_hActiveWeapon");
	if(wep != null)
		NetProps.SetPropFloat(wep, "m_flNextSecondaryAttack", Time() + 999.9);
}

::Left4Fun.Events.OnGameEvent_charger_charge_end <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnChargerChargeEnd - " + player.GetPlayerName());
	
	local wep = NetProps.GetPropEntity(player, "m_hActiveWeapon");
	if(wep != null)
		NetProps.SetPropFloat(wep, "m_flNextSecondaryAttack", Time() + 1.0);
}

::Left4Fun.Events.OnGameEvent_player_entered_start_area <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	if (!Left4Fun.ModeStarted || !player || !player.IsValid() || player.GetClassname() != "player" || NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS)
		return;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnPlayerEnteredStartArea - player: " + player.GetPlayerName());
	
	local charName = Left4Utils.GetCharacterName(player);
	if (charName && charName != "")
	{
		Left4Fun.PlayersInStartArea[charName] <- true;
		Left4Fun.PlayersInSafeSpot[charName] <- true;
	}
}

::Left4Fun.Events.OnGameEvent_player_left_start_area <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	if (!Left4Fun.ModeStarted || !player || !player.IsValid() || player.GetClassname() != "player" || NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS)
		return;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnPlayerLeftStartArea - player: " + player.GetPlayerName());
	
	local charName = Left4Utils.GetCharacterName(player);
	if (charName && charName != "")
	{
		Left4Fun.PlayersInStartArea[charName] <- false;
		Left4Fun.PlayersInSafeSpot[charName] <- false;
	}
}

::Left4Fun.Events.OnGameEvent_player_entered_checkpoint <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	
	Left4Timers.AddTimer(null, 0.01, @(params) Left4Fun.OnPlayerEnteredCheckpoint, { player = player }, false);
}

::Left4Fun.OnPlayerEnteredCheckpoint <- function (player)
{
	if (!player || !Player.IsValid())
		return;
	
	if (!Left4Fun.ModeStarted || !player || !player.IsValid() || player.GetClassname() != "player" || NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS)
		return;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnPlayerEnteredCheckpoint - player: " + player.GetPlayerName());
	
	local charName = Left4Utils.GetCharacterName(player);
	if (charName && charName != "")
		Left4Fun.PlayersInSafeSpot[charName] <- true;	
}

::Left4Fun.Events.OnGameEvent_player_left_checkpoint <- function (params)
{
	local player = Left4Fun.GetParamPlayer("userid", params);
	if (!Left4Fun.ModeStarted || !player || !player.IsValid() || player.GetClassname() != "player" || NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS)
		return;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnPlayerLeftCheckpoint - player: " + player.GetPlayerName());
	
	local charName = Left4Utils.GetCharacterName(player);
	if (charName && charName != "")
		Left4Fun.PlayersInSafeSpot[charName] <- false;
}

::Left4Fun.Events.OnGameEvent_achievement_earned <- function (params)
{
	local playerIndex = Left4Fun.GetParamInt("player", params);
	local achievementID = Left4Fun.GetParamInt("achievement", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnAchievementEarned - playerIndex: " + playerIndex + " - achievementID: " + achievementID);
}

::Left4Fun.Events.OnGameEvent_achievement_event <- function (params)
{
	local achievement = Left4Fun.GetParam("achievement_name", params);
	local cur_val = Left4Fun.GetParamInt("cur_val", params);
	local max_val = Left4Fun.GetParamInt("max_val", params);
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "OnAchievementEvent - achievement: " + achievement + " - cur_val: " + cur_val + " - max_val: " + max_val);
}

// ---------------------------------------------

::Left4Fun.AllowTakeDamage <- function (damageTable)
{
	//Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun.AllowTakeDamage");
	
	local victim = null;
	local attacker = null;
	local damageDone = 0;
	
	if (("Victim" in damageTable) && damageTable.Victim != null)
		victim = damageTable.Victim;
		
	if (("Attacker" in damageTable) && damageTable.Attacker != null)
		attacker = damageTable.Attacker;
	
	if (("DamageDone" in damageTable) && damageTable.DamageDone != null)
		damageDone = damageTable.DamageDone;
	
	if (victim && victim.GetClassname() == "player")
	{
		local dmg = Left4Fun.OnPlayerDamage(victim, attacker, damageDone, damageTable);
		if (dmg != null)
			damageTable.DamageDone = dmg;
		
		return (damageTable.DamageDone > 0);
	}
	
	return true;
}

HooksHub.SetAllowTakeDamage("L4F", ::Left4Fun.AllowTakeDamage);

::Left4Fun.OnPlayerDamage <- function (victim, attacker, damageDone, damageTable)
{	
	/*
	if (victim)
		Left4Fun.Log(LOG_LEVEL_DEBUG, "OnPlayerDamage - " + attacker.GetClassname() + " - victim: " + victim.GetClassname() + " - damage: " + damageDone + " - DamageType: " + damageTable.DamageType);
	else
		Left4Fun.Log(LOG_LEVEL_DEBUG, "OnPlayerDamage - " + attacker.GetClassname() + " - damage: " + damageDone);
	*/
	
	if (damageDone <= 0 || victim == null)
		return damageDone;
	
	local vl = Left4Users.GetOnlineUserLevel(victim.GetPlayerUserId());
	if (vl < L4U_LEVEL.User)
		return damageDone * Left4Fun.Settings.troll_damagefactor;
	
	if (attacker != null && attacker.IsPlayer() && NetProps.GetPropInt(attacker, "m_iTeamNum") == TEAM_SPECTATORS)
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "Blocked bugged damage from spectator:");
		Left4Fun.PrintDamage(victim, attacker, damageDone, damageTable);
		
		return 0;
	}
	
	if (NetProps.GetPropInt(victim, "m_iTeamNum") == TEAM_SURVIVORS)
	{
		//if (Left4Fun.Settings.god_on_revive && victim.IsIncapacitated() && victim.IsGettingUp())  // the index 'IsGettingUp' does not exist (gg valve documentation)
		if (Left4Fun.Settings.god_on_revive && victim.IsIncapacitated() && NetProps.GetPropInt(victim, "m_reviveOwner") > 0)
			return 0; // God Mode when revived (this way you can revive without interruptions like the bots do)
		
		if (Left4Fun.Settings.godmode == ST_USER.ALL || (Left4Fun.Settings.godmode == ST_USER.ADMINS && vl >= L4U_LEVEL.Admin) || (Left4Fun.Settings.godmode == ST_USER.USERS && vl < L4U_LEVEL.Admin))
			return 0; // God Mode

		if ("Inflictor" in damageTable && damageTable.Inflictor && damageTable.Inflictor.GetName().find("SURVAB_NOFF_") != null && NetProps.GetPropInt(attacker, "m_iTeamNum") == NetProps.GetPropInt(victim, "m_iTeamNum"))
			return 0;

		if (SurvivorAbilities.IsImmuneToDamage(victim, damageTable.DamageType))
			return 0;
	}
	
	local nextHealth = (victim.GetHealth() + victim.GetHealthBuffer()) - damageDone;
	//Left4Fun.Log(LOG_LEVEL_DEBUG, "OnHurt - " + victim.GetPlayerName() + " - damage: " + damageDone + " - nextHealth: " + nextHealth);
	//Left4Fun.Log(LOG_LEVEL_DEBUG, "OnHurt - " + victim.GetPlayerName() + " - damage: " + damageDone + " - type: " + damageTable.DamageType + " - health: " + (victim.GetHealth() + victim.GetHealthBuffer()));
	
	if ((damageTable.DamageType & DMG_FALL) == 0 && (damageTable.DamageType & DMG_CRUSH) == 0 && (damageTable.DamageType & DMG_DROWN) == 0 && NetProps.GetPropInt(victim, "m_iTeamNum") == TEAM_SURVIVORS && victim.IsIncapacitated())
	{
		// Constant dmg type when incap: 131072 (DMG_POISON)
		// Dmg type with insta death: DMG_CRUSH, DMG_DROWN
		//Left4Fun.Log(LOG_LEVEL_DEBUG, "OnHurt - " + victim.GetPlayerName() + " - damage: " + damageDone + " - type: " + damageTable.DamageType + " - health: " + (victim.GetHealth() + victim.GetHealthBuffer()));
		
		if (nextHealth <= Left4Fun.L4FCvars.helpme_auto_health)
		{
			if (Left4Fun.L4FCvars.helpme == ST_USER.ALL || (Left4Fun.L4FCvars.helpme == ST_USER.ADMINS && vl >= L4U_LEVEL.Admin) || (Left4Fun.L4FCvars.helpme == ST_USER.USERS && vl < L4U_LEVEL.Admin))
 			{
				if (Left4Fun.SelfHelp(victim))
					return 0;
			}
		}
	}
	
	//Left4Fun.PrintDamage(victim, attacker, damageDone, damageTable);
	
	if (attacker == null || !attacker.IsPlayer() || victim.GetPlayerUserId() == attacker.GetPlayerUserId() || NetProps.GetPropInt(victim, "m_iTeamNum") != NetProps.GetPropInt(attacker, "m_iTeamNum"))
	{
		Left4Fun.NearIncapAdrenalineBoost(victim, nextHealth);
		return damageDone;
	}
 	
 	//Left4Fun.Log(LOG_LEVEL_DEBUG, "Friendly fire!");
 	
	if (IsPlayerABot(attacker))
		damageDone *= Left4Fun.Settings.bot_friendlyfire_damagefactor;
	
	nextHealth = (victim.GetHealth() + victim.GetHealthBuffer()) - damageDone;
	
	//Left4Fun.Log(LOG_LEVEL_DEBUG, "damageDone: " + damageDone);
	
	Left4Fun.NearIncapAdrenalineBoost(victim, nextHealth);
	return damageDone;
}

::Left4Fun.CanPickupObject <- function (object)
{
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun.CanPickupObject");
	
	return (Left4Fun.Settings.pickup_objects != 0);
}

HooksHub.SetCanPickupObject("L4F", ::Left4Fun.CanPickupObject);

// ---------------------------------------------

function SurvivorAbilities::Events::OnAbilityReady::AbilityReady (userid)
{
	if (!Left4Fun.L4FCvars.survivor_abilities_notifications)
		return;
	
	local player = g_MapScript.GetPlayerFromUserID(userid);
	if (player)
		Left4Fun.PrintToPlayerChat(player, "Your survivor ability is ready", PRINTCOLOR_GREEN);
}

function SurvivorAbilities::Events::OnAbilityUsedUp::AbilityUsedUp (userid, ability)
{
	if (!Left4Fun.L4FCvars.survivor_abilities_notifications)
		return;

	local player = g_MapScript.GetPlayerFromUserID(userid);
	if (player)
		Left4Fun.PrintToPlayerChat(player, "Ability used up", PRINTCOLOR_ORANGE);
}

function SurvivorAbilities::Events::OnAbilityExpired::AbilityExpired (userid, ability)
{
	if (!Left4Fun.L4FCvars.survivor_abilities_notifications)
		return;

	local player = g_MapScript.GetPlayerFromUserID(userid);
	if (player)
		Left4Fun.PrintToPlayerChat(player, "Ability expired", PRINTCOLOR_ORANGE);
}

// ---------------------------------------------

__CollectEventCallbacks(::Left4Fun.Events, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
