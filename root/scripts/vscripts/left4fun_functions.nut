//------------------------------------------------------
//     Author : smilzo
//     https://steamcommunity.com/id/smilz0
//------------------------------------------------------

Msg("Including left4fun_functions...\n");

//if (!("IsAdmin" in ::Left4Fun))
//{
	::Left4Fun.DoAdminInit <- function (player)
	{
		if (!player)
			return;
			
		if (Left4Fun.Admins.len() > 0)
			return;
		
		local steamid = player.GetNetworkIDString();
		if (!steamid || steamid == "BOT")
			return;
		
		Left4Fun.Admins[steamid] <- player.GetPlayerName();
		Left4Utils.SaveAdminsToFile("left4fun/cfg/" + Left4Fun.BaseName + "_admins.txt", ::Left4Fun.Admins);
		
		Left4Fun.PrintToPlayerChat(player, "Admin added", PRINTCOLOR_GREEN);
		
		local userid = player.GetPlayerUserId();
		userid = userid.tointeger();
		if (Left4Fun.OnlineAdmins.find(userid) == null)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Adding admin with userid: " + userid);
		
			Left4Fun.OnlineAdmins.push(userid);
			Left4Fun.OnlineAdmins.sort();
			
			Left4Fun.PrintToPlayerChat(player, "You have been added to the online admins list", PRINTCOLOR_GREEN);
		}
	}

	::Left4Fun.IsAdmin <- function (player)
	{
		if (!player)
			return false;

		//if (Director.IsSinglePlayerGame() || GetListenServerHost() == player)
		if (GetListenServerHost() == player)
			return true;
		
		local steamid = player.GetNetworkIDString();
		if (!steamid)
			return false;

		if (!(steamid in ::Left4Fun.Admins))
			return false;
		
		return true;
	}

	::Left4Fun.IsAdminSteamID <- function (steamID)
	{
		if (!steamID)
			return false;

		if (!(steamID in ::Left4Fun.Admins))
			return false;
		
		return true;
	}

	::Left4Fun.IsBanned <- function (player)
	{
		if (!player)
			return false;

		if (GetListenServerHost() == player)
			return false;
		
		local steamid = player.GetNetworkIDString();
		if (!steamid)
			return false;

		if (steamid in ::Left4Fun.Bans)
			return true;
		
		return false;
	}

	::Left4Fun.GetArg <- function (index, args)
	{
		if (!args || args.len() <= index)
			return null;
		return args[index];
	}

	::Left4Fun.GetParam <- function (paramName, params)
	{
		if (!params || !paramName || !(paramName in params))
			return null;
		return params[paramName];
	}

	::Left4Fun.GetParamInt <- function (paramName, params)
	{
		local ret = Left4Fun.GetParam(paramName, params);
		if (ret == null)
			return null;
		return ret.tointeger();
	}

	::Left4Fun.GetParamFloat <- function (paramName, params)
	{
		local ret = Left4Fun.GetParam(paramName, params);
		if (ret == null)
			return null;
		return ret.tofloat();
	}

	::Left4Fun.GetParamBool <- function (paramName, params)
	{
		local ret = Left4Fun.GetParam(paramName, params);
		if (ret == null)
			return null;
		return (ret.tointeger() != 0);
	}

	::Left4Fun.GetParamPlayer <- function (paramName, params)
	{
		local userid = Left4Fun.GetParam(paramName, params);
		if (userid == null)
			return null;
		
		return g_MapScript.GetPlayerFromUserID(userid);
	}

	::Left4Fun.GetParamEntity <- function (paramName, params)
	{
		local index = Left4Fun.GetParam(paramName, params);
		if (index == null)
			return null;
		
		return EntIndexToHScript(index);
	}

	::Left4Fun.GetParamPlayerOrEntity <- function (playerParamName, entityParamName, params)
	{
		local ret = Left4Fun.GetParamPlayer(playerParamName, params);
		if (!ret)
			ret = Left4Fun.GetParamEntity(entityParamName, params);
		return ret;
	}

	::Left4Fun.IsInStartArea <- function (player)
	{
		local charName = Left4Utils.GetCharacterName(player);
		if (charName && charName != "")
		{
			if (!(charName in ::Left4Fun.PlayersInStartArea))
				return true;

			return Left4Fun.PlayersInStartArea[charName];
		}
		return false;
	}

	::Left4Fun.IsInSafeSpot <- function (player)
	{
		local charName = Left4Utils.GetCharacterName(player);
		if (charName && charName != "")
		{
			if (!(charName in ::Left4Fun.PlayersInSafeSpot))
				return true;

			return Left4Fun.PlayersInSafeSpot[charName];
		}
		return false;
	}

	::Left4Fun.AreAllSurvivorsInSafeSpot <- function ()
	{
		foreach (key, val in ::Left4Fun.PlayersInSafeSpot)
		{
			if (val == false)
				return false;
		}
		return true;
	}

	::Left4Fun.ClientPrint <- function (client, destination, text)
	{
		//ClientPrint(client, destination, text);
		Left4Timers.AddTimer(null, 0.1, @(params) ClientPrint(params.client, params.destination, params.text), { client = client, destination = destination, text = text }, false);
	}

	::Left4Fun.PrintToPlayerConsole <- function (player, text)
	{
		if (!player || !text)
			return;

		ClientPrint(player, 2, "[L4F] : " + text);
	}

	::Left4Fun.PrintToPlayerChat <- function (player, text, colorcode = PRINTCOLOR_NORMAL)
	{
		if (!player || !text)
			return;
		
		Left4Fun.ClientPrint(player, 3, colorcode + text);
	}

	::Left4Fun.DebugChatNotice <- function (text)
	{
		Left4Fun.ClientPrint(null, 3, "[DEBUG]: " + text);
	}

	::Left4Fun.ChatNotice <- function (text, colorcode = PRINTCOLOR_CYAN, forceShow = false)
	{
		if (!forceShow && !Left4Fun.L4FCvars.chat_notices)
			return;
		
		Left4Fun.ClientPrint(null, 3, colorcode + text);
	}

	::Left4Fun.AdminChatNotice <- function (level, text)
	{
		if (level < Left4Fun.Settings.admin_hints_level)
			return;
		
		local colorcode = PRINTCOLOR_NORMAL;
		if (level == ST_NOTICE.WARNING || level == ST_NOTICE.ALERT)
			colorcode = PRINTCOLOR_ORANGE;
		
		foreach (userid in Left4Fun.OnlineAdmins)
		{
			local player = g_MapScript.GetPlayerFromUserID(userid);
			if (player)
				Left4Fun.ClientPrint(player, 3, colorcode + text);
		}
	}

	::Left4Fun.UserHint <- function (player, text, color = HINTCOLOR_WHITE, icon = "icon_tip", duration = 5)
	{
		if (!Left4Fun.L4FCvars.user_hints || !player)
			return;
		
		//player.ShowHint(text, duration, icon, "", color, 0, 0, 0);
		
		local color2 = PRINTCOLOR_NORMAL;
		Left4Fun.ClientPrint(player, 3, color2 + text);
	}

	::Left4Fun.AdminHint <- function (level, text, duration = 5, addToConsole = false)
	{
		if (level < Left4Fun.Settings.admin_hints_level)
			return;
		
		local icon = "icon_info";
		local color = HINTCOLOR_WHITE;
		local color2 = PRINTCOLOR_NORMAL;
		if (level == ST_NOTICE.WARNING)
		{
			icon = "icon_alert";
			color = HINTCOLOR_YELLOW;
			color2 = PRINTCOLOR_ORANGE;
		}
		else if (level == ST_NOTICE.ALERT)
		{
			icon = "icon_alert_red";
			color = HINTCOLOR_RED;
			color2 = PRINTCOLOR_ORANGE;
		}
		
		foreach (userid in Left4Fun.OnlineAdmins)
		{
			local player = g_MapScript.GetPlayerFromUserID(userid);
			if (player)
			{
				//player.ShowHint(text, duration, icon, "", color, 0, 0, 0);
				Left4Fun.ClientPrint(player, 3, color2 + text);
				
				if (addToConsole)
					Left4Fun.PrintToPlayerConsole(player, text)
			}
		}
	}

	::Left4Fun.GetModFileToLoad <- function ()
	{
		if (!Left4Fun.Settings.mod || Left4Fun.Settings.mod == "none")
			return "";
			
		local modFileToLoad = "left4fun/mods/" + Left4Fun.Settings.mod + "_" + SessionState.ModeName + ".txt";
		local fileContent = FileToString(modFileToLoad);
		if (fileContent)
			return modFileToLoad;
		
		modFileToLoad = "left4fun/mods/" + Left4Fun.Settings.mod + "_all.txt";
		fileContent = FileToString(modFileToLoad);
		if (fileContent)
			return modFileToLoad;

		return null;
	}

	::Left4Fun.LoadStore <- function ()
	{
		local c = 0;
		local fileContents = FileToString("left4fun/cfg/" + Left4Fun.BaseName + "_store.txt");
		if (!fileContents)
			return c;
		
		local items = split(fileContents, "\r\n");
		foreach (item in items)
		{
			item = Left4Utils.StripComments(item);
			if (item != "")
			{
				local values = split(item, "=");
				if (values.len() != 2)
					Left4Fun.Log(LOG_LEVEL_WARN, "Invalid store line: " + item);
				else
				{
					local key = values[0];
					local value = values[1];
					
					if (!key || !value)
						Left4Fun.Log(LOG_LEVEL_WARN, "Invalid store line: " + item);
					else
					{
						key = strip(key);
						value = strip(value);
						
						if (key in Left4Fun.BuyItems_Spawn)
						{
							Left4Fun.BuyItems_Spawn[key] = value.tointeger();
							c++;
						}
						else if (key in Left4Fun.BuyItems_Give)
						{
							Left4Fun.BuyItems_Give[key].price = value.tointeger();
							c++;
						}
						else
							Left4Fun.Log(LOG_LEVEL_WARN, "Invalid store key: " + key);
					}
				}
			}
		}
		Left4Fun.Log(LOG_LEVEL_INFO, "Store loaded");
		
		return c;
	}

	::Left4Fun.SaveStore <- function ()
	{
		local fileContents = "";
		foreach(key, value in Left4Fun.BuyItems_Spawn)
		{
			if (fileContents == "")
				fileContents = key + " = " + value;
			else
				fileContents += "\n" + key + " = " + value;
		}
		foreach(key, value in Left4Fun.BuyItems_Give)
		{
			if (fileContents == "")
				fileContents = key + " = " + value.price;
			else
				fileContents += "\n" + key + " = " + value.price;
		}
		StringToFile("left4fun/cfg/" + Left4Fun.BaseName + "_store.txt", fileContents);
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Store saved");
	}

	::Left4Fun.LoadReplaceWithMoney <- function ()
	{
		local fileContents = FileToString("left4fun/money/pickupstoreplace.txt");
		if (!fileContents)
			return false;
		
		Left4Fun.ClassesToReplaceWithMoney <- {};
		
		local replacements = split(fileContents, "\r\n");
		foreach (replacement in replacements)
		{
			replacement = Left4Utils.StripComments(replacement);
			local values = split(replacement, "=");
			if (values.len() != 2)
				Left4Fun.Log(LOG_LEVEL_WARN, "Invalid ReplaceWithMoney line: " + replacement);
			else
			{
				local key = strip(values[0]);
				local value = strip(values[1]).tointeger();
				if (!key)
					Left4Fun.Log(LOG_LEVEL_WARN, "Invalid ReplaceWithMoney line: " + replacement);
				else
				{
					//Left4Fun.Log(LOG_LEVEL_DEBUG, "ClassesToReplaceWithMoney[" + key + "] = " + value);
					
					Left4Fun.ClassesToReplaceWithMoney[key] <- value;
				}
			}
		}
		Left4Fun.Log(LOG_LEVEL_INFO, "ReplaceWithMoney loaded");
		
		return true;
	}

	::Left4Fun.SaveReplaceWithMoney <- function ()
	{
		local fileContents = "";
		foreach(key, value in Left4Fun.ClassesToReplaceWithMoney)
		{
			if (fileContents == "")
				fileContents = key + " = " + value;
			else
				fileContents += "\n" + key + " = " + value;
		}
		StringToFile("left4fun/money/pickupstoreplace.txt", fileContents);
		
		Left4Fun.Log(LOG_LEVEL_INFO, "ReplaceWithMoney saved");
	}

	::Left4Fun.GetPlayer <- function (ent)
	{
		if (!ent || !ent.IsValid() || !ent.IsPlayer())
			return null;
		
		return ent;
	}

	::Left4Fun.GetSurvivor <- function (ent)
	{
		if (!ent || !ent.IsValid() || !ent.IsPlayer() || ent.GetZombieType() != Z_SURVIVOR)
			return null;
		
		return ent;
	}

	::Left4Fun.IsOnlineAdmin <- function (player)
	{
		if (!player || !player.IsValid())
			return false;
		
		if (Left4Fun.OnlineAdmins.find(player.GetPlayerUserId()) != null)
			return true;
		else
			return false;
	}

	::Left4Fun.IsOnlineTroll <- function (player)
	{
		if (!player || !player.IsValid())
			return false;
		
		if (Left4Fun.OnlineTrolls.find(player.GetPlayerUserId()) != null)
			return true;
		else
			return false;
	}

	::Left4Fun.IsTroll <- function (player)
	{
		if (!player || !player.IsValid())
			return false;

		local steamid = player.GetNetworkIDString();
		if (!steamid)
			return false;

		if (!(steamid in ::Left4Fun.Trolls))
			return false;
		
		return true;
	}

	::Left4Fun.IsTrollSteamID <- function (steamID)
	{
		if (!steamID)
			return false;

		if (!(steamID in ::Left4Fun.Trolls))
			return false;
		
		return true;
	}

	::Left4Fun.ST_User2String <- function (value)
	{
		switch (value)
		{
			case ST_USER.ALL:
			{
				return "all";
			}
			case ST_USER.USERS:
			{
				return "users";
			}
			case ST_USER.ADMINS:
			{
				return "admins";
			}
			default:
			{
				return "none";
			}
		}
	}

	::Left4Fun.String2ST_User <- function (value)
	{
		switch (value)
		{
			case "all":
			{
				return ST_USER.ALL;
			}
			case "users":
			{
				return ST_USER.USERS;
			}
			case "admins":
			{
				return ST_USER.ADMINS;
			}
			default:
			{
				return ST_USER.NONE;
			}
		}
	}

	::Left4Fun.ST_Notice2String <- function (value)
	{
		switch (value)
		{
			case ST_NOTICE.ALL:
			{
				return "all";
			}
			case ST_NOTICE.INFO:
			{
				return "info";
			}
			case ST_NOTICE.WARNING:
			{
				return "warning";
			}
			case ST_NOTICE.ALERT:
			{
				return "alert";
			}
			default:
			{
				return "none";
			}
		}
	}

	::Left4Fun.String2ST_Notice <- function (value)
	{
		switch (value)
		{
			case "all":
			{
				return ST_NOTICE.ALL;
			}
			case "info":
			{
				return ST_NOTICE.INFO;
			}
			case "warning":
			{
				return ST_NOTICE.WARNING;
			}
			case "alert":
			{
				return ST_NOTICE.ALERT;
			}
			default:
			{
				return ST_NOTICE.NONE;
			}
		}
	}

	::Left4Fun.CV_Supershovetype2String <- function (value)
	{
		switch (value)
		{
			case CV_SUPERSHOVETYPE.PUSH:
			{
				return "push";
			}
			default:
			{
				return "stagger";
			}
		}
	}

	::Left4Fun.String2CV_Supershovetype <- function (value)
	{
		switch (value)
		{
			case "push":
			{
				return CV_SUPERSHOVETYPE.PUSH;
			}
			default:
			{
				return CV_SUPERSHOVETYPE.STAGGER;
			}
		}
	}

	::Left4Fun.String2Bool <- function (value)
	{
		local v = value.tolower();
		if (v == "on" || v == "true" || v == "yes")
			return 1;
		else
			return 0;
	}

	::Left4Fun.Bool2String <- function (value)
	{
		if (value != 0)
			return "true";
	  else
		return "false";
	}

	::Left4Fun.ChangeSetting <- function (settingName, settingValue, player = null)
	{
		local currentValue = null;
		
		switch (settingName)
		{
			case "mod":
			{
				if (settingValue == "")
					currentValue = Left4Fun.Settings.mod;
				else
				{
					Left4Fun.Settings.mod = settingValue;
					
					local fileName = Left4Fun.GetModFileToLoad();
					if (fileName == null)
						Left4Fun.PrintToPlayerChat(player, "Warning: a mod file named '" + Left4Fun.Settings.mod + "_" + SessionState.ModeName + ".txt' or '" + Left4Fun.Settings.mod + "_all.txt' was not found. Are you sure the name is correct?", PRINTCOLOR_ORANGE);
				}
					
				break;
			}
			case "godmode":
			{
				if (settingValue == "")
					currentValue = ST_User2String(Left4Fun.Settings.godmode);
				else
					Left4Fun.Settings.godmode = Left4Fun.String2ST_User(settingValue);
					
				break;
			}
			case "god_on_revive":
			{
				if (settingValue == "")
					currentValue = Bool2String(Left4Fun.Settings.god_on_revive);
				else
					Left4Fun.Settings.god_on_revive = Left4Fun.String2Bool(settingValue);
					
				break;
			}
			case "admin_commands":
			{
				if (settingValue == "")
					currentValue = Bool2String(Left4Fun.Settings.admin_commands);
				else
					Left4Fun.Settings.admin_commands = Left4Fun.String2Bool(settingValue);
					
				break;
			}
			case "pickup_objects":
			{
				if (settingValue == "")
					currentValue = Bool2String(Left4Fun.Settings.pickup_objects);
				else
					Left4Fun.Settings.pickup_objects = Left4Fun.String2Bool(settingValue);
					
				break;
			}
			case "troll_damagefactor":
			{
				if (settingValue == "")
					currentValue = Left4Fun.Settings.troll_damagefactor;
				else
					Left4Fun.Settings.troll_damagefactor = settingValue.tofloat();
				
				break;
			}
			case "bot_friendlyfire_damagefactor":
			{
				if (settingValue == "")
					currentValue = Left4Fun.Settings.bot_friendlyfire_damagefactor;
				else
					Left4Fun.Settings.bot_friendlyfire_damagefactor = settingValue.tofloat();
				
				break;
			}
			case "always_win":
			{
				if (settingValue == "")
					currentValue = ST_User2String(Left4Fun.Settings.always_win);
				else
					Left4Fun.Settings.always_win = Left4Fun.String2ST_User(settingValue);
					
				break;
			}
			case "admin_hints_level":
			{
				if (settingValue == "")
					currentValue = ST_Notice2String(Left4Fun.Settings.admin_hints_level);
				else
					Left4Fun.Settings.admin_hints_level = Left4Fun.String2ST_Notice(settingValue);
					
				break;
			}
			case "reload_fix":
			{
				if (settingValue == "")
					currentValue = Bool2String(Left4Fun.Settings.reload_fix);
				else
					Left4Fun.Settings.reload_fix = Left4Fun.String2Bool(settingValue);
					
				break;
			}
			case "m60_fix":
			{
				if (settingValue == "")
					currentValue = Bool2String(Left4Fun.Settings.m60_fix);
				else
					Left4Fun.Settings.m60_fix = Left4Fun.String2Bool(settingValue);
					
				break;
			}
			case "loglevel":
			{
				if (settingValue == "")
					currentValue = Left4Fun.Settings.loglevel;
				else
					Left4Fun.Settings.loglevel = settingValue.tointeger();
				
				break;
			}
			case "dump":
			{
				Left4Fun.PrintToPlayerChat(player, "[Settings] mod = " + Left4Fun.Settings.mod, PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "[Settings] godmode = " + ST_User2String(Left4Fun.Settings.godmode), PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "[Settings] god_on_revive = " + Bool2String(Left4Fun.Settings.god_on_revive), PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "[Settings] troll_damagefactor = " + Left4Fun.Settings.troll_damagefactor, PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "[Settings] bot_friendlyfire_damagefactor = " + Left4Fun.Settings.bot_friendlyfire_damagefactor, PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "[Settings] always_win = " + ST_User2String(Left4Fun.Settings.always_win), PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "[Settings] admin_hints_level = " + ST_Notice2String(Left4Fun.Settings.admin_hints_level), PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "[Settings] admin_commands = " + Bool2String(Left4Fun.Settings.admin_commands), PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "[Settings] pickup_objects = " + Bool2String(Left4Fun.Settings.pickup_objects), PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "[Settings] reload_fix = " + Bool2String(Left4Fun.Settings.reload_fix), PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "[Settings] m60_fix = " + Bool2String(Left4Fun.Settings.m60_fix), PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "[Settings] loglevel = " + Left4Fun.Settings.loglevel, PRINTCOLOR_NORMAL);
				
				// ...
				
				return;
			}
			default:
			{
				Left4Fun.PrintToPlayerChat(player, "Invalid setting: " + settingName, PRINTCOLOR_ORANGE);
				return;
			}
		}
		
		if (currentValue == null)
		{
			Left4Fun.PrintToPlayerChat(player, "[Settings] " + settingName + " changed to: " + settingValue, PRINTCOLOR_GREEN);
			Left4Utils.SaveSettingsToFile("left4fun/cfg/" + Left4Fun.BaseName + "_settings.txt", ::Left4Fun.Settings, Left4Fun.Log);
		}
		else
			Left4Fun.PrintToPlayerChat(player, "[Settings] " + settingName + " = " + currentValue, PRINTCOLOR_NORMAL);
	}

	::Left4Fun.MyConvertZombieClass <- function (iClass)
	{
		local c = "z_" + iClass;
		if (c in Left4Fun.ZombiesToConvert)
		{
			local val = Left4Fun.ZombiesToConvert[c];
		
			//Left4Fun.Log(LOG_LEVEL_DEBUG, "MyConvertZombieClass - ZombiesToConvert[" + iClass + "] = " + val);
			
			return val.tointeger();
		}
		else
		{
			//Left4Fun.Log(LOG_LEVEL_DEBUG, "MyConvertZombieClass - ZombiesToConvert[" + iClass + "] is null!!!");
			
			return iClass;
		}
	}

	::Left4Fun.GetTargetPlayers <- function (player, targetName, survivorsOnly = false)
	{
		local targetArray = [];
		
		if (targetName == null)
			return targetArray;
		
		local target = targetName.tolower();
		if (target == "me")
		{
			if (player != null && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
				targetArray.push(player);
		}
		else if (target == "all")
		{
			foreach(survivor in ::Left4Utils.GetAliveSurvivors())
				targetArray.push(survivor);
		}
		else if (target == "others")
		{
			foreach(survivor in ::Left4Utils.GetOtherAliveSurvivors(player))
				targetArray.push(survivor);
		}
		else if (target == "bots")
		{
			foreach(survivor in ::Left4Utils.GetAliveSurvivorBots())
				targetArray.push(survivor);
		}
		else if (target == "boomer" && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
		{
			foreach(boomer in ::Left4Utils.GetAlivePlayersByType(Z_BOOMER))
				targetArray.push(boomer);
		}
		else if (target == "charger" && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
		{
			foreach(charger in ::Left4Utils.GetAlivePlayersByType(Z_CHARGER))
				targetArray.push(charger);
		}
		else if (target == "hunter" && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
		{
			foreach(hunter in ::Left4Utils.GetAlivePlayersByType(Z_HUNTER))
				targetArray.push(hunter);
		}
		else if (target == "jockey" && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
		{
			foreach(jockey in ::Left4Utils.GetAlivePlayersByType(Z_JOCKEY))
				targetArray.push(jockey);
		}
		else if (target == "smoker" && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
		{
			foreach(smoker in ::Left4Utils.GetAlivePlayersByType(Z_SMOKER))
				targetArray.push(smoker);
		}
		else if (target == "spitter" && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
		{
			foreach(spitter in ::Left4Utils.GetAlivePlayersByType(Z_SPITTER))
				targetArray.push(spitter);
		}
		else if (target == "tank" && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
		{
			foreach(tank in ::Left4Utils.GetAlivePlayersByType(Z_TANK))
				targetArray.push(tank);
		}
		else if (target == "witch" && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
		{
			local ent = null;
			while (ent = Entities.FindByClassname(ent, "witch"))
			{
				if (ent.IsValid())
					targetArray.push(ent);
			}
		}
		else if (target == "special" && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
		{
			foreach(special in ::Left4Utils.GetAllPlayers(TEAM_INFECTED))
				targetArray.push(special);
		}
		else if (target == "common" && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
		{
			local ent = null;
			while (ent = Entities.FindByClassname(ent, "infected"))
			{
				if (ent.IsValid())
					targetArray.push(ent);
			}
		}
		else if (target == "infected" && (!survivorsOnly || NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS))
		{
			foreach(infected in ::Left4Utils.GetAllInfected())
				targetArray.push(infected);
		}
		else
		{
			local t = Left4Utils.GetPlayerFromName(targetName);
			if (t != null && (!survivorsOnly || NetProps.GetPropInt(t, "m_iTeamNum") == TEAM_SURVIVORS))
				targetArray.push(t);
		}
		
		return targetArray;
	}

	::Left4Fun.LoadDirectorVars <- function ()
	{
		foreach (key, val in Left4Fun.DirectorVarsToLoad)
		{
			try
			{
				local compiledscript = compilestring("DirectorScript.GetDirectorOptions()." + key + " <- " + val);
				compiledscript();
			}
			catch(exception)
			{
				Left4Fun.Log(LOG_LEVEL_ERROR, "LoadDirectorVars - Exception: " + exception);
			}
		}
		Left4Fun.DirectorVar = null;
	}

	::Left4Fun.HelpPlayer <- function (player)
	{
		if (!player || !player.IsValid() || !("IsPlayer" in player) || !player.IsPlayer())
			return;
		
		local attacker = Left4Utils.GetCurrentAttacker(player);
		if (attacker)
		{
			//attacker.Stagger(player.GetOrigin());
			Left4Utils.KillPlayer(attacker, DMG_MELEE, player);
		}
		
		if (player.IsDead() || player.IsDying())
			player.ReviveByDefib();
		else if (player.IsHangingFromLedge())
			player.ReviveFromIncap();
		else if (player.IsIncapacitated())
		{
			player.ReviveFromIncap();
			player.SetHealthBuffer(130);
		}
	}

	::Left4Fun.SelfHelp <- function (player)
	{
		if (!player.IsIncapacitated() && !player.IsHangingFromLedge())
			return false;
	   
		if (Left4Utils.HasItem(player, "weapon_adrenaline"))
		{
			Left4Utils.RemoveItem(player, "weapon_adrenaline");
			
			Left4Fun.ChatNotice(player.GetPlayerName() + " self helped using his adrenaline");
		}
		else if (Left4Utils.HasItem(player, "weapon_pain_pills"))
		{
			Left4Utils.RemoveItem(player, "weapon_pain_pills");
			
			Left4Fun.ChatNotice(player.GetPlayerName() + " self helped using his pain pills");
		}
		else if (Left4Utils.HasItem(player, "weapon_first_aid_kit"))
		{
			Left4Utils.RemoveItem(player, "weapon_first_aid_kit");
			
			Left4Fun.ChatNotice(player.GetPlayerName() + " self helped using his first aid kit");
		}
		else
			return false;
		
		Left4Fun.HelpPlayer(player);
		
		return true;
	}

	::Left4Fun.RespawnDeadPlayer <- function (deadPlayerID)
	{ 	
		local deadPlayer = g_MapScript.GetPlayerFromUserID(deadPlayerID);
		if (!deadPlayer || !deadPlayer.IsValid())
		{
			Left4Fun.Log(LOG_LEVEL_ERROR, "RespawnDeadPlayer - couldn't find player with id: " + deadPlayerID);
			return;
		}

		local characterName = deadPlayer.GetPlayerName();
		
		if (!deadPlayer.IsDead() && !deadPlayer.IsDying())
		{
			Left4Fun.Log(LOG_LEVEL_WARN, "RespawnDeadPlayer - " + characterName + " is not dead!");
			
			return;
		}
		
		local surv = Left4Utils.GetAnyAliveSurvivor();
		if (surv)
		{
			deadPlayer.ReviveByDefib();
			
			if (deadPlayer.IsDead() || deadPlayer.IsDying())
			{
				local isr = g_ModeScript.CreateSingleSimpleEntityFromTable({ classname = "info_survivor_rescue", origin = surv.GetOrigin(), angles = QAngle(0, 0, 0) });
				NetProps.SetPropEntity(isr, "m_survivor", deadPlayer);
				
				DoEntFire("!self", "Rescue", "", 0.1, null, isr);
				DoEntFire("!self", "Kill", "", 0.5, null, isr);
				
				Left4Fun.ChatNotice(characterName + " respawned");
			}
			else
			{
				deadPlayer.SetOrigin(surv.GetOrigin());
			
				Left4Fun.ChatNotice(characterName + " respawned");
			}
		}
		else
			Left4Fun.Log(LOG_LEVEL_INFO, "Can't respawn player because there is no other survivor alive");
	}

	::Left4Fun.CleanExtraSurvivors <- function ()
	{
		local survivorSet = Director.GetSurvivorSet();
		foreach (s in ::Left4Utils.GetAllSurvivors(0))
		{
			local c = NetProps.GetPropInt(s, "m_survivorCharacter");
			if (c >= 4 && survivorSet == 2 && NetProps.GetPropInt(s, "m_iAccount") == 1)
			{
				if (NetProps.GetPropInt(s, "m_iTeamNum") != TEAM_L4D1_SURVIVORS)
				{
					Left4Fun.Log(LOG_LEVEL_DEBUG, "Setting extra survivor " + s.GetPlayerName() + "'s team to TEAM_L4D1_SURVIVORS");
					NetProps.SetPropInt(s, "m_iTeamNum", TEAM_L4D1_SURVIVORS);
				}
				
				Left4Fun.Log(LOG_LEVEL_DEBUG, "Kicking extra survivor " + s.GetPlayerName());
				SendToServerConsole("kick " + s.GetPlayerName());
			}
			else if (c < 4 && NetProps.GetPropInt(s, "m_iTeamNum") != TEAM_SURVIVORS)
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "Setting survivor " + s.GetPlayerName() + "'s team to TEAM_SURVIVORS");
				NetProps.SetPropInt(s, "m_iTeamNum", TEAM_SURVIVORS);
			}
		}
	}

	::Left4Fun.RestoreExtraSurvivors <- function ()
	{
		/* TODO
		local survivorSet = Director.GetSurvivorSet();
		if (survivorSet == 2 && SessionState.MapName.tolower().find("c6m") == null)
		{
			local e = null;
			while (e = Entities.FindByClassname(e, "player"))
			{
				if (e.IsValid())
				{
					if (NetProps.GetPropInt(e, "m_iTeamNum") == TEAM_L4D1_SURVIVORS)
					{
						Left4Fun.Log(LOG_LEVEL_DEBUG, "Switching extra survivor " + e.GetPlayerName() + " from TEAM_L4D1_SURVIVORS to TEAM_SURVIVORS");
						NetProps.SetPropInt(s, "m_iTeamNum", TEAM_SURVIVORS);
						//e.SetHealth(100);
						e.Respawn();
						// TODO ?
					}
				}
			}
		}
		*/
	}

	::Left4Fun.LoadBank <- function ()
	{
		try
		{
			Left4Fun.Bank = Left4Utils.LoadTable("left4fun/data/" + Left4Fun.BaseName + "_bank.dat");
		}
		catch (ex)
		{
			Left4Fun.Bank = null;
			Left4Fun.Log(LOG_LEVEL_ERROR, "LoadBank - Failed to load bank file: " + ex);
		}
		if (!Left4Fun.Bank)
			Left4Fun.Bank = {};
		
		Left4Fun.BankBackup = g_ModeScript.DuplicateTable(Left4Fun.Bank);
		
		Left4Utils.SaveTable({}, "left4fun/data/" + Left4Fun.BaseName + "_bank.dat");
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Bank loaded");
	}

	::Left4Fun.SaveBank <- function ()
	{
		Left4Utils.SaveTable(Left4Fun.Bank, "left4fun/data/" + Left4Fun.BaseName + "_bank.dat");
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Bank saved");
	}

	::Left4Fun.BankAccountName <- function (player)
	{
		if (Left4Utils.GetType(player) != Z_SURVIVOR)
		{
			Left4Fun.Log(LOG_LEVEL_WARN, "BankAccountName - not survivor: " + Left4Utils.GetType(player));
			return null;
		}
		
		local ret = Left4Utils.GetCharacterName(player);
		if (ret == "")
			ret = null;
		
		if (!ret)
		{
			if ("IsPlayer" in player)
				Left4Fun.Log(LOG_LEVEL_DEBUG, "BankAccountName - IsPlayer in player: " + player.IsPlayer());
			else
				Left4Fun.Log(LOG_LEVEL_DEBUG, "BankAccountName - IsPlayer not in player!");
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "BankAccountName - DispName: " + g_MapScript.GetCharacterDisplayName(player));
		}
		
		return ret;
	}

	::Left4Fun.InitBankAccount <- function (player)
	{
		local accName = Left4Fun.BankAccountName(player);
		if (!accName || accName in Left4Fun.Bank)
			return accName;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "Initializing bank account: " + accName);
		
		Left4Fun.Bank[accName] <- { money = 0, gifts = 0 };
		
		return accName;
	}

	::Left4Fun.GetBankItemAmount <- function (player, itemName)
	{
		local accName = Left4Fun.InitBankAccount(player);
		if (!accName)
			return -1;
		
		return Left4Fun.Bank[accName][itemName].tointeger();
	}

	::Left4Fun.SetBankItemAmount <- function (player, itemName, amount)
	{
		local accName = Left4Fun.InitBankAccount(player);
		if (!accName)
			return -1;
		
		Left4Fun.Bank[accName][itemName] = amount;
	}

	::Left4Fun.AddBankItemAmount <- function (player, itemName, amount)
	{
		local accName = Left4Fun.InitBankAccount(player);
		if (!accName)
			return -1;
		
		Left4Fun.Bank[accName][itemName] += amount;
		
		if (itemName == "money")
			Left4Fun.MoneyEarned += amount;
	}

	::Left4Fun.SubBankItemAmount <- function (player, itemName, amount)
	{
		local accName = Left4Fun.InitBankAccount(player);
		if (!accName)
			return -1;
		
		Left4Fun.Bank[accName][itemName] -= amount;
		
		if (itemName == "money")
			Left4Fun.MoneySpent += amount;
	}

	::Left4Fun.LoadGunGameConfig <- function (mapname)
	{
		// TODO
	}

	::Left4Fun.SaveGunGameConfig <- function (mapname)
	{
		Left4Utils.SaveTable(Left4Fun.GunGameConfig, "left4fun/gungame/" + mapname + ".dat");
		
		Left4Fun.Log(LOG_LEVEL_INFO, "GunGame config saved");
	}

	::Left4Fun.LoadZombieDropsConfig <- function (mapname)
	{
		Left4Fun.ZombieDropsConfig = { };
		
		local c = 0;
		local fileContents = FileToString("left4fun/zombiedrops/" + mapname + ".txt");
		if (!fileContents)
		{
			Left4Fun.Log(LOG_LEVEL_INFO, "ZombieDrops config not found, creating new one");
		
			fileContents = "// common\n"
						 + "common,3,0,melee,pistol_magnum\n"
						 + "common,1,0,pistol\n"
						 + "common,5,0,molotov,pipe_bomb,vomitjar\n"
						 + "// special\n"
						 + "special,50,35,tier1\n"
						 + "special,50,35,tier2\n"
						 + "special,50,0,pain_pills,adrenaline\n"
						 + "special,15,0,first_aid_kit\n"
						 + "// witch\n"
						 + "witch,90,35,tier2\n"
						 + "witch,80,35,tier2,chainsaw,grenade_launcher,rifle_m60\n"
						 + "witch,90,0,first_aid_kit,defibrillator\n"
						 + "// tank\n"
						 + "tank,100,45,tier2\n"
						 + "tank,100,45,tier2\n"
						 + "tank,50,45,tier2\n"
						 + "tank,90,45,chainsaw,grenade_launcher,rifle_m60\n"
						 + "tank,100,0,first_aid_kit\n"
						 + "tank,90,0,first_aid_kit\n"
						 + "tank,90,0,first_aid_kit,defibrillator\n"
						 + "tank,80,0,first_aid_kit\n";
			
			StringToFile("left4fun/zombiedrops/" + mapname + ".txt", fileContents);
		
			Left4Fun.Log(LOG_LEVEL_INFO, "ZombieDrops config saved");
			
			//Left4Fun.SaveZombieDropsConfig(mapname);
		}
		
		local items = split(fileContents, "\r\n");
		foreach (item in items)
		{
			item = Left4Utils.StripComments(item);
			if (item != "")
			{
				local values = split(item, ",");
				if (values.len() < 4)
					Left4Fun.Log(LOG_LEVEL_WARN, "Invalid ZombieDrops line: " + item);
				else
				{
					local key = strip(values[0]);
					if (!key)
						Left4Fun.Log(LOG_LEVEL_WARN, "Invalid ZombieDrops line: " + item);
					else
					{
						if (!(key in Left4Fun.ZombieDropsConfig))
							Left4Fun.ZombieDropsConfig[key] <- [ ];
					
						local conf = { };
						conf.Chance <- strip(values[1]).tofloat();
						conf.LaserSightChance <- strip(values[2]).tofloat();
						conf.Items <- [ ];
						
						local i = 3;
						while (i < values.len())
						{
							conf.Items.push(strip(values[i]));
							i++;
						}
						
						Left4Fun.ZombieDropsConfig[key].push(conf);
						
						c++;
					}
				}
			}
		}
		return c;
	}

	::Left4Fun.BuildZombieDropsConfig <- function (fileContents, key)
	{
		foreach(conf in Left4Fun.ZombieDropsConfig[key])
		{
			fileContents += key + "," + conf.Chance + "," + conf.LaserSightChance;
			foreach (item in conf.Items)
				fileContents += "," + item;
			fileContents += "\n";
		}
		return fileContents;
	}

	::Left4Fun.SaveZombieDropsConfig <- function (mapname)
	{
		local fileContents = "// common\n";
		fileContents = Left4Fun.BuildZombieDropsConfig(fileContents, "common");
		fileContents += "// special\n";
		fileContents = Left4Fun.BuildZombieDropsConfig(fileContents, "special");
		fileContents += "// witch\n";
		fileContents = Left4Fun.BuildZombieDropsConfig(fileContents, "witch");
		fileContents += "// tank\n";
		fileContents = Left4Fun.BuildZombieDropsConfig(fileContents, "tank");
		
		StringToFile("left4fun/zombiedrops/" + mapname + ".txt", fileContents);
		
		Left4Fun.Log(LOG_LEVEL_INFO, "ZombieDrops config saved");
	}

	::Left4Fun.ConvertZombieDropsConfigs <- function (mapname)
	{
		Left4Fun.ZombieDropsConfig = Left4Utils.LoadTable("left4fun/zombiedrops/" + mapname + ".dat");
		Left4Fun.SaveZombieDropsConfig(mapname);
	}

	::Left4Fun.DropZombieDropsItem <- function (zombie_class, attacker, victim)
	{
		if (!Left4Fun.L4FCvars.zombiedrops)
			return;
		
		if (!(zombie_class in Left4Fun.ZombieDropsConfig))
			return;
		
		if(Left4Fun.L4FCvars.zombiedrops_onplayer && attacker != null && attacker.IsPlayer())
			Left4Timers.AddTimer("DelayedDropZombieDropsItem_" + UniqueString(), 0.7, Left4Fun.DelayedDropZombieDropsItem, { zombie_class = zombie_class, location = attacker.GetOrigin() + Vector(0, 0, 50) + (attacker.GetForwardVector() * 50), angles = attacker.GetAngles() }, false);
		else
			Left4Timers.AddTimer("DelayedDropZombieDropsItem_" + UniqueString(), 0.7, Left4Fun.DelayedDropZombieDropsItem, { zombie_class = zombie_class, location = victim.GetOrigin() + Vector(0, 0, 50), angles = victim.GetAngles() }, false);
	}

	::Left4Fun.DelayedDropZombieDropsItem <- function (args)
	{
		if (!("zombie_class" in args) || !("location" in args) || !("angles" in args))
			return;
			
		local zombie_class = args["zombie_class"];
		local location = args["location"];
		local angles = args["angles"];
		
		foreach (entry in Left4Fun.ZombieDropsConfig[zombie_class])
		{
			local is_melee = false;
			local item = entry.Items[RandomInt(0, entry.Items.len() - 1)];
			if (RandomInt(1, 100) <= entry.Chance)
			{
				if (item == "melee")
				{
					item = Left4Fun.MeleeWeapon[RandomInt(0, Left4Fun.MeleeWeapon.len() - 1)];
					is_melee = true;
				}
				else if (item == "tier1")
					item = Left4Fun.PrimaryWeaponLevel1[RandomInt(0, Left4Fun.PrimaryWeaponLevel1.len() - 1)];
				else if (item == "tier2")
					item = Left4Fun.PrimaryWeaponLevel2[RandomInt(0, Left4Fun.PrimaryWeaponLevel2.len() - 1)];
				
				local wep = null;
				if (is_melee)
					wep = Left4Utils.SpawnWeapon("weapon_melee_spawn", location, angles, 1, 999, 1, { melee_weapon = item });
				else
					wep = Left4Utils.SpawnWeapon(item, location, angles);
					
				if (RandomInt(1, 100) <= entry.LaserSightChance)
				{
					local bits = NetProps.GetPropInt(wep, "m_upgradeBitVec");
					NetProps.SetPropInt(wep, "m_upgradeBitVec", bits | 4);
				}
			}
		}
	}

	::Left4Fun.GiveGunGameItem <- function (zombie_class, player)
	{
		local players = { };
		if (zombie_class == "tank")
			players = ::Left4Utils.GetAliveSurvivors();
		else
			players["0"] <- player;
		
		foreach (player in players)
		{
			foreach (entry in Left4Fun.ZombieDropsConfig[zombie_class])
			{
				local item = entry.Items[RandomInt(0, entry.Items.len() - 1)];
				if (RandomInt(1, 100) <= entry.Chance)
				{
					if (item == "melee")
						item = Left4Fun.MeleeWeapon[RandomInt(0, Left4Fun.MeleeWeapon.len() - 1)];
					else if (item == "tier1")
						item = Left4Fun.PrimaryWeaponLevel1[RandomInt(0, Left4Fun.PrimaryWeaponLevel1.len() - 1)];
					else if (item == "tier2")
						item = Left4Fun.PrimaryWeaponLevel2[RandomInt(0, Left4Fun.PrimaryWeaponLevel2.len() - 1)];
					
					Left4Fun.Log(LOG_LEVEL_DEBUG, "GiveGunGameItem - Giving zombiedrops item: " + item + " to: " + player.GetPlayerName());
					
					player.GiveItem(item);
					if (RandomInt(1, 100) <= entry.LaserSightChance)
					{
						Left4Fun.Log(LOG_LEVEL_DEBUG, "GiveGunGameItem - Setting laser sight upgrade");
						
						player.GiveUpgrade(UPGRADE_LASER_SIGHT);
					}
				}
			}
		}
	}

	// Checks if a certain entity is a ammo/weapon spawn for the L4D1 survivors in The Passing finale based on it's class name / location
	::Left4Fun.IsThePassingFinaleL4D1Item <- function (entclass, entloc)
	{
		if (Director.GetMapName() != "c6m3_port")
			return false;

		local l4d1Items = [
			{ entclass = "weapon_ammo_spawn", entloc = Vector(224.000000, -456.000000, 185.156250) },
			{ entclass = "weapon_ammo_spawn", entloc = Vector(280.000000, -1040.000000, 414.156250) },
			{ entclass = "weapon_rifle_spawn", entloc = Vector(288.000000, -1072.000000, 416.000000) },
			{ entclass = "weapon_rifle_ak47_spawn", entloc = Vector(368.000000, -520.000000, 161.968750) },
			{ entclass = "weapon_sniper_military_spawn", entloc = Vector(368.000000, -576.000000, 161.687500) }
		];

		foreach (i in l4d1Items)
		{
			if (i.entclass == entclass && (i.entloc - entloc).Length() <= 5)
				return true;
		}
		
		return false;
	}

	::Left4Fun.Sanitize <- function (weapons = true, weapon_spawns = true, utils = true, util_spawns = true, meds = true, med_spawns = true, health_cabinets = true, upgrades = true, upgrade_spawns = true, extras = true, extra_spawns = true, ammo = true)
	{
		if (weapons)
		{
			local weaponsToRemove =
			{
				weapon_melee = 0
				weapon_chainsaw = 0
				weapon_pistol = 0
				weapon_pistol_magnum = 0
				weapon_smg = 0
				weapon_smg_silenced = 0
				weapon_smg_mp5 = 0
				weapon_pumpshotgun = 0
				weapon_shotgun_chrome = 0
				weapon_rifle = 0
				weapon_rifle_desert = 0
				weapon_rifle_ak47 = 0
				weapon_rifle_sg552 = 0
				weapon_autoshotgun = 0
				weapon_shotgun_spas = 0		
				weapon_hunting_rifle = 0
				weapon_sniper_military = 0
				weapon_sniper_awp = 0
				weapon_sniper_scout = 0
				weapon_rifle_m60 = 0
				weapon_grenade_launcher = 0
				//weapon_item = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing weapons...");
			foreach (entclass, v in weaponsToRemove)
			{
				local ent = null;
				while (ent = Entities.FindByClassname(ent, entclass))
				{
					if (ent.GetOwnerEntity() == null)
						DoEntFire("!self", "Kill", "", 0, null, ent);
				}
			}
		}
		
		if (weapon_spawns)
		{
			local weaponSpawnsToRemove =
			{
				weapon_spawn = 0
				weapon_melee_spawn = 0
				weapon_chainsaw_spawn = 0
				weapon_pistol_spawn = 0
				weapon_pistol_magnum_spawn = 0
				weapon_smg_spawn = 0
				weapon_smg_silenced_spawn = 0
				weapon_smg_mp5_spawn = 0
				weapon_pumpshotgun_spawn = 0
				weapon_shotgun_chrome_spawn = 0
				weapon_rifle_spawn = 0
				weapon_rifle_desert_spawn = 0
				weapon_rifle_ak47_spawn = 0
				weapon_rifle_sg552_spawn = 0
				weapon_autoshotgun_spawn = 0
				weapon_shotgun_spas_spawn = 0		
				weapon_hunting_rifle_spawn = 0
				weapon_sniper_military_spawn = 0
				weapon_sniper_awp_spawn = 0
				weapon_sniper_scout_spawn = 0
				weapon_rifle_m60_spawn = 0
				weapon_grenade_launcher_spawn = 0
				//weapon_item_spawn = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing weapon spawns...");
			foreach (entclass, v in weaponSpawnsToRemove)
			{
				local ent = null;
				while (ent = Entities.FindByClassname(ent, entclass))
				{
					if (Left4Fun.IsThePassingFinaleL4D1Item(entclass, ent.GetOrigin()))
						Left4Fun.Log(LOG_LEVEL_DEBUG, "ignoring The Passing finale L4D1 " + entclass);
					else
						DoEntFire("!self", "Kill", "", 0, null, ent);
				}
			}
		}
		
		if (utils)
		{
			local utilsToRemove =
			{
				weapon_molotov = 0
				weapon_pipe_bomb = 0
				weapon_vomitjar = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing utils...");
			foreach (entclass, v in utilsToRemove)
			{
				local ent = null;
				while (ent = Entities.FindByClassname(ent, entclass))
				{
					if (ent.GetOwnerEntity() == null)
						DoEntFire("!self", "Kill", "", 0, null, ent);
				}
			}
		}
		
		if (util_spawns)
		{
			local utilSpawnsToRemove =
			{
				weapon_molotov_spawn = 0
				weapon_pipe_bomb_spawn = 0
				weapon_vomitjar_spawn = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing util spawns...");
			foreach (entclass, v in utilSpawnsToRemove)
			{
				EntFire(entclass, "Kill");
			}
		}
		
		if (meds)
		{
			local medsToRemove =
			{
				weapon_first_aid_kit = 0
				weapon_defibrillator = 0
				weapon_pain_pills = 0
				weapon_adrenaline = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing meds...");
			foreach (entclass, v in medsToRemove)
			{
				local ent = null;
				while (ent = Entities.FindByClassname(ent, entclass))
				{
					if (ent.GetOwnerEntity() == null)
						DoEntFire("!self", "Kill", "", 0, null, ent);
				}
			}
		}
		
		if (med_spawns)
		{
			local medSpawnsToRemove =
			{
				weapon_first_aid_kit_spawn = 0
				weapon_defibrillator_spawn = 0
				weapon_pain_pills_spawn = 0
				weapon_adrenaline_spawn = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing med spawns...");
			foreach (entclass, v in medSpawnsToRemove)
			{
				EntFire(entclass, "Kill");
			}
		}

		if (health_cabinets)
		{
			local medSpawnsToRemove =
			{
				prop_health_cabinet = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing health cabinets...");
			foreach (entclass, v in medSpawnsToRemove)
			{
				EntFire(entclass, "Kill");
			}
		}
		
		if (upgrades)
		{
			local upgradesToRemove =
			{
				weapon_upgradepack_incendiary = 0
				weapon_upgradepack_explosive = 0
				upgrade_laser_sight = 0
				//upgrade_item = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing upgrades...");
			foreach (entclass, v in upgradesToRemove)
			{
				local ent = null;
				while (ent = Entities.FindByClassname(ent, entclass))
				{
					if (ent.GetOwnerEntity() == null)
						DoEntFire("!self", "Kill", "", 0, null, ent);
				}
			}
		}
		
		if (upgrade_spawns)
		{
			local upgradeSpawnsToRemove =
			{
				weapon_upgradepack_incendiary_spawn = 0
				weapon_upgradepack_explosive_spawn = 0
				upgrade_laser_sight_spawn = 0
				//upgrade_item_spawn = 0
				upgrade_spawn = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing upgrade spawns...");
			foreach (entclass, v in upgradeSpawnsToRemove)
			{
				EntFire(entclass, "Kill");
			}
		}
		
		if (extras)
		{
			local extrasToRemove =
			{
				weapon_fireworkcrate = 0
				weapon_gascan = 0
				weapon_oxygentank = 0
				weapon_propanetank = 0
				weapon_scavenge_item = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing extras...");
			foreach (entclass, v in extrasToRemove)
			{
				local ent = null;
				while (ent = Entities.FindByClassname(ent, entclass))
				{
					if (ent.GetOwnerEntity() == null)
						DoEntFire("!self", "Kill", "", 0, null, ent);
				}
			}
			
			// TODO:
			// (prop_physics) - model: models/props_junk/gascan001a.mdl
			// (prop_physics) - model: models/props_junk/propanecanister001a.mdl
			// (prop_physics) - model: models/props_equipment/oxygentank01.mdl
			
			// Objects.OfModel(model);
		}
		
		if (extra_spawns)
		{
			local extraSpawnsToRemove =
			{
				weapon_fireworkcrate_spawn = 0
				weapon_gascan_spawn = 0
				weapon_oxygentank_spawn = 0
				weapon_propanetank_spawn = 0
				weapon_scavenge_item_spawn = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing extra spawns...");
			foreach (entclass, v in extraSpawnsToRemove)
			{
				EntFire(entclass, "Kill");
			}
		}
		
		if (ammo)
		{
			local ammoToRemove =
			{
				weapon_ammo = 0
				weapon_ammo_spawn = 0
			}
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Sanitize - Removing ammo...");
			foreach (entclass, v in ammoToRemove)
			{
				local ent = null;
				while (ent = Entities.FindByClassname(ent, entclass))
				{
					if (Left4Fun.IsThePassingFinaleL4D1Item(entclass, ent.GetOrigin()))
						Left4Fun.Log(LOG_LEVEL_DEBUG, "ignoring The Passing finale L4D1 " + entclass);
					else
						DoEntFire("!self", "Kill", "", 0, null, ent);
				}
			}
		}
	}

	::Left4Fun.DelayedReplacePickupsWithMoney <- function (args)
	{
		Left4Timers.RemoveTimer("DelayedReplacePickupsWithMoney");
		
		if (Left4Fun.ReplacePickupsWithMoney())
			Left4Timers.AddTimer("DelayedReplacePickupsWithMoney", 0.1, Left4Fun.DelayedReplacePickupsWithMoney, { }, false);
		else if (Left4Fun.SaferoomAmmoToRestore != null)
		{
			// We spawn this here after the ReplacePickupsWithMoney cycle finished or it gets removed
			Left4Utils.SpawnAmmo(Left4Fun.SaferoomAmmoToRestore.model, Left4Fun.SaferoomAmmoToRestore.location, Left4Fun.SaferoomAmmoToRestore.angles);
			Left4Fun.SaferoomAmmoToRestore = null;
		}
	}

	::Left4Fun.ReplacePickupsWithMoney <- function ()
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "Replacing pickups with money...");
		
		local count = 0;
		local srLocation = Left4Fun.GetSaferoomLocation();
		
		foreach (entclass, amount in ::Left4Fun.ClassesToReplaceWithMoney)
		{
			local ent = null;
			while (ent = Entities.FindByClassname(ent, entclass))
			{
				if (entclass.find("_spawn") != null || ent.GetOwnerEntity() == null)
				{
					// If you remove from the saferoom all the objects that usually get transitioned to the next map by the
					// info_changelevel (medkits, weapons, ammo, etc..), in the next map such objects are spawned again as if
					// you started the campaign from that map, so i leave there an ammo pile to make the transition work correctly
					// and have no duplicate money in the next map's saferoom.
					if (srLocation && entclass == "weapon_ammo_spawn" && (ent.GetOrigin() - srLocation).Length() <= 500)
					{
						Left4Fun.SaferoomMoney.AmmoSpawnIndex <- ent.GetEntityIndex();
						Left4Fun.SaferoomMoney.AmmoSpawnLocation <- { x = 0, y = 0, z = 0 };
						Left4Fun.SaferoomMoney.AmmoSpawnAngles <- { pitch = 0, yaw = 0, roll = 0 };
						Left4Fun.SaferoomMoney.AmmoSpawnModel <- "";
						
						Left4Fun.Log(LOG_LEVEL_DEBUG, "ignoring saferoom ammo_spawn: " + Left4Fun.SaferoomMoney.AmmoSpawnIndex);
					}
					else if (Left4Fun.IsThePassingFinaleL4D1Item(entclass, ent.GetOrigin()))
						Left4Fun.Log(LOG_LEVEL_DEBUG, "ignoring The Passing finale L4D1 " + entclass);
					else
					{
						local location = ent.GetOrigin();
						//DoEntFire("!self", "Kill", "", 0, null, ent);
						ent.Kill();
						
						if (amount > 0)
						{
							local c = amount;
							while (c > 0)
							{
								local xoffs = RandomInt(5, 20);
								local yoffs = RandomInt(5, 20);
								local zoffs = 8;
								local dir = RandomInt(0, 360);
								
								Left4Fun.SpawnL4FPickup(L4FPICKUP_MONEY_MODEL, L4FPICKUP_MONEY_PTYPE, (c >= 1000) ? 1000 : c, location + Vector(xoffs, yoffs, zoffs), QAngle(0, dir, 0));
								c -= 1000;
							}
							
							Left4Fun.Log(LOG_LEVEL_DEBUG, "Replaced " + entclass + " with " + amount + " money");
							
							if (++count >= 10)
								return true;
						}
					}
				}
			}
		}
		return false;
	}

	::Left4Fun.GetLandmarkByName <- function (name)
	{
		local ent = null;
		while (ent = Entities.FindByClassname(ent, "info_landmark"))
		{
			if (ent.GetName() == name)
				return ent;
		}
		return null;
	}

	::Left4Fun.GetChangeLevel <- function ()
	{
		local changelevel = Entities.FindByClassname(null, "info_changelevel");
		if (!changelevel)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "GetChangeLevel - info_changelevel was not found, trying trigger_changelevel...");
			changelevel = Entities.FindByClassname(null, "trigger_changelevel");
			if (!changelevel)
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "GetChangeLevel - trigger_changelevel was not found!");
				return null;
			}
		}
		return changelevel;
	}

	::Left4Fun.GetSaferoomLandmark <- function ()
	{
		local changelevel = Left4Fun.GetChangeLevel();
		if (!changelevel)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "GetSaferoomLandmark - couldn't find a changelevel trigger on this map!");
			return null;
		}
		
		local landmark = NetProps.GetPropString(changelevel, "m_landmarkName");
		local ent = Left4Fun.GetLandmarkByName(landmark);
		if (!ent)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "GetSaferoomLandmark - couldn't find a landmark entity named: " + landmark);
			return null;
		}
		
		return ent;
	}

	::Left4Fun.GetSaferoomDoor <- function ()
	{
		local landmark = Left4Fun.GetSaferoomLandmark();
		if (!landmark)
			return null;
		
		return Entities.FindByClassnameNearest("prop_door_rotating_checkpoint", landmark.GetOrigin(), 2000);
	}

	::Left4Fun.GetSaferoomLocation <- function ()
	{
		local landmark = Left4Fun.GetSaferoomLandmark();
		if (landmark)
			return landmark.GetOrigin();
		return null;
	}

	::Left4Fun.GetSaferoomDoorLocation <- function ()
	{
		local door = Left4Fun.GetSaferoomDoor()
		if (!door)
			return null;
			
		return (door.GetOrigin() + (door.GetAngles().Forward() * 50) - (door.GetAngles().Left() * 60));
	}

	::Left4Fun.LoadSaferoomMoney <- function ()
	{
		Left4Fun.SaferoomMoney = Left4Utils.LoadTable("left4fun/data/" + Left4Fun.BaseName + "_savedmoney.dat");
		if (!Left4Fun.SaferoomMoney || !("Landmark" in Left4Fun.SaferoomMoney))
		{
			Left4Fun.SaferoomMoney <- {};
			return;
		}
		
		local landmark = Left4Fun.GetLandmarkByName(Left4Fun.SaferoomMoney.Landmark);
		if (!landmark)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "LoadSaferoomMoney - can't find a landmark entity named '" + Left4Fun.SaferoomMoney.Landmark + "' on this map, clearing saferoom money...");
			Left4Fun.CleanSaferoomMoney();
			return;
		}
		
		local landmarkLocation = landmark.GetOrigin();
		foreach (money in Left4Fun.SaferoomMoney.Money)
		{
			local loc = Vector(money.Location.x, money.Location.y, money.Location.z);
			local ang = QAngle(money.Angles.pitch, money.Angles.yaw, money.Angles.roll);
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Money to load -> Amount: " + money.Amount + " - Location: " + loc + " - Angles: " + ang);
			
			Left4Fun.SpawnL4FPickup(L4FPICKUP_MONEY_MODEL, L4FPICKUP_MONEY_PTYPE, money.Amount, loc + landmarkLocation, ang);
		}
		
		if (!("AmmoSpawnModel" in Left4Fun.SaferoomMoney) || !Left4Fun.SaferoomMoney.AmmoSpawnModel || Left4Fun.SaferoomMoney.AmmoSpawnModel == "")
			Left4Fun.Log(LOG_LEVEL_DEBUG, "LoadSaferoomMoney - Ammo spawn wasn't saved!");
		else
		{
			local loc = Vector(Left4Fun.SaferoomMoney.AmmoSpawnLocation.x, Left4Fun.SaferoomMoney.AmmoSpawnLocation.y, Left4Fun.SaferoomMoney.AmmoSpawnLocation.z);
			local ang = QAngle(Left4Fun.SaferoomMoney.AmmoSpawnAngles.pitch, Left4Fun.SaferoomMoney.AmmoSpawnAngles.yaw, Left4Fun.SaferoomMoney.AmmoSpawnAngles.roll);
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Ammo spawn to load -> Model: " + Left4Fun.SaferoomMoney.AmmoSpawnModel + " - Location: " + loc + " - Angles: " + ang);
			
			Left4Fun.SaferoomAmmoToRestore <- { model = Left4Fun.SaferoomMoney.AmmoSpawnModel, location = loc + landmarkLocation, angles = ang };
		}
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Saferoom money loaded.");
	}

	::Left4Fun.SaveSaferoomMoney <- function ()
	{
		local changelevel = Left4Fun.GetChangeLevel();
		if (!changelevel)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "SaveSaferoomMoney - can't save saferoom money, no changelevel trigger found!");
			return;
		}
		
		local landmark = Left4Fun.GetSaferoomLandmark();
		if (!landmark)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "SaveSaferoomMoney - can't save saferoom money, no saferoom landmark found!");
			return;
		}

		Left4Fun.SaferoomMoney.Landmark <- landmark.GetName();
		Left4Fun.SaferoomMoney.Money <- [];
		
		local landmarkLocation = landmark.GetOrigin();
		local ent = null;
		while (ent = Entities.FindByClassname(ent, "func_button"))
		{
			if (ent.GetName().find("l4fpick") && changelevel.IsTouching(ent))
			{
				local pickup = ent;
				if (ent.GetMoveParent() != null)
					pickup = ent.GetMoveParent();
				
				local money = {};
				
				local loc = pickup.GetOrigin() - landmarkLocation;
				local ang = pickup.GetAngles();
				
				money.Amount <- pickup.GetScriptScope().pvalue;
				money.Location <- { x = loc.x, y = loc.y, z = loc.z };
				money.Angles <- { pitch = ang.Pitch(), yaw = ang.Yaw(), roll = ang.Roll() };
				
				Left4Fun.Log(LOG_LEVEL_DEBUG, "Money to save -> Amount: " + money.Amount + " - Location: " + loc + " - Angles: " + ang);
				
				Left4Fun.SaferoomMoney.Money.push(money);
			}
		}
		
		if ("AmmoSpawnIndex" in Left4Fun.SaferoomMoney)
		{
			local saferoomAmmo = EntIndexToHScript(Left4Fun.SaferoomMoney.AmmoSpawnIndex);
			if (!saferoomAmmo)
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "SaveSaferoomMoney - Couldn't fine ammo_spawn entity with index: " + Left4Fun.SaferoomMoney.AmmoSpawnIndex);
				
				Left4Fun.SaferoomMoney.AmmoSpawnLocation <- { x = 0, y = 0, z = 0 };
				Left4Fun.SaferoomMoney.AmmoSpawnAngles <- { pitch = 0, yaw = 0, roll = 0 };
				Left4Fun.SaferoomMoney.AmmoSpawnModel <- "";
			}
			else
			{
				local loc = saferoomAmmo.GetOrigin() - landmarkLocation;
				local ang = saferoomAmmo.GetAngles();
				
				Left4Fun.SaferoomMoney.AmmoSpawnLocation <- { x = loc.x, y = loc.y, z = loc.z };
				Left4Fun.SaferoomMoney.AmmoSpawnAngles <- { pitch = ang.Pitch(), yaw = ang.Yaw(), roll = ang.Roll() };
				Left4Fun.SaferoomMoney.AmmoSpawnModel <- NetProps.GetPropString(saferoomAmmo, "m_ModelName");
				
				Left4Fun.Log(LOG_LEVEL_DEBUG, "Ammo spawn to save -> Model: " + Left4Fun.SaferoomMoney.AmmoSpawnModel + " - Location: " + loc + " - Angles: " + ang);
			}
		}
		
		Left4Utils.SaveTable(Left4Fun.SaferoomMoney, "left4fun/data/" + Left4Fun.BaseName + "_savedmoney.dat");
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Saferoom money saved.");
	}

	::Left4Fun.CleanSaferoomMoney <- function ()
	{
		Left4Fun.SaferoomMoney <- {};
		
		Left4Utils.SaveTable(Left4Fun.SaferoomMoney, "left4fun/data/" + Left4Fun.BaseName + "_savedmoney.dat");
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Saferoom money cleared.");
	}

	::Left4Fun.ZombieMoneyEarn <- function (player, zombieType)
	{
		if (!Left4Fun.L4FCvars.money)
			return;
		
		local amount = 0;
		if (zombieType <= Z_COMMON)
			amount = 10;
		else if (zombieType >= Z_SMOKER && zombieType <= Z_CHARGER)
			amount = 100;
		else if (zombieType == Z_TANK)
			amount = 500; // TODO: should be splitted between teammates?
		else if (zombieType == Z_WITCH || zombieType == Z_WITCH_BRIDE)
			amount = 150;

		Left4Fun.AddBankItemAmount(player, "money", amount);
	}

	::Left4Fun.ZombieMoneyDrop <- function (zombieType, location, angles, velocity)
	{
		local chance = 0;
		local amount = 0;
		
		if (zombieType <= Z_COMMON)
		{
			chance = 10;
			amount = RandomInt(2, 10);
		}
		else if (zombieType >= Z_SMOKER && zombieType <= Z_CHARGER)
		{
			chance = 60;
			amount = RandomInt(10, 50);
		}
		else if (zombieType == Z_TANK)
		{
			chance = 100;
			amount = RandomInt(50, 100);
		}
		else if (zombieType == Z_WITCH || zombieType == Z_WITCH_BRIDE)
		{
			chance = 75;
			amount = RandomInt(30, 60);
		}
		
		if (RandomInt(1, 100) > chance)
			return;
		
		while (amount > 0)
		{
			local dir = RandomInt(0, 360);
			
			local forward = Vector(cos(dir), sin(dir), 0);  //(cos(pitch)cos(yaw), cos(pitch)sin(yaw), sin(pitch))
			forward.z = 1;
			
			Left4Fun.SpawnL4FDrop(L4FPICKUP_MONEY_MODEL, L4FPICKUP_MONEY_PTYPE, (amount >= 10) ? 10 : amount, location + Vector(0, 0, 50), QAngle(0, dir, 0), forward * 160);
			
			amount -= 10;
		}
	}

	::Left4Fun.HorizontalVelocity <- function (vel)
	{
		return (abs(vel.x) + abs(vel.y)); // x,y = horizontal coords - z = vertical
	}

	::Left4Fun.SurvivorAbilitiesUpdate <- function (args)
	{
		SurvivorAbilities.Update(!Left4Fun.AreAllSurvivorsInSafeSpot());
	}

	::Left4Fun.PlayerIn <- function (player)
	{
		local userid = player.GetPlayerUserId().tointeger();
		
		if (Left4Fun.IsAdmin(player))
		{
			if (Left4Fun.OnlineAdmins.find(userid) == null)
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "Adding admin with userid: " + userid);
		
				Left4Fun.OnlineAdmins.push(userid);
				Left4Fun.OnlineAdmins.sort();
				
				Left4Fun.PrintToPlayerChat(player, "You have been added to the online admins list", PRINTCOLOR_GREEN);
			}
		}
		
		if (Left4Fun.IsTroll(player))
		{
			if (Left4Fun.OnlineTrolls.find(userid) == null)
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "Adding troll with userid: " + userid);
		
				Left4Fun.OnlineTrolls.push(userid);
				Left4Fun.OnlineTrolls.sort();
			}
			
			// TODO
			//Left4Fun.PrintToPlayerChat(player, "You have been added to the online admins list", PRINTCOLOR_GREEN);
		}
	}

	::Left4Fun.PlayerOut <- function (player)
	{
		local userid = player.GetPlayerUserId().tointeger();
		
		local idx = Left4Fun.OnlineAdmins.find(userid);
		if (idx != null)
		{
			Left4Fun.OnlineAdmins.remove(idx);
			Left4Fun.Log(LOG_LEVEL_DEBUG, "OnlineAdmin removed with idx: " + idx);
		}
		
		idx = Left4Fun.OnlineTrolls.find(userid);
		if (idx != null)
		{
			Left4Fun.OnlineTrolls.remove(idx);
			Left4Fun.Log(LOG_LEVEL_DEBUG, "OnlineTroll removed with idx: " + idx);
		}
	}

	::Left4Fun.DelayedOnWitchSpawned <- function (args)
	{
		if (!("witch" in args))
			return;
		local witch = args["witch"];
		if (!witch)
		{
			Left4Fun.Log(LOG_LEVEL_WARN, "witch is null!!!");
			return;
		}
		
		//Left4Fun.Log(LOG_LEVEL_DEBUG, "DelayedOnWitchSpawned");
		
		local iClass = Left4Utils.GetType(witch);
		local convertedClass = Left4Fun.MyConvertZombieClass(iClass);
		if (convertedClass != iClass)
		{
			//Left4Utils.SpawnInfected(convertedClass, witch.GetOrigin(), QAngle(0,0,0), true);
			Left4Utils.SpawnInfected(convertedClass, null, QAngle(0,0,0), true);
			Left4Utils.KillPlayer(witch);
		}
		else 
		{
			if (Left4Fun.WitchesToSpawn < 0)
			{
				Left4Fun.WitchesToSpawn = Left4Fun.L4FCvars.witch_clones;
				Left4Fun.Log(LOG_LEVEL_DEBUG, "Witch master spawned, spawning " + Left4Fun.WitchesToSpawn + " witch clones...");
			}
				
			if (Left4Fun.WitchesToSpawn > 0)
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "Delayed witch spawn...");
				Left4Fun.WitchesToSpawn--;
				Left4Utils.SpawnInfected(iClass, witch.GetOrigin(), QAngle(0,0,0), true);
			}
			else
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "No more witches to spawn");
				Left4Fun.WitchesToSpawn = -1;
			}
		}
	}

	::Left4Fun.DelayedOnSpawn <- function (args)
	{
		if (!("userid" in args))
			return;
		local userid = args["userid"];
		
		//Left4Fun.Log(LOG_LEVEL_DEBUG, "DelayedOnSpawn_" + userid);
		Left4Timers.RemoveTimer("DelayedOnSpawn_" + userid);
		
		local player = g_MapScript.GetPlayerFromUserID(userid);
		if (!player)
			return;
		
		local iClass = Left4Utils.GetType(player);
		local convertedClass = Left4Fun.MyConvertZombieClass(iClass);
		if (convertedClass != iClass)
		{
			//Left4Utils.SpawnInfected(convertedClass, player.GetOrigin(), QAngle(0,0,0), true);
			Left4Utils.SpawnInfected(convertedClass, null, QAngle(0,0,0), true);
			Left4Utils.KillPlayer(player);
		}
		else if (iClass == Z_TANK)
		{
			if (Left4Fun.TanksToSpawn < 0)
			{
				Left4Fun.TanksToSpawn = Left4Fun.L4FCvars.tank_clones;
				Left4Fun.Log(LOG_LEVEL_DEBUG, "Tank master spawned, spawning " + Left4Fun.TanksToSpawn + " tank clones...");
			}
				
			if (Left4Fun.TanksToSpawn > 0)
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "Delayed tank spawn...");
				Left4Fun.TanksToSpawn--;
				Left4Utils.SpawnInfected(Z_TANK, player.GetOrigin(), QAngle(0,0,0), true);
			}
			else
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "No more tanks to spawn");
				Left4Fun.TanksToSpawn = -1;
			}
		}
	}

	::Left4Fun.IsExtraSurvivor <- function (survivor)
	{
		if (Director.GetSurvivorSet() == 1)
			return false; // Assume it's not possible to spawn extra survivor bots in L4D1 maps

		return (NetProps.GetPropInt(survivor, "m_survivorCharacter") >= 4);
	}

	::Left4Fun.NearIncapAdrenalineBoost <- function (player, health)
	{
	  if (Left4Fun.IsOnlineTroll(player))
		return;
	  
	  if (Left4Fun.L4FCvars.adrenalineboost == ST_USER.NONE)
			return;
		else if (Left4Fun.L4FCvars.adrenalineboost == ST_USER.ADMINS && !Left4Fun.IsOnlineAdmin(player))
			return;
		else if (Left4Fun.L4FCvars.adrenalineboost == ST_USER.USERS && Left4Fun.IsOnlineAdmin(player))
			return;
		
		if (health <= Left4Fun.L4FCvars.adrenalineboost_health && !player.IsAdrenalineActive())
			player.UseAdrenaline(Left4Fun.L4FCvars.adrenalineboost_duration);
	}

	::Left4Fun.PrintDamage <- function (victim, attacker, damageDone, damageTable)
	{
		local atk = "?";
		local atkTeam = "?";
		if (attacker != null)
		{
			atk = attacker.GetPlayerName();
			atkTeam = NetProps.GetPropInt(attacker, "m_iTeamNum");
		}
		
		local weapon = "?";
		if (damageTable.Weapon != null)
			weapon = damageTable.Weapon;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, atk + " (" + atkTeam + ") damaged " + victim.GetPlayerName() + " (" + NetProps.GetPropInt(victim, "m_iTeamNum") + "): " + damageDone + " HP of type " + damageTable.DamageType + " with " + weapon);
	}

	::Left4Fun.DamageContains <- function (damageType, containsType)
	{
		return (damageType & containsType) != 0;
	}

	::Left4Fun.UtilityRestore <- function (args)
	{
		if ("playerID" in args && "weapon" in args)
		{
			local userid = args["playerID"];
			local weapon = args["weapon"];
			
			Left4Timers.RemoveTimer("UtilsRestore_" + userid);
			
			local player = g_MapScript.GetPlayerFromUserID(userid);
			if (!player || player.IsDead() || player.IsDying())
				return;
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Restoring " + weapon + " to " + player.GetPlayerName());
			
			player.GiveItem(weapon);
			DoEntFire("!self", "CancelCurrentScene", "", 0, null, player);
		}
	}

	::Left4Fun.RestoreMaxTeamSwitches <- function (args)
	{
		//Left4Fun.Log(LOG_LEVEL_DEBUG, "Restoring vs_max_team_switches: " + Left4Fun.VsMaxTeamSwitches);
		Convars.SetValue("vs_max_team_switches", Left4Fun.VsMaxTeamSwitches);
	}

	::Left4Fun.ResetM60Clip <- function (args)
	{
		local weapon = args["weapon"];
		if (!weapon || !weapon.IsValid())
			return;
		
		NetProps.SetPropInt(weapon, "m_iClip1", 0);
		NetProps.SetPropInt(weapon, "m_iClip2", 0); // <- This is for compatibility with the reload_fix feature
	}

	::Left4Fun.GetFirstPlayableL4D2Survivor <- function ()
	{
		// Try to find a survivor who is still alive first
		foreach(survivor in ::Left4Utils.GetAliveSurvivors())
		{
			if (NetProps.GetPropInt(survivor, "m_survivorCharacter") < 4 && IsPlayerABot(survivor) && NetProps.GetPropInt(survivor, "m_humanSpectatorUserID") == 0)
				return survivor;
		}
		
		// Any available
		foreach(survivor in ::Left4Utils.GetAllSurvivors())
		{
			if (NetProps.GetPropInt(survivor, "m_survivorCharacter") < 4 && IsPlayerABot(survivor) && NetProps.GetPropInt(survivor, "m_humanSpectatorUserID") == 0)
				return survivor;
		}
		return null;
	}

	::Left4Fun.SwitchTeam <- function (player, team)
	{
		local character = null;
		if (team == 2 && Director.GetSurvivorSet() == 2)
		{
			character = Left4Fun.GetFirstPlayableL4D2Survivor();
			if (!character)
			{
				Left4Fun.Log(LOG_LEVEL_WARN, "Can't switch team, no playable character available"); // TODO: hint?
				return;
			}
		}

		if (Left4Fun.VsMaxTeamSwitches < 0)
			Left4Fun.VsMaxTeamSwitches = Convars.GetStr("vs_max_team_switches").tointeger();
		
		Convars.SetValue("vs_max_team_switches", 99);

		if (character)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Switching player " + player.GetPlayerName() + " to team " + team + " as " + Left4Utils.GetCharacterName(character));
			
			Left4Utils.ClientCommand(player, "jointeam " + team + " " + Left4Utils.GetCharacterName(character));
		}
		else
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Switching player " + player.GetPlayerName() + " to team " + team);
			
			Left4Utils.ClientCommand(player, "jointeam " + team);
		}
		
		Left4Timers.AddTimer("RestoreMaxTeamSwitches_" + player.GetPlayerUserId(), 0.2, Left4Fun.RestoreMaxTeamSwitches, { }, false);
	}

	::Left4Fun.GetGiveItem <- function (item)
	{
		foreach (key, val in Left4Fun.BuyItems_Give)
		{
			//Left4Fun.Log(LOG_LEVEL_DEBUG, "GetGiveItem: " + key);
			if (item.find(key) != null)
				return key;
		}
		return null;
	}

	::Left4Fun.GetSpawnItem <- function (item)
	{
		foreach (key, val in Left4Fun.BuyItems_Spawn)
		{
			//Left4Fun.Log(LOG_LEVEL_DEBUG, "GetSpawnItem: " + key);
			if (item.find(key) != null)
				return key;
		}
		return null;
	}

	::Left4Fun.GetGiveItemByWeapon <- function (weapon)
	{
		foreach (key, val in Left4Fun.BuyItems_Give)
		{
			//Left4Fun.Log(LOG_LEVEL_DEBUG, "GetGiveItemByWeapon: " + key);
			if (val.weapon == weapon)
				return key;
		}
		return null;
	}

	// Ret: 0 = can buy, >0 = not enough money (ret is the price of the item), -1 = item not found
	::Left4Fun.CanBuy <- function (player, key)
	{
		if (!(key in Left4Fun.BuyItems_Spawn) && !(key in Left4Fun.BuyItems_Give))
			return -1;
		
		if (key in Left4Fun.BuyItems_Spawn)
		{
			if (Left4Fun.BuyItems_Spawn[key] <= Left4Fun.GetBankItemAmount(player, "money"))
				return 0;
			else
				return Left4Fun.BuyItems_Spawn[key];
		}
		
		if (Left4Fun.BuyItems_Give[key].price <= Left4Fun.GetBankItemAmount(player, "money"))
			return 0;
		else
			return Left4Fun.BuyItems_Give[key].price;
	}

	::Left4Fun.Buy <- function (player, key)
	{
		local amount = 0;
		if (key in Left4Fun.BuyItems_Spawn)
			amount = Left4Fun.BuyItems_Spawn[key];
		else if (key in Left4Fun.BuyItems_Give)
			amount = Left4Fun.BuyItems_Give[key].price;
		
		Left4Fun.SubBankItemAmount(player, "money", amount);
	}

	// Ret: 0 = can buy, >0 = not enough money (ret is the price of the item), -1 = item not found
	::Left4Fun.SellAndGive <- function (player, key)
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "SellAndGive - " + player.GetPlayerName() + " - key: " + key);
		
		local c = Left4Fun.CanBuy(player, key);
		if (c != 0)
			return c;
		
		if (Left4Fun.BuyItems_Give[key].weapon != "ammo" && Left4Utils.HasItem(player, Left4Fun.BuyItems_Give[key].weapon))
		{
			local w = Left4Fun.BuyItems_Give[key].weapon;
			if (w.find("weapon_") == null)
				w = "weapon_melee";
			
			player.Drop(w);
		}
		
		if (!(Left4Fun.BuyItems_Give[key].weapon in Left4Fun.UnavailableMelee))
		{
			player.GiveItem(Left4Fun.BuyItems_Give[key].weapon);
			Left4Fun.Buy(player, key);
			Left4Fun.ChatNotice(player.GetPlayerName() + " bought " + key);
		}
		else
			Left4Fun.Log(LOG_LEVEL_INFO, "SellAndGive - Melee " + key + " is not available on this map");
		
		return c;
	}

	// Ret: 0 = can buy, >0 = not enough money (ret is the price of the item), -1 = item not found
	::Left4Fun.SellAndSpawn <- function (player, key)
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "SellAndSpawn - " + player.GetPlayerName() + " - key: " + key);
		
		local c = Left4Fun.CanBuy(player, key);
		if (c != 0)
			return c;
		
		local location = player.GetOrigin() + (player.GetForwardVector() * 20);
		local angles = QAngle(0, player.EyeAngles().y, 0);
		
		if (key == "pile")
		{
			local model = "models/props/terror/ammo_stack.mdl";
			if (RandomInt(0, 5) > 3)
				model = "models/props_unique/spawn_apartment/coffeeammo.mdl";
			Left4Utils.SpawnAmmo(model, location);
		}
		else if (key == "laser")
		{
			//player.GiveUpgrade(UPGRADE_LASER_SIGHT);
			local ent = g_ModeScript.CreateSingleSimpleEntityFromTable({ classname = "upgrade_spawn", origin = location, angles = angles, spawnflags = 2, laser_sight = 1, upgradepack_incendiary = 0, upgradepack_explosive = 0 });
			if (ent)
				ent.ValidateScriptScope();
			else
				Left4Fun.Log(LOG_LEVEL_WARN, "ent is null!");
		}
		else if (key == "barrel")
		{
			Left4Utils.SpawnFuelBarrel(location);
		}
		else if (key == "mg1")
		{
			Left4Utils.SpawnL4D1Minigun(location, angles);
		}
		else if (key == "mg2")
		{
			Left4Utils.SpawnMinigun(location, angles);
		}
		
		Left4Fun.Buy(player, key);
		Left4Fun.ChatNotice(player.GetPlayerName() + " bought " + key);
		
		return c;
	}

	::Left4Fun.GetNextAvailableInfectedClass <- function (classFrom)
	{
		if (!Left4Fun.ModeStarted)
			return -1;
		
		local c = classFrom;
		local i = 0;
		
		while (i < 6)
		{
			c++;
			if (c > 6)
				c = 1;
			
			if ((Left4Fun.InfectedLimits[c] - ::Left4Utils.GetAlivePlayersByType(c).len()) > 0)
				return c;
			
			i++;
		}
		return -1;
	}

	::Left4Fun.DO_next_infected <- function (player)
	{
		local c = NetProps.GetPropInt(player, "m_zombieClass");
		c = Left4Fun.GetNextAvailableInfectedClass(c);
		if (c < 0)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "No infected class available");
			return;
		}
		Left4Fun.Log(LOG_LEVEL_DEBUG, "Available infected class: " + c);

		local loc = player.GetOrigin();
		Left4Utils.KillPlayer(player); // this doesn't even work on ghost infected players, idk why i leave it here...
		Left4Fun.ZombieSelectionUserid = player.GetPlayerUserId();
		Left4Utils.SpawnInfected(c, loc);
	}

	::Left4Fun.EntInput <- function (entName, input, value = "", delay = 0, activator = null)
	{
		local ent = Entities.FindByName(null, entName);
		if (!ent)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "EntInput - " + entName + " not found!!!");
			return;
		}
		
		local activatorEnt = activator;
		if (activatorEnt == "!self")
			activatorEnt = ent;
			
		DoEntFire("!self", input.tostring(), value.tostring(), delay.tofloat(), activatorEnt, ent);
	}

	::Left4Fun.OnL4FDropSpawned <- function (ptype, value, ent)
	{
		//Left4Fun.Log(LOG_LEVEL_DEBUG, "OnL4FDropSpawned - " + ent.GetName() + " - ptype: " + ptype + " - value: " + value);
		
		EmitSoundOn("UI/gift_drop.wav", ent);
	}

	::Left4Fun.OnL4FPickupSpawned <- function (ptype, value, ent)
	{
		//Left4Fun.Log(LOG_LEVEL_DEBUG, "OnL4FPickupSpawned - " + ent.GetName() + " - ptype: " + ptype + " - value: " + value);
		
		//EmitSoundOn("UI/gift_drop.wav", ent);
	}

	::Left4Fun.OnL4FDropGrabbed <- function (player, ent)
	{
		Left4Fun.OnL4FPickupGrabbed(player, ent);
	}

	::Left4Fun.OnL4FPickupGrabbed <- function (player, ent)
	{
		//Left4Fun.Log(LOG_LEVEL_DEBUG, "OnL4FPickupGrabbed - " + player.GetName() + " - " + ent.GetName());
		
		if (NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS) // TODO?: || IsPlayerABot(player)
			return;
		
		local scope = ent.GetScriptScope();
		
		if (!("grabbed" in scope))
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "grabbed not in scope!");
			DoEntFire("!self", "Kill", "", 0, null, ent);
			return;
		}
		
		if (scope.grabbed)
		{
			//Left4Fun.Log(LOG_LEVEL_DEBUG, "already grabbed!");
			//DoEntFire("!self", "Kill", "", 0, null, ent);
			return;
		}
		scope.grabbed <- true;
		
		if (scope.ptype == L4FPICKUP_MONEY_PTYPE)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, player.GetPlayerName() + " grabbed " + scope.pvalue + " credits");
			Left4Fun.ChatNotice(player.GetPlayerName() + " grabbed " + scope.pvalue + " credits");
			
			Left4Fun.AddBankItemAmount(player, "money", scope.pvalue);
		}
		else if (scope.ptype == L4FPICKUP_GIFT_PTYPE)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, player.GetPlayerName() + " grabbed " + scope.pvalue + " gifts");
			Left4Fun.ChatNotice(player.GetPlayerName() + " grabbed " + scope.pvalue + " gifts");
			
			Left4Fun.AddBankItemAmount(player, "gifts", 1);
		}
		else
			Left4Fun.Log(LOG_LEVEL_WARN, "Invalid ptype!!!");
		
		EmitSoundOn("UI/littlereward.wav", ent);
		
		DoEntFire("!self", "KillHierarchy", "", 0, null, ent);
	}

	::Left4Fun.SpawnL4FDrop <- function (pmodel, ptype, pvalue, location, angles = QAngle(0,0,0), velocity = Vector(0, 0, 0))
	{
		angles = QAngle(0, angles.Yaw(), 0);
		
		local ent = g_ModeScript.CreateSingleSimpleEntityFromTable({ classname = "prop_physics_multiplayer", origin = location, angles = angles, targetname = "l4fpick", model = pmodel, spawnflags = 8192 + 512 + 4 + 2, rendermode = 10, nodamageforces = 1 });
		local ent2 = g_ModeScript.CreateSingleSimpleEntityFromTable({ classname = "prop_dynamic", origin = location, angles = angles, targetname = "l4fpick", model = pmodel, spawnflags = 256 });
		local ent3 = g_ModeScript.CreateSingleSimpleEntityFromTable({ classname = "func_button", origin = location, angles = angles, targetname = "l4fpick", model = pmodel, rendermode = 10, spawnflags = 1024 + 256 + 1, glow = ent2.GetName(), disableshadows = 1, disablereceiveshadows = 1 });
		
		NetProps.SetPropInt(ent2, "m_MoveType", 0);
		
		DoEntFire("!self", "DisableDamageForces", "", 0, null, ent3);
		NetProps.SetPropInt(ent3, "m_MoveType", 0);
		
		//ent.AttachOther(ent3, true);
		ent3.SetOrigin(ent.GetOrigin());
		DoEntFire("!self", "SetParent", "!activator", 0, ent, ent3);
		
		//ent3.AttachOther(ent2, true);
		ent2.SetOrigin(ent3.GetOrigin());
		DoEntFire("!self", "SetParent", "!activator", 0, ent3, ent2);
		
		//ent3.ConnectOutput("OnPressed", My_OnL4FDropTouch);
		ent3.ValidateScriptScope();
		local s = ent3.GetScriptScope();
		s["My_OnL4FDropTouch"] <- My_OnL4FDropTouch;
		ent3.ConnectOutput("OnPressed", "My_OnL4FDropTouch");
		
		ent.ValidateScriptScope();
		local scope = ent.GetScriptScope();
		scope.ptype <- ptype;
		scope.pvalue <- pvalue;
		scope.grabbed <- false;
		
		local function FixPos()
		{
			if (self.GetMoveParent() != null)
				self.SetOrigin(Vector(0, 0, 0));
		}
		
		//ent2.AddThinkFunction(FixPos);
		ent2.ValidateScriptScope();
		local scope = ent2.GetScriptScope();
		scope["FixPos"] <- FixPos;
		AddThinkToEnt(ent2, "FixPos");
		
		//ent3.AddThinkFunction(FixPos);
		ent3.ValidateScriptScope();
		local scope = ent3.GetScriptScope();
		scope["FixPos"] <- FixPos;
		AddThinkToEnt(ent3, "FixPos");
		
		::Left4Fun.OnL4FDropSpawned(ptype, pvalue, ent);

		//ent.ApplyAbsVelocityImpulse(velocity);
		
		Left4Timers.AddTimer("DelayedPush_" + UniqueString(), 0.1, Left4Fun.DelayedPush, { entity = ent, velocity = velocity }, false);
	}

	::Left4Fun.SpawnL4FPickup <- function (pmodel, ptype, pvalue, location, angles = QAngle(0,0,0))
	{
		angles = QAngle(0, angles.Yaw(), 0);

		// glowcolor -> close: 0.3, 0.7, 1.0 - far: 0.3, 0.4, 1.0
		// 												76 178 255 - 76 102 255
		//local ent = CreateEntity("prop_physics_override", location, angles, { targetname = "l4fpick", model = pmodel, spawnflags = 8192 + 4096 + 4 + 2, rendermode = 3, renderamt = 255, renderfx = 14, glowstate = 2, glowrange = 300, glowcolor = "76 102 255", solid = 6, MoveType = 6, CollisionGroup = 4, health = 0, PerformanceMode = 1, nodamageforces = 1 });
		//local ent = CreateEntity("prop_physics", location, angles, { targetname = "l4fpick", model = "models/props_junk/gnome.mdl", spawnflags = 8192, overridescript = "glow,1,physicsmode,1,base,Metal.GasCan" });
		
		//local ent = CreateEntity("scripted_item_drop", location, angles, { targetname = "l4fpick", model = pmodel, spawnflags = 8192 + 4096 + 2, solid = 1, rendermode = 10, nodamageforces = 1 });
		
		local ent = g_ModeScript.CreateSingleSimpleEntityFromTable({ classname = "prop_physics_multiplayer", origin = location, angles = angles, targetname = "l4fpick", model = pmodel, spawnflags = 8192 + 512 + 4 + 2, rendermode = 10, nodamageforces = 1 });
		local ent2 = g_ModeScript.CreateSingleSimpleEntityFromTable({ classname = "prop_dynamic", origin = location, angles = angles, targetname = "l4fpick", model = pmodel, spawnflags = 256 });
		local ent3 = g_ModeScript.CreateSingleSimpleEntityFromTable({ classname = "func_button", origin = location, angles = angles, targetname = "l4fpick", model = pmodel, rendermode = 10, spawnflags = 1024 + 256 + 1, glow = ent2.GetName(), disableshadows = 1, disablereceiveshadows = 1 });
		
		NetProps.SetPropInt(ent2, "m_MoveType", 0);
		
		DoEntFire("!self", "DisableDamageForces", "", 0, null, ent3);
		NetProps.SetPropInt(ent3, "m_MoveType", 0);
		
		//ent.AttachOther(ent3, true);
		ent3.SetOrigin(ent.GetOrigin());
		DoEntFire("!self", "SetParent", "!activator", 0, ent, ent3);
		
		//ent3.AttachOther(ent2, true);
		ent2.SetOrigin(ent3.GetOrigin());
		DoEntFire("!self", "SetParent", "!activator", 0, ent3, ent2);
		
		//ent3.ConnectOutput("OnPressed", My_OnL4FPickupTouch);
		ent3.ValidateScriptScope();
		local s = ent3.GetScriptScope();
		s["My_OnL4FPickupTouch"] <- My_OnL4FPickupTouch;
		ent3.ConnectOutput("OnPressed", "My_OnL4FPickupTouch");
		
		ent.ValidateScriptScope();
		local scope = ent.GetScriptScope();
		scope.ptype <- ptype;
		scope.pvalue <- pvalue;
		scope.grabbed <- false;
		
		local function FixPos()
		{
			if (self.GetMoveParent() != null)
				self.SetOrigin(Vector(0, 0, 0));
		}
		
		//ent2.AddThinkFunction(FixPos);
		ent2.ValidateScriptScope();
		local scope = ent2.GetScriptScope();
		scope["FixPos"] <- FixPos;
		AddThinkToEnt(ent2, "FixPos");
		
		//ent3.AddThinkFunction(FixPos);
		ent3.ValidateScriptScope();
		local scope = ent3.GetScriptScope();
		scope["FixPos"] <- FixPos;
		AddThinkToEnt(ent3, "FixPos");
		
		::Left4Fun.OnL4FPickupSpawned(ptype, pvalue, ent);
	}

	::My_OnL4FDropTouch <- function ()
	{
		//Left4Fun.Log(LOG_LEVEL_DEBUG, "My_OnL4FDropTouch");
		
		Left4Fun.OnL4FDropGrabbed(activator, self.GetMoveParent());
	}

	::My_OnL4FPickupTouch <- function ()
	{
		//Left4Fun.Log(LOG_LEVEL_DEBUG, "My_OnL4FPickupTouch");
		
		Left4Fun.OnL4FPickupGrabbed(activator, self.GetMoveParent());
	}

	::Left4Fun.DelayedPush <- function (args)
	{
		if (!("entity" in args) || !("velocity" in args))
			return;
			
		local entity = args["entity"];
		local velocity = args["velocity"];

		if (!entity || !entity.IsValid())
			return;

		//Left4Fun.DebugChatNotice("Vel: " + velocity);
		
		entity.ApplyAbsVelocityImpulse(velocity);
	}

	::Left4Fun.SetupExtraSurvivor <- function (survivor)
	{
		if (!survivor || !survivor.IsValid())
			return;
		
		local char = NetProps.GetPropInt(survivor, "m_survivorCharacter");
		if (!(char in ::Left4Fun.SpawningExtraSurvivors))
			return;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "SetupExtraSurvivor - char: " + char);
		
		foreach (key, val in ::Left4Fun.SpawningExtraSurvivors[char])
		{
			if (typeof val == "integer")
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "SetupExtraSurvivor - " + key + ": " + val);
				NetProps.SetPropInt(survivor, key, val);
			}
			else if (typeof val == "float")
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "SetupExtraSurvivor - " + key + ": " + val);
				NetProps.SetPropFloat(survivor, key, val);
			}
			if (typeof val == "string")
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "SetupExtraSurvivor - " + key + ": " + val);
				NetProps.SetPropString(survivor, key, val);
			}
		}
	}

	::Left4Fun.SpawnSurvivor <- function (char, pos = Vector(0, 0, 0), ang = QAngle(0, 0, 0), team = TEAM_SURVIVORS, l4d1behavior = false, newChar = null)
	{
		local nChar = 0;
		char = char.tolower();
		
		if (char == "bill")
			nChar = 4;
		else if (char == "zoey")
			nChar = 5;
		else if (char == "francis")
			nChar = 6;
		else if (char == "louis")
			nChar = 7;
		
		if (nChar == 0)
			return false;
		
		if (newChar != null)
			Left4Fun.SpawningExtraSurvivors[nChar] <- { m_iTeamNum = team.tointeger(), m_survivorCharacter = newChar.tointeger(), m_iAccount = 1, m_humanSpectatorUserID = -1, m_humanSpectatorEntIndex = -1 };
		else
			Left4Fun.SpawningExtraSurvivors[nChar] <- { m_iTeamNum = team.tointeger(), m_iAccount = 1, m_humanSpectatorUserID = -1, m_humanSpectatorEntIndex = -1 };
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "SpawnSurvivor - char: " + char + " - team: " + team + " - l4d1behavior: " + l4d1behavior + " - newChar: " + newChar);
		
		Left4Utils.SpawnL4D1Survivor(nChar, pos, ang, l4d1behavior);
	}
		
	::Left4Fun.ApplyRenderCVars <- function (ent, entType)
	{
		if (!ent || !ent.IsValid())
			return;
		
		if (entType in ::Left4Fun.L4FCvars.render_mode)
			ent.__KeyValueFromInt("rendermode", Left4Fun.L4FCvars.render_mode[entType].tointeger());
			
		if (entType in ::Left4Fun.L4FCvars.render_fx)
			ent.__KeyValueFromInt("renderfx", Left4Fun.L4FCvars.render_fx[entType].tointeger());
		
		if (entType in ::Left4Fun.L4FCvars.render_color)
			ent.__KeyValueFromString("rendercolor", Left4Fun.L4FCvars.render_color[entType]);
	}

	::Left4Fun.ApplyPlayerRenderCVars <- function (player)
	{
		local z = NetProps.GetPropInt(player, "m_zombieClass");
		switch (z)
		{
			case Z_SMOKER:
			{
				Left4Fun.ApplyRenderCVars(player, "smoker");
				break;
			}
			case Z_BOOMER:
			{
				Left4Fun.ApplyRenderCVars(player, "boomer");
				break;
			}
			case Z_HUNTER:
			{
				Left4Fun.ApplyRenderCVars(player, "hunter");
				break;
			}
			case Z_SPITTER:
			{
				Left4Fun.ApplyRenderCVars(player, "spitter");
				break;
			}
			case Z_JOCKEY:
			{
				Left4Fun.ApplyRenderCVars(player, "jockey");
				break;
			}
			case Z_CHARGER:
			{
				Left4Fun.ApplyRenderCVars(player, "charger");
				break;
			}
			case Z_SURVIVOR:
			{
				Left4Fun.ApplyRenderCVars(player, "survivor");
				break;
			}
			case Z_TANK:
			{
				Left4Fun.ApplyRenderCVars(player, "tank");
				break;
			}
		}
	}

	::Left4Fun.RenderCommons <- function (args)
	{
		local ent = null;
		while (ent = Entities.FindByClassname(ent, "infected"))
			Left4Fun.ApplyRenderCVars(ent, "common");
	}

	::Left4Fun.InitHud <- function ()
	{
		// TODO: keep already created huds from other scripts (but how? there is no HUDGetLayout)
		
		if (Left4Fun.L4FCvars.money_hud)
		{
			Left4Hud.AddHud("money", g_ModeScript.HUD_TICKER, g_ModeScript.HUD_FLAG_TEAM_SURVIVORS | g_ModeScript.HUD_FLAG_NOTVISIBLE);
			Left4Hud.PlaceHud("money", 0.25, 0.0, 0.5, 0.025);
		}
	}

	::Left4Fun.UpdHud <- function (args)
	{
		local str = "";
		
		foreach(s in ::Left4Utils.GetAllSurvivors())
		{
			local accName = Left4Fun.BankAccountName(s);
			if (accName)
			{
				if (str == "")
					str = accName + ": " + Left4Fun.GetBankItemAmount(s, "money");
				else
					str += " - " + accName + ": " + Left4Fun.GetBankItemAmount(s, "money");
			}
		}
		
		Left4Hud.SetHudText("money", str);
	}

	::Left4Fun.ShowHud <- function ()
	{
		Left4Timers.RemoveTimer("UpdHud");
		
		Left4Fun.UpdHud(null);
		
		Left4Hud.ShowHud("money");
		
		Left4Timers.AddTimer("UpdHud", 2, Left4Fun.UpdHud, { }, true);
	}

	::Left4Fun.HideHud <- function (args)
	{
		Left4Timers.RemoveTimer("UpdHud");
		
		Left4Hud.HideHud("money");
	}

	::Left4Fun.GetPrimaryLevel <- function (inventory)
	{
		if (!inventory || !("slot0" in inventory))
			return 0;

		local weapon = inventory["slot0"].GetClassname();
		
		foreach (w in Left4Fun.PrimaryWeaponLevel1)
		{
			if (w == weapon)
				return 1;
		}
		
		foreach (w in Left4Fun.PrimaryWeaponLevel2)
		{
			if (w == weapon)
				return 2;
		}
		
		return 3;
	}

	::Left4Fun.GetRandomPrimary <- function (level)
	{
		if (level == 1)
			return Left4Fun.PrimaryWeaponLevel1[RandomInt(0, Left4Fun.PrimaryWeaponLevel1.len() - 1)];
		else if (level == 2)
			return Left4Fun.PrimaryWeaponLevel2[RandomInt(0, Left4Fun.PrimaryWeaponLevel2.len() - 1)];
		else
			return null;
	}

	::Left4Fun.BotsBuyThink <- function (args)
	{
	  foreach(survivor in ::Left4Utils.GetAliveSurvivorBots())
	  {
		local money = Left4Fun.GetBankItemAmount(survivor, "money");
		local health = survivor.GetHealth() + survivor.GetHealthBuffer();
		local inventory = {};
		GetInvTable(survivor, inventory);

		// SLOT_PRIMARY = 0, SLOT_SECONDARY = 1, SLOT_THROW = 2, SLOT_MEDKIT = 3, SLOT_PILLS = 4

		// 1st: try to get the best primary weapon we can afford
		local justBoughtWeapon = false;
		local l = Left4Fun.GetPrimaryLevel(inventory);
		if (l < 2)
		{
			local w = Left4Fun.GetRandomPrimary(2);
			local key = Left4Fun.GetGiveItemByWeapon(w);
			if (key)
			{
				if (Left4Fun.BuyItems_Give[key].price <= money)
				{
					Left4Fun.SellAndGive(survivor, key);
					justBoughtWeapon = true;
				}
				else if (l < 1)
				{
					w = Left4Fun.GetRandomPrimary(1);
					local key = Left4Fun.GetGiveItemByWeapon(w);
					if (key)
					{
						if (Left4Fun.BuyItems_Give[key].price <= money)
						{
							Left4Fun.SellAndGive(survivor, key);
							justBoughtWeapon = true;
						}
					}
					else
						print("ERROR: BotsBuyThink - GetGiveItemByWeapon(" + w + ") returned null!");
				}
			}
			else
				print("ERROR: BotsBuyThink - GetGiveItemByWeapon(" + w + ") returned null!");
		}
		
		// 2nd: try not to run out of ammo
		// If we just bought a weapon we'll do this the next time otherwise, if the previous weapon had < 6 bullets, we'll end up wasting money buying ammo for the new weapon
		if (!justBoughtWeapon && "slot0" in inventory && NetProps.GetPropIntArray(survivor, "m_iAmmo", NetProps.GetPropInt(inventory["slot0"], "m_iPrimaryAmmoType")) < 6 && Left4Fun.BuyItems_Give["ammo"].price <= money)
			Left4Fun.SellAndGive(survivor, "ammo");
			
		// 3rd: try to get a first aid kit but only if we need it or we already managed to get a level 2 primary weapon
		if (!("slot3" in inventory) && Left4Fun.BuyItems_Give["kit"].price <= money && (l > 1 || health < 50))
			Left4Fun.SellAndGive(survivor, "kit");

		// 4th: if our health is too low (< 20) we'll try to get the pain pills for quick healing
		// 5th: we also get them if we are in very good conditions (we already got a level 2 primary and a medkit, we can still afford ammo after this purchase, health is > 75 and we are calm)
		if (!("slot4" in inventory))
		{
			if ((health < 20 && Left4Fun.BuyItems_Give["pills"].price <= money) ||
				(l > 1 && ("slot3" in inventory) && (Left4Fun.BuyItems_Give["pills"].price + Left4Fun.BuyItems_Give["ammo"].price) <= money && survivor.GetHealth() > 75 && NetProps.GetPropInt(survivor, "m_isCalm") != 0))
				Left4Fun.SellAndGive(survivor, "pills");
		}
	  }
	}

	::Left4Fun.DoFindMapAreas <- function (args)
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "DoFindMapAreas");
		
		local areas = {};
		Left4Utils.FindMapAreas(areas);
		
	//	if (areas["checkpointA"])
	//		Left4Fun.Locations["checkpointA"] <- areas["checkpointA"].GetCenter();
		
		if (areas["checkpointB"])
			Left4Fun.Locations["checkpointB"] <- areas["checkpointB"].GetCenter();
		
		if (areas["finale"])
			Left4Fun.Locations["finale"] <- areas["finale"].GetCenter();
			
		if (areas["rescueVehicle"])
			Left4Fun.Locations["rescueVehicle"] <- areas["rescueVehicle"].GetCenter();
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "checkpointA: " + Left4Fun.Locations["checkpointA"]);
		Left4Fun.Log(LOG_LEVEL_DEBUG, "checkpointB: " + Left4Fun.Locations["checkpointB"]);
		Left4Fun.Log(LOG_LEVEL_DEBUG, "finale: " + Left4Fun.Locations["finale"]);
		Left4Fun.Log(LOG_LEVEL_DEBUG, "rescueVehicle: " + Left4Fun.Locations["rescueVehicle"]);
	}

	::Left4Fun.PingGlow <- function(params)
	{
		local ent = params["ent"];
		if (!ent || !ent.IsValid())
			return;
		
		NetProps.SetPropInt(ent, "m_Glow.m_iGlowType", 0);
	}

	::Left4Fun.SearchNearestPingTarget <- function(pos, normalRadius = 30, specialRadius = 100, weaponRadius = 50)
	{
		local ent = null;
		local ret = null;
		local dist1 = 1000000;
		local dist2 = 1000000;
		local survivor = null;
		
		
		// Special infected have the highest priority. I search the nearest one (if any) and save the nearest survivor for later
		while (ent = Entities.FindByClassnameWithin(ent, "player", pos, specialRadius))
		{
			if (ent.IsValid() && !ent.IsDead && !ent.IsDying())
			{
				local d = (ent.GetOrigin() - pos).Length();
				
				if (NetProps.GetPropInt(ent, "m_iTeamNum") == TEAM_INFECTED)
				{
					if (d < dist1)
					{
						ret = ent;
						dist1 = d;
						dist2 = d;
					}
				}
				else
				{
					if (d < dist2)
					{
						survivor = ent;
						dist2 = d;
					}
				}
			}
		}
		if (ret)
			return ret;
		
		// Witches are pretty much like special infected but with slightly lower priority since they aren't much of a threat if not startlet
		//ret = Entities.FindByClassnameNearest("witch", pos, specialRadius);
		ret = null;
		dist1 = 1000000;
		ent = null;
		while (ent = Entities.FindByClassnameWithin(ent, "witch", pos, specialRadius))
		{
			if (ent.IsValid() && NetProps.GetPropInt(ent, "m_lifeState") == 0)
			{
				local d = (ent.GetOrigin() - pos).Length();
				if (d < dist1)
				{
					ret = ent;
					dist1 = d;
				}
			}
		}
		if (ret)
			return ret;

		// Next in priority list are the weapons
		ret = null;
		dist1 = 1000000;
		ent = null;
		while (ent = Entities.FindByClassnameWithin(ent, "weapon_*", pos, weaponRadius))
		{
			if (ent.IsValid() && NetProps.GetPropInt(ent, "m_hOwner") <= 0)
			{
				local d = (ent.GetOrigin() - pos).Length();
				if (d < dist1)
				{
					ret = ent;
					dist1 = d;
				}
			}
		}
		if (ret)
			return ret;
		
		// Then the common infected
		//ret = Entities.FindByClassnameNearest("infected", pos, normalRadius);
		ret = null;
		dist1 = 1000000;
		ent = null;
		while (ent = Entities.FindByClassnameWithin(ent, "infected", pos, normalRadius))
		{
			if (ent.IsValid() && NetProps.GetPropInt(ent, "m_lifeState") == 0)
			{
				local d = (ent.GetOrigin() - pos).Length();
				if (d < dist1)
				{
					ret = ent;
					dist1 = d;
				}
			}
		}
		if (ret)
			return ret;

		// Survivors have the lowest priority
		if (survivor)
			return survivor;

		return null;
	}

	::Left4Fun.Ping <- function(player, duration = 7, duration_survivors = 3, duration_infected = 2.5, ignoreEnts = false, entGlow = true, cliSound = true, entSound = false)
	{
		if (!player || !player.IsValid())
			return;
		
		local team = NetProps.GetPropInt(player, "m_iTeamNum");
		
		local dur = duration;
		local ent = null;
		local pos = null;
		local isSpecial = false;
		
		if (ignoreEnts)
			pos = Left4Utils.GetLookingPosition(player);
		else
		{
			local looking = Left4Utils.GetLookingTargetEx(player);
			if (looking)
			{
				pos = looking["pos"] + Vector(0, 0, 20);
				ent = looking["ent"];
				
				if (!ent)
					ent = Left4Fun.SearchNearestPingTarget(looking["pos"]);
				
				if (ent)
				{
					local entClass = ent.GetClassname();
					if (entClass.find("weapon_") != null)
						pos = ent.GetCenter() + Vector(0, 0, 20);
					else if (entClass == "player")
					{
						pos = ent.GetCenter() + Vector(0, 0, 50);
						
						if (NetProps.GetPropInt(ent, "m_iTeamNum") == TEAM_INFECTED)
						{
							isSpecial = true;
							dur = duration_infected;
							
							if (NetProps.GetPropInt(ent, "m_zombieClass") == Z_TANK)
								pos += Vector(0, 0, 20);
						}
						else
							dur = duration_survivors;
					}
					else if (entClass == "witch")
					{
						pos = ent.GetCenter() + Vector(0, 0, 50);
						
						isSpecial = true;
						dur = duration_infected;
					}
					else if (entClass == "infected")
					{
						pos = ent.GetCenter() + Vector(0, 0, 50);
						dur = duration_infected;
					}
					else
						ent = null;
				}
			}
		}
		
		if (!pos)
			return;

		local tgtname = "ping_" + player.GetPlayerUserId();
		
		local previous = Entities.FindByName(null, tgtname);
		if (previous)
		{
			local scope = previous.GetScriptScope();
			if (scope.GlowEnt && scope.GlowEnt.IsValid())
			{
				NetProps.SetPropInt(scope.GlowEnt, "m_Glow.m_iGlowType", 0);
			
				if ("PingGlow_" + scope.GlowEnt.GetEntityIndex() in ::Left4Timers.Timers)
					Left4Timers.RemoveTimer("PingGlow_" + scope.GlowEnt.GetEntityIndex());
			}

			DoEntFire("!self", "Kill", "", 0, null, previous);
		}
		
		local tbl =
		{
			targetname = tgtname,
			spawnflags = 1,
			origin = pos,
			//rendermode = 2,
			rendermode = 0,
			rendercolor = "255 255 255",
			renderamt = 255,
			renderfx = 17,
			//scale = 0.5,
			scale = 1,
			framerate = 0.0,
			
			model = "vgui/hud/icon_arrow_plain.vmt"
			//model = "vgui/hud/icon_locator_generic.vmt"
			//model = "vgui/icon_download.vmt"
			//model = "vgui/scroll_down.vmt"
			//model = "effects/speech_voice.vmt"
			//model = "editor/scripted_sentence.vmt"
			//model = "editor/erroricon.vmt"
		};

		local sprite = SpawnEntityFromTable("env_sprite", tbl);
		NetProps.SetPropInt(sprite, "m_iTeamNum", team);

		sprite.ValidateScriptScope();
		local scope = sprite.GetScriptScope();
		scope.GlowEnt <- ent;

		DoEntFire("!self", "Kill", "", dur, null, sprite);

		if (ent && entGlow)
		{
			if ("PingGlow_" + ent.GetEntityIndex() in ::Left4Timers.Timers)
				Left4Timers.RemoveTimer("PingGlow_" + ent.GetEntityIndex());
			
			NetProps.SetPropInt(ent, "m_Glow.m_iGlowType", 3);
			
			Left4Timers.AddTimer("PingGlow_" + ent.GetEntityIndex(), dur, ::Left4Fun.PingGlow, { ent = ent }, false);
		}

		local sound = "EDIT_MARK.Enable";
		if (isSpecial)
			sound = "EDIT_MARK.Disable";
		
		//local sound = "EDIT_MARK.Enable";
		//local sound = "Instructor.LessonStart";
		//local sound = "Instructor.ImportantLessonStart";
		//local sound = "EDIT.ToggleAttribute";
		//local sound = "Event.NewAvailableZombie";
		//local sound = "Christmas.GiftDrop";
		//local sound = "Hint.Helpful";
		
		if (cliSound)
		{
			local client = null;
			while (client = Entities.FindByClassname(client, "player"))
			{
				if (!IsPlayerABot(client) && NetProps.GetPropInt(client, "m_iTeamNum") == team)
					EmitSoundOnClient(sound, client);
			}
		}	
		
		if (entSound)
			EmitSoundOn(sound, sprite);
	}
//}
