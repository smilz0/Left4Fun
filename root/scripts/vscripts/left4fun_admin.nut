//------------------------------------------------------
//     Author : smilzo
//     https://steamcommunity.com/id/smilz0
//------------------------------------------------------

Msg("Including left4fun_admin...\n");

//if (!("HandleAdminCommand" in ::Left4Fun))
//{
	::Left4Fun.HandleAdminCommand <- function (player, cmd, args)
	{
		switch (cmd)
		{
			case "kick":
			{
				Left4Fun.CMD_kick(player, args);
				break;
			}
			case "ban":
			{
				Left4Fun.CMD_ban(player, args);
				break;
			}
			case "incap":
			{
				Left4Fun.CMD_incap(player, args);
				break;
			}
			case "kill":
			{
				Left4Fun.CMD_kill(player, args);
				break;
			}
			case "respawn":
			{
				Left4Fun.CMD_respawn(player, args);
				break;
			}
			case "give":
			{
				Left4Fun.CMD_give(player, args);
				break;
			}
			case "remove":
			{
				Left4Fun.CMD_remove(player, args);
				break;
			}
			case "warp":
			{
				Left4Fun.CMD_warp(player, args);
				break;
			}
			case "cvar":
			{
				Left4Fun.CMD_cvar(player, args);
				break;
			}
			case "console":
			{
				Left4Fun.CMD_console(player, args);
				break;
			}
			case "director":
			{
				Left4Fun.CMD_director(player, args);
				break;
			}
			case "restart":
			{
				Left4Fun.CMD_restart(player, args);
				break;
			}
			case "prop":
			{
				Left4Fun.CMD_prop(player, args);
				break;
			}
			case "ignite":
			{
				Left4Fun.CMD_ignite(player, args);
				break;
			}
			case "extinguish":
			{
				Left4Fun.CMD_extinguish(player, args);
				break;
			}
			default:
				//Left4Fun.Log(LOG_LEVEL_DEBUG, "OnUserCommand - Invalid cmd: " + cmd);
				break;
		}
	}

	::Left4Fun.CMD_kick <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Utils.GetPlayerFromName(Left4Fun.GetArg(0, args));
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}

		if (IsPlayerABot(target) && NetProps.GetPropInt(target, "m_humanSpectatorUserID") > 0)
			target = g_MapScript.GetPlayerFromUserID(NetProps.GetPropInt(target, "m_humanSpectatorUserID"));
		
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid spectator", PRINTCOLOR_ORANGE);
			return;
		}
		
		if (Left4Fun.IsOnlineAdmin(target))
		{
			Left4Fun.PrintToPlayerChat(player, "Can't kick online admins", PRINTCOLOR_ORANGE);
			return;
		}
		
		local steamid = target.GetNetworkIDString();
		if (!steamid)
		{
			Left4Fun.PrintToPlayerChat(player, "Target has an invalid Steam ID", PRINTCOLOR_ORANGE);
			return;
		}
		
		local reason = Left4Fun.GetArg(1, args);
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_kick from " + player.GetPlayerName() + " - target: " + target.GetPlayerName() + " - reason: " + reason);
		
		if (reason && steamid != "BOT")
		{
			SendToServerConsole("kickid " + steamid + " " + reason);
			
			Left4Fun.ChatNotice(target.GetPlayerName() + " has been kicked with the reason: " + reason, PRINTCOLOR_ORANGE);
		}
		else
		{
			if (steamid == "BOT")
			{
				if (Left4Fun.IsExtraSurvivor(target))
					NetProps.SetPropInt(target, "m_iTeamNum", TEAM_L4D1_SURVIVORS);
					
				SendToServerConsole("kick " + target.GetPlayerName());
			}
			else
				SendToServerConsole("kickid " + steamid);
				
			Left4Fun.ChatNotice(target.GetPlayerName() + " has been kicked", PRINTCOLOR_ORANGE);
		}
	}

	::Left4Fun.CMD_ban <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Utils.GetPlayerFromName(Left4Fun.GetArg(0, args));
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}

		if (IsPlayerABot(target) && NetProps.GetPropInt(target, "m_humanSpectatorUserID") > 0)
			target = g_MapScript.GetPlayerFromUserID(NetProps.GetPropInt(target, "m_humanSpectatorUserID"));
		
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid spectator", PRINTCOLOR_ORANGE);
			return;
		}
		
		if (Left4Fun.IsOnlineAdmin(target))
		{
			Left4Fun.PrintToPlayerChat(player, "Can't ban online admins", PRINTCOLOR_ORANGE);
			return;
		}
		
		local steamid = target.GetNetworkIDString();
		if (!steamid)
		{
			Left4Fun.PrintToPlayerChat(player, "Target has an invalid Steam ID", PRINTCOLOR_ORANGE);
			return;
		}
		
		if (steamid == "BOT")
		{
			Left4Fun.PrintToPlayerChat(player, "Can't ban a BOT", PRINTCOLOR_ORANGE);
			return;
		}
		
		local reason = Left4Fun.GetArg(1, args);
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_ban from " + player.GetPlayerName() + " - target: " + target.GetPlayerName() + " - reason: " + reason);
		
		Left4Fun.Bans[steamid] <- target.GetPlayerName();
		Left4Utils.SaveAdminsToFile("left4fun/cfg/" + Left4Fun.BaseName + "_bans.txt", ::Left4Fun.Bans);
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Ban added for steamid: " + steamid);
		
		if (reason)
		{
			SendToServerConsole("kickid " + steamid + " " + reason);
			
			Left4Fun.ChatNotice(target.GetPlayerName() + " has been banned with the reason: " + reason, PRINTCOLOR_ORANGE);
		}
		else
		{
			SendToServerConsole("kickid " + steamid);
				
			Left4Fun.ChatNotice(target.GetPlayerName() + " has been banned", PRINTCOLOR_ORANGE);
		}
	}

	::Left4Fun.CMD_incap <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_incap from " + player.GetPlayerName() + " - target: " + target);
		
		local targetPlayers = Left4Fun.GetTargetPlayers(player, target, true);
		if (targetPlayers.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No players found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (targetPlayer in targetPlayers)
		{
			if (targetPlayer)
				Left4Utils.IncapacitatePlayer(targetPlayer);
		}
	}

	::Left4Fun.CMD_kill <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_kill from " + player.GetPlayerName() + " - target: " + target);
		
		local targetPlayers = Left4Fun.GetTargetPlayers(player, target);
		if (targetPlayers.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No players found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (targetPlayer in targetPlayers)
		{
			if (targetPlayer)
				Left4Utils.KillPlayer(targetPlayer);
		}
	}

	::Left4Fun.CMD_respawn <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;

		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		target = target.tolower();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_respawn from " + player.GetPlayerName() + " - target: " + target);
		
		if (target == "me")
			Left4Fun.RespawnDeadPlayer(player.GetPlayerUserId());
		else if (target == "all")
		{
			foreach (p in ::Left4Utils.GetDeadSurvivors())
				Left4Fun.RespawnDeadPlayer(p.GetPlayerUserId());
		}
		else if (target == "bots")
		{
			foreach (p in ::Left4Utils.GetDeadSurvivors())
			{
				if (IsPlayerABot(p))
					Left4Fun.RespawnDeadPlayer(p.GetPlayerUserId());
			}
		}
		else
		{
			local t = Left4Utils.GetPlayerFromName(target);
			if (t)
				Left4Fun.RespawnDeadPlayer(t.GetPlayerUserId());
			else
				Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_respawn - couldn't find player named: " + target);
		}
	}

	::Left4Fun.CMD_give <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		local item = Left4Fun.GetArg(1, args);
		
		if (!target || !item)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_give from " + player.GetPlayerName() + " - target: " + target + " - item: " + item);
		
		local targetPlayers = Left4Fun.GetTargetPlayers(player, target, true);
		if (targetPlayers.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No players found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		if (item == "melee")
			item = Left4Fun.MeleeWeapon[RandomInt(0, Left4Fun.MeleeWeapon.len() - 1)];
		else if (item == "tier1")
			item = Left4Fun.PrimaryWeaponLevel1[RandomInt(0, Left4Fun.PrimaryWeaponLevel1.len() - 1)];
		else if (item == "tier2")
			item = Left4Fun.PrimaryWeaponLevel2[RandomInt(0, Left4Fun.PrimaryWeaponLevel2.len() - 1)];
		
		foreach (targetPlayer in targetPlayers)
		{
			if (targetPlayer)
				targetPlayer.GiveItem(item);
		}
	}

	::Left4Fun.CMD_remove <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		local item = Left4Fun.GetArg(1, args);
		
		if (!target || !item)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_remove from " + player.GetPlayerName() + " - target: " + target + " - item: " + item);
		
		local targetPlayers = Left4Fun.GetTargetPlayers(player, target, true);
		if (targetPlayers.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No players found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		local slot = item.tolower();
		if (slot == "held" || slot == "slot0" || slot == "slot1" || slot == "slot2" || slot == "slot3" || slot == "slot4" || slot == "slot5")
		{
			//if (slot == "held")
			//	slot = "Held";
			foreach (targetPlayer in targetPlayers)
			{
				if (targetPlayer)
					Left4Utils.RemoveInventoryItemInSlot(targetPlayer, slot);
			}
		}
		else
		{
			foreach (targetPlayer in targetPlayers)
			{
				if (targetPlayer)
					Left4Utils.RemoveInventoryItem(targetPlayer, item);
			}
		}
	}

	::Left4Fun.CMD_warp <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_warp from " + player.GetPlayerName() + " - target: " + target);
		
		local targetPlayers = Left4Fun.GetTargetPlayers(player, target);
		if (targetPlayers.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No players found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		local destination = Left4Fun.GetArg(1, args);
		if (!destination)
			destination = "here";
		destination = destination.tolower();

		local location = null;
		if (destination == "here")
			location = Left4Utils.GetLookingPosition(player, TRACE_MASK_VISIBLE);
		else if (destination == "me")
			location = player.GetOrigin();
		else if (destination == "saferoom")
		{
			//location = Left4Fun.GetSaferoomLocation();
			//location = Left4Fun.GetSaferoomDoorLocation();
			
			if (Left4Fun.Locations["checkpointB"])
				location = Left4Fun.Locations["checkpointB"];
			else
				location = Left4Fun.GetSaferoomDoorLocation();
		}
		else if (destination == "start")
		{
			location = Left4Fun.Locations["checkpointA"];
		}
		else if (destination == "finale")
		{
			location = Left4Fun.Locations["finale"];
		}
		else if (destination == "rescue")
		{
			location = Left4Fun.Locations["rescueVehicle"];
		}
		else
		{
			local destPlayer = Left4Utils.GetPlayerFromName(destination);
			if (destPlayer != null)
				location = destPlayer.GetOrigin();
		}
		
		if (location == null)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid destination", PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (targetPlayer in targetPlayers)
		{
			if (targetPlayer)
				targetPlayer.SetOrigin(location);
		}
	}

	::Left4Fun.CMD_cvar <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local varName = Left4Fun.GetArg(0, args);
		local varValue = Left4Fun.GetArg(1, args);
		
		if (!varName)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_cvar from " + player.GetPlayerName() + " - varName: " + varName + " - varValue: " + varValue);
		
		if (varValue)
		{
			if (varName.find("l4f_") == 0)
				Left4Fun.SetL4FCvar(varName, varValue);
			else
				Convars.SetValue(varName, varValue);
		}
		else
		{
			if (varName.find("l4f_") == 0)
			{
				local val = Left4Fun.GetL4FCvar(varName);
				Left4Fun.Log(LOG_LEVEL_DEBUG, "L4FCVAR: " + varName + " = " + val);
				Left4Fun.PrintToPlayerChat(player, "L4FCVAR: " + varName + " = " + val, PRINTCOLOR_NORMAL);
			}
			else
			{
				local val = Convars.GetStr(varName);
				Left4Fun.Log(LOG_LEVEL_DEBUG, "CVAR: " + varName + " = " + val);
				Left4Fun.PrintToPlayerChat(player, "CVAR: " + varName + " = " + val, PRINTCOLOR_NORMAL);
			}
		}
	}

	::Left4Fun.CMD_console <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local command = "";
		for (local i = 0; i < args.len(); i++)
			command = command + args[i].tostring() + " ";
		if (!command || command == "")
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_console from " + player.GetPlayerName() + " - command: " + command);
		SendToServerConsole(command);
	}

	::Left4Fun.CMD_director <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local param = Left4Fun.GetArg(0, args);
		if (!param)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		param = param.tolower();
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_director from " + player.GetPlayerName() + " - param: " + param);
		
		if (param == "on")
		{
			Left4Utils.StartDirector();
			
			Left4Fun.Log(LOG_LEVEL_INFO, "Director started");
			Left4Fun.PrintToPlayerChat(player, "Director started", PRINTCOLOR_GREEN);
		}
		else if (param == "off")
		{
			Left4Utils.StopDirector();
			
			foreach(infectedPlayer in ::Left4Utils.GetAllInfected())
				Left4Utils.KillPlayer(infectedPlayer);
				
			Left4Fun.Log(LOG_LEVEL_INFO, "Director stopped");
			Left4Fun.PrintToPlayerChat(player, "Director stopped", PRINTCOLOR_GREEN);
		}
	}

	::Left4Fun.CMD_restart <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_restart from " + player.GetPlayerName());
		
		Left4Utils.RestartChapter();
	}

	// TODO: remove
	::Left4Fun.CMD_prop <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local location = Left4Utils.GetLookingPosition(player);

		local entClass = Left4Fun.GetArg(0, args);
		if (!entClass)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		local mdl = Left4Fun.GetArg(1, args);
		if (!mdl)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		local properties = Left4Fun.GetArg(2, args);
		if (!properties)
			properties = "";
		
		local x = Left4Fun.GetArg(3, args);
		if (!x)
			x = 0;
		else
			x = x.tofloat();
		local y = Left4Fun.GetArg(4, args);
		if (!y)
			y = 0;
		else
			y = y.tofloat();
		local z = Left4Fun.GetArg(5, args);
		if (!z)
			z = 0;
		else
			z = z.tofloat();
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_prop from " + player.GetPlayerName() + " - location: " + location + " - entClass: " + entClass + " - model: " + mdl + " - properties: " + properties + " - angles: (" + x + "," + y + "," + z + ")");
		
		Left4Utils.PrecacheModel(mdl);
		local ent = g_ModeScript.CreateSingleSimpleEntityFromTable({ classname = entClass, origin = location, angles = QAngle(x, y, z), model = mdl, overridescript = properties });
		if (!ent)
			Left4Fun.Log(LOG_LEVEL_DEBUG, "FAIL!");
		else
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "OK");
		}
		
		/*	
		Left4Utils.PrecacheModel("models/props_collectables/money_wad.mdl");
		Left4Utils.PrecacheModel("models/props_collectables/gold_bar.mdl");
		Left4Utils.PrecacheModel("models/props_collectables/coin.mdl");
		Left4Utils.PrecacheModel("models/props_collectables/backpack.mdl");
		Left4Utils.PrecacheModel("models/props_collectables/mushrooms.mdl");
		Left4Utils.PrecacheModel("models/props_collectables/piepan.mdl");
		Left4Utils.PrecacheModel("models/props_collectables/vault.mdl");
		*/
	}

	// TODO: remove
	::Left4Fun.CMD_ignite <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		local time = Left4Fun.GetArg(1, args);
		if (!time)
			time = 5.0;
		else
		  time = time.tofloat();
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_ignite from " + player.GetPlayerName() + " - target: " + target + " - time: " + time);
		
		local targets = Left4Fun.GetTargetPlayers(player, target, false);
		if (targets.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No entities found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (target in targets)
			DoEntFire("!self", "IgniteLifetime", time.tostring(), 0, null, target);
	}

	// TODO: remove
	::Left4Fun.CMD_extinguish <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_extinguish from " + player.GetPlayerName() + " - target: " + target);
		
		local targets = Left4Fun.GetTargetPlayers(player, target, false);
		if (targets.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No entities found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (target in targets)
		{
			if ("Extinguish" in target)
				target.Extinguish();
			else
				DoEntFire("!self", "IgniteLifetime", "0", 0, null, target);
		}
	}
//}
