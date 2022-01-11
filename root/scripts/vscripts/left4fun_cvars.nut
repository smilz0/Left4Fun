//------------------------------------------------------
//     Author : smilzo
//     https://steamcommunity.com/id/smilz0
//------------------------------------------------------

Msg("Including left4fun_cvars...\n");

if (!("L4FCvarsBak" in getroottable()))
	::L4FCvarsBak <- {};

//if (!("L4FCvars" in ::Left4Fun))
//{
	::Left4Fun.L4FCvars <-
	{
		helpme = ST_USER.NONE
		helpme_auto_health = -10
		autorespawn = ST_USER.NONE
		autorespawn_delay = 8
		utils_restore_interval = 15
		utils_max_restores = 0
		utils_restore_interval_adm = 10
		utils_max_restores_adm = 0
		adrenalineboost = ST_USER.NONE
		adrenalineboost_health = 10
		adrenalineboost_duration = 10
		adrenalineboost_duration_onrevive = 5
		tank_clones = 0
		witch_clones = 0
		health_onnewchapter = 0
		chat_notices = 0
		user_hints = 0
		supershove = ST_USER.NONE
		supershove_type = CV_SUPERSHOVETYPE.STAGGER
		supershove_onadmin = 0
		superjump = ST_USER.NONE
		money = 0
		money_hud = 0
		money_reset = 0
		money_replacepickups = 1
		gungame = 0
		zombiedrops = 0
		zombiedrops_onplayer = 0
		charger_steer_humans = 0
		charger_steer_bots = 0
		timed_notice = ""
		timed_notice_interval = 0
		remove_pistol_onincap = 0
		gl_airborn_push_force = 0
		m60_airborn_push_force = 0
		render_mode = {}
		render_fx = {}
		render_color = {}
		render_hasCommon = false
		disable_ledge_hang = 0
		survivor_abilities = 0
		survivor_abilities_hud = 0
		survivor_abilities_removeonincap = 1
		survivor_abilities_add_onspawn = 0
		survivor_abilities_notifications = 1
	}

	::Left4Fun.PersistentCVars <- {}

	::Left4Fun.LoadCvars <- function (file, persistent = false)
	{
		local count = 0;
		local fileContents = FileToString(file);
		if (fileContents == null)
		{
			Left4Fun.Log(LOG_LEVEL_WARN, "Cvars file does not exist: " + file);
			return count;
		}

		local cvars = split(fileContents, "\r\n");
		foreach (cvar in cvars)
		{
			//Left4Fun.Log(LOG_LEVEL_DEBUG, cvar);
			cvar = Left4Utils.StringReplace(cvar, "\\t", "");
			cvar = Left4Utils.StripComments(cvar);
			if (cvar && cvar != "")
			{
				cvar = strip(cvar);
				//Left4Fun.Log(LOG_LEVEL_DEBUG, cvar);
			
				if (cvar && cvar != "")
				{
					local idx = cvar.find(" ");
					if (idx != null)
					{
						local command = cvar.slice(0, idx);
						command = Left4Utils.StringReplace(command, "\"", "");
						command = strip(command);
						//Left4Fun.Log(LOG_LEVEL_DEBUG, command);
						
						local value = cvar.slice(idx + 1);
						value = Left4Utils.StringReplace(value, "\"", "");
						value = strip(value);
						//Left4Fun.Log(LOG_LEVEL_DEBUG, value);
						//Left4Fun.Log(LOG_LEVEL_DEBUG, "CVAR: " + command + " " + value);
						
						if (command.find("l4f_") == 0)
						{
							if (Left4Fun.SetL4FCvar(command, value))
							{
								count++;
								
								if (persistent)
									Left4Fun.PersistentCVars[command] <- value;
							}
							else
							{
								if (command == "l4f_include")
								{
									local includeFileName = "left4fun/mods/" + value + ".txt";
									Left4Fun.Log(LOG_LEVEL_DEBUG, "Loading cvars from include file: " + includeFileName);
									
									count += Left4Fun.LoadCvars(includeFileName);
								}
								else if (command == "l4f_weapontoconvert")
								{
									local convert = split(value, ",");
									if (!convert || convert.len() != 2)
										Left4Fun.Log(LOG_LEVEL_WARN, "Invalid format for l4f_weapontoconvert: " + value);
									else
									{
										local wFrom = strip(convert[0]).tolower();
										local wTo = strip(convert[1]);
														
										//Left4Fun.Log(LOG_LEVEL_DEBUG, "l4f_weapontoconvert: " + wFrom + " = " + wTo);
									
										Left4Fun.WeaponsToConvert[wFrom] <- wTo;
										count++;
									}
								}
								else if (command == "l4f_zombietoconvert")
								{
									local convert = split(value, ",");
									if (!convert || convert.len() != 2)
										Left4Fun.Log(LOG_LEVEL_WARN, "Invalid format for l4f_zombietoconvert: " + value);
									else
									{
										local wFrom = "z_" + strip(convert[0]).tolower();
										local wTo = strip(convert[1]);
										
										//Left4Fun.Log(LOG_LEVEL_DEBUG, "l4f_zombietoconvert: " + wFrom + " = " + wTo);
										
										Left4Fun.ZombiesToConvert[wFrom] <- wTo;
										count++;
									}
								}
								else if (command == "l4f_weapontoremove")
								{
									//Left4Fun.Log(LOG_LEVEL_DEBUG, "l4f_weapontoremove: " + value);
													
									Left4Fun.WeaponsToRemove.push(value);
									count++;
								}
								else if (command == "l4f_defaultitem")
								{
									//Left4Fun.Log(LOG_LEVEL_DEBUG, "l4f_defaultitem: " + value);
														
									Left4Fun.DefaultItems.push(value);
									count++;
								}
								else if (command == "l4f_sanitize")
								{
									//Left4Fun.Log(LOG_LEVEL_DEBUG, "l4f_sanitize: " + value);
														
									Left4Fun.SanitizeList.push(value.tolower());
									count++;
								}
							}
						}
						else if (command == BASENAME_CVAR)
							Left4Fun.Log(LOG_LEVEL_WARN, command + " cvar is reserved and hasn't been loaded");
						else
						{
							local allowed = false;
							foreach (str in Left4Fun.ExceptionsOnForbiddenCvarsOnLoad)
							{
								//Left4Fun.Log(LOG_LEVEL_DEBUG, "ExceptionsOnForbiddenCvarsOnLoad: " + str);
								
								local expression = regexp(str);
								if (expression.match(command))
								{
									allowed = true;
									break;
								}
							}
							if (!allowed)
							{
								allowed = true;
								foreach (str in Left4Fun.ForbiddenCvarsOnLoad)
								{
									//Left4Fun.Log(LOG_LEVEL_DEBUG, "ForbiddenCvarsOnLoad: " + str);
									
									local expression = regexp(str);
									if (expression.match(command))
									{
										allowed = false;
										break;
									}
								}
							}
											
							if (allowed)
							{
								if (!(command in ::L4FCvarsBak))
									L4FCvarsBak[command] <- Convars.GetStr(command); // Backup the vanilla value
								
								Convars.SetValue(command, value);
								count++;
								
								if (persistent)
									Left4Fun.PersistentCVars[command] <- value;
							}
							else
								Left4Fun.Log(LOG_LEVEL_WARN, command + " cvar is forbidden and hasn't been loaded");
						}
					}
				}
			}
		}
		
		if (persistent)
			Left4Fun.SavePersistentCVars();
		
		return count;
	}

	::Left4Fun.RestoreCvars <- function ()
	{
		if (L4FCvarsBak.len() <= 0)
			return;
		
		foreach (cvar, value in ::L4FCvarsBak)
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "RestoreCvars - cvar: " + cvar + " - value: " + value);
			
			Convars.SetValue(cvar, value);
		}
		Left4Fun.Log(LOG_LEVEL_INFO, "Restored " + L4FCvarsBak.len() + " cvars");
		
		L4FCvarsBak.clear();
	}

	::Left4Fun.SavePersistentCVars <- function ()
	{
		local fileContents = "";
		foreach (cvar, value in Left4Fun.PersistentCVars)
			fileContents += cvar + " " + value + "\n";
		
		StringToFile("left4fun/cfg/" + Left4Fun.BaseName + "_persistentcvars.txt", fileContents);
		
		Left4Fun.Log(LOG_LEVEL_INFO, "Persistent cvars saved");
	}

	::Left4Fun.SetL4FCvar <- function (cvar, value)
	{
		switch (cvar)
		{
			case "l4f_helpme":
				Left4Fun.L4FCvars.helpme = Left4Fun.String2ST_User(value);
				return true;
				
			case "l4f_helpme_auto_health":
				Left4Fun.L4FCvars.helpme_auto_health = value.tointeger();
				return true;

			case "l4f_autorespawn":
				Left4Fun.L4FCvars.autorespawn = Left4Fun.String2ST_User(value);
				return true;

			case "l4f_autorespawn_delay":
				Left4Fun.L4FCvars.autorespawn_delay = value.tofloat();
				return true;

			case "l4f_utils_restore_interval":
				Left4Fun.L4FCvars.utils_restore_interval = value.tofloat();
				return true;

			case "l4f_utils_max_restores":
				Left4Fun.L4FCvars.utils_max_restores = value.tointeger();
				return true;

			case "l4f_utils_restore_interval_adm":
				Left4Fun.L4FCvars.utils_restore_interval_adm = value.tofloat();
				return true;

			case "l4f_utils_max_restores_adm":
				Left4Fun.L4FCvars.utils_max_restores_adm = value.tointeger();
				return true;

			case "l4f_adrenalineboost":
				Left4Fun.L4FCvars.adrenalineboost = Left4Fun.String2ST_User(value);
				return true;

			case "l4f_supershove":
				Left4Fun.L4FCvars.supershove = Left4Fun.String2ST_User(value);
				return true;

			case "l4f_supershove_type":
				Left4Fun.L4FCvars.supershove_type = Left4Fun.String2CV_Supershovetype(value);
				return true;

			case "l4f_supershove_onadmin":
				Left4Fun.L4FCvars.supershove_onadmin = String2Bool(value);
				return true;

			case "l4f_superjump":
				Left4Fun.L4FCvars.superjump = Left4Fun.String2ST_User(value);
				return true;

			case "l4f_adrenalineboost_health":
				Left4Fun.L4FCvars.adrenalineboost_health = value.tointeger();
				return true;

			case "l4f_adrenalineboost_duration":
				Left4Fun.L4FCvars.adrenalineboost_duration = value.tofloat();
				return true;

			case "l4f_adrenalineboost_duration_onrevive":
				Left4Fun.L4FCvars.adrenalineboost_duration_onrevive = value.tofloat();
				return true;

			case "l4f_tank_clones":
				Left4Fun.L4FCvars.tank_clones = value.tointeger();
				return true;

			case "l4f_witch_clones":
				Left4Fun.L4FCvars.witch_clones = value.tointeger();
				return true;

			case "l4f_health_onnewchapter":
				Left4Fun.L4FCvars.health_onnewchapter = value.tointeger();
				return true;

			case "l4f_chat_notices":
				Left4Fun.L4FCvars.chat_notices = String2Bool(value);
				return true;

			case "l4f_user_hints":
				Left4Fun.L4FCvars.user_hints = String2Bool(value);
				return true;
				
			case "l4f_money":
				Left4Fun.L4FCvars.money = String2Bool(value);
				return true;
				
			case "l4f_money_hud":
				Left4Fun.L4FCvars.money_hud = String2Bool(value);
				
				Left4Fun.HideHud(null);
				if (Left4Fun.L4FCvars.money_hud)
					Left4Fun.ShowHud();
				
				return true;
				
			case "l4f_money_reset":
				Left4Fun.L4FCvars.money_reset = String2Bool(value);
				return true;
				
			case "l4f_money_replacepickups":
				Left4Fun.L4FCvars.money_replacepickups = String2Bool(value);
				return true;
				
			case "l4f_gungame":
				Left4Fun.L4FCvars.gungame = String2Bool(value);
				return true;
				
			case "l4f_zombiedrops":
				Left4Fun.L4FCvars.zombiedrops = String2Bool(value);
				return true;
				
			case "l4f_zombiedrops_onplayer":
				Left4Fun.L4FCvars.zombiedrops_onplayer = String2Bool(value);
				return true;
				
			case "l4f_charger_steer_humans":
				Left4Fun.L4FCvars.charger_steer_humans = String2Bool(value);
				return true;
				
			case "l4f_charger_steer_bots":
				Left4Fun.L4FCvars.charger_steer_bots = String2Bool(value);
				return true;
				
			case "l4f_timed_notice":
				Left4Fun.L4FCvars.timed_notice = value;
				return true;
				
			case "l4f_timed_notice_interval":
				Left4Fun.L4FCvars.timed_notice_interval = value.tofloat();
				return true;
				
			case "l4f_remove_pistol_onincap":
				Left4Fun.L4FCvars.remove_pistol_onincap = String2Bool(value);
				return true;
				
			case "l4f_gl_airborn_push_force":
				Left4Fun.L4FCvars.gl_airborn_push_force = value.tofloat();
				return true;
				
			case "l4f_m60_airborn_push_force":
				Left4Fun.L4FCvars.m60_airborn_push_force = value.tofloat();
				return true;
				
			case "l4f_disable_ledge_hang":
				Left4Fun.L4FCvars.disable_ledge_hang = String2Bool(value);
				return true;
				
			case "l4f_survivor_abilities":
				Left4Fun.L4FCvars.survivor_abilities = String2Bool(value);
				return true;
				
			case "l4f_survivor_abilities_hud":
				Left4Fun.L4FCvars.survivor_abilities_hud = String2Bool(value);
				return true;
				
			case "l4f_survivor_abilities_removeonincap":
				Left4Fun.L4FCvars.survivor_abilities_removeonincap = String2Bool(value);
				return true;
				
			case "l4f_survivor_abilities_add_onspawn":
				Left4Fun.L4FCvars.survivor_abilities_add_onspawn = String2Bool(value);
				return true;
				
			case "l4f_survivor_abilities_notifications":
				Left4Fun.L4FCvars.survivor_abilities_notifications = String2Bool(value);
				return true;
		}
		
		local idx = cvar.find("l4f_director.");
		if (idx == 0)
		{
			local dvar = cvar.slice(13);
			//Left4Fun.Log(LOG_LEVEL_DEBUG, "dvar: " + dvar);
			
			if ("GetDirectorOptions" in DirectorScript)
			{
				try
				{
					local compiledscript = compilestring("DirectorScript.GetDirectorOptions()." + dvar + " <- " + value);
					compiledscript();
				}
				catch(exception)
				{
					Left4Fun.Log(LOG_LEVEL_ERROR, exception);
					if (Left4Fun.Settings.loglevel >= LOG_LEVEL_ERROR)
						Left4Utils.PrintStackTrace();
				}
			}
			Left4Fun.DirectorVarsToLoad[dvar] <- value;
			
			return true;
		}
		else
		{
			idx = cvar.find("l4f_render.");
			if (idx == 0)
			{
				local rvar = cvar.slice(11);
				//Left4Fun.Log(LOG_LEVEL_DEBUG, "rvar: " + rvar);
				
				local args = split(rvar, ".");
				if (args && args.len() > 1)
				{
					local rvar = strip(args[0]);
					local key = strip(args[1]);
					
					if (rvar == "mode")
						Left4Fun.L4FCvars.render_mode[key] <- value;
					else if (rvar == "fx")
						Left4Fun.L4FCvars.render_fx[key] <- value;
					else if (rvar == "color")
						Left4Fun.L4FCvars.render_color[key] <- value;
					
					if (key == "common")
						Left4Fun.L4FCvars.render_hasCommon = true;
				}
				
				return true;
			}
		}
		
		return false;
	}

	::Left4Fun.GetL4FCvar <- function (cvar)
	{
		switch (cvar)
		{
			case "l4f_helpme":
				return ST_User2String(Left4Fun.L4FCvars.helpme);
				
			case "l4f_helpme_auto_health":
				return Left4Fun.L4FCvars.helpme_auto_health;

			case "l4f_autorespawn":
				return ST_User2String(Left4Fun.L4FCvars.autorespawn);

			case "l4f_autorespawn_delay":
				return Left4Fun.L4FCvars.autorespawn_delay;

			case "l4f_utils_restore_interval":
				return Left4Fun.L4FCvars.utils_restore_interval;

			case "l4f_utils_max_restores":
				return Left4Fun.L4FCvars.utils_max_restores;

			case "l4f_utils_restore_interval_adm":
				return Left4Fun.L4FCvars.utils_restore_interval_adm;

			case "l4f_utils_max_restores_adm":
				return Left4Fun.L4FCvars.utils_max_restores_adm;

			case "l4f_adrenalineboost":
				return ST_User2String(Left4Fun.L4FCvars.adrenalineboost);

			case "l4f_supershove":
				return ST_User2String(Left4Fun.L4FCvars.supershove);

			case "l4f_supershove_type":
				return CV_Supershovetype2String(Left4Fun.L4FCvars.supershove_type);

			case "l4f_supershove_onadmin":
				return Bool2String(Left4Fun.L4FCvars.supershove_onadmin);

			case "l4f_superjump":
				return ST_User2String(Left4Fun.L4FCvars.superjump);

			case "l4f_adrenalineboost_health":
				return Left4Fun.L4FCvars.adrenalineboost_health;

			case "l4f_adrenalineboost_duration":
				return Left4Fun.L4FCvars.adrenalineboost_duration;

			case "l4f_adrenalineboost_duration_onrevive":
				return Left4Fun.L4FCvars.adrenalineboost_duration_onrevive;

			case "l4f_tank_clones":
				return Left4Fun.L4FCvars.tank_clones;

			case "l4f_witch_clones":
				return Left4Fun.L4FCvars.witch_clones;

			case "l4f_health_onnewchapter":
				return Left4Fun.L4FCvars.health_onnewchapter;

			case "l4f_chat_notices":
				return Bool2String(Left4Fun.L4FCvars.chat_notices);

			case "l4f_user_hints":
				return Bool2String(Left4Fun.L4FCvars.user_hints);
				
			case "l4f_money":
				return Bool2String(Left4Fun.L4FCvars.money);
				
			case "l4f_money_hud":
				return Bool2String(Left4Fun.L4FCvars.money_hud);
				
			case "l4f_money_reset":
				return Bool2String(Left4Fun.L4FCvars.money_reset);
				
			case "l4f_money_replacepickups":
				return Bool2String(Left4Fun.L4FCvars.money_replacepickups);
				
			case "l4f_gungame":
				return Bool2String(Left4Fun.L4FCvars.gungame);
				
			case "l4f_zombiedrops":
				return Bool2String(Left4Fun.L4FCvars.zombiedrops);
				
			case "l4f_zombiedrops_onplayer":
				return Bool2String(Left4Fun.L4FCvars.zombiedrops_onplayer);
				
			case "l4f_charger_steer_humans":
				return Bool2String(Left4Fun.L4FCvars.charger_steer_humans);
				
			case "l4f_charger_steer_bots":
				return Bool2String(Left4Fun.L4FCvars.charger_steer_bots);
				
			case "l4f_timed_notice":
				return Left4Fun.L4FCvars.timed_notice;
				
			case "l4f_timed_notice_interval":
				return Left4Fun.L4FCvars.timed_notice_interval;
			
			case "l4f_remove_pistol_onincap":
				return Bool2String(Left4Fun.L4FCvars.remove_pistol_onincap);
			
			case "l4f_gl_airborn_push_force":
				return Left4Fun.L4FCvars.gl_airborn_push_force;
				
			case "l4f_m60_airborn_push_force":
				return Left4Fun.L4FCvars.m60_airborn_push_force;
			
			case "l4f_disable_ledge_hang":
				return Bool2String(Left4Fun.L4FCvars.disable_ledge_hang);
			
			case "l4f_survivor_abilities":
				return Bool2String(Left4Fun.L4FCvars.survivor_abilities);
				
			case "l4f_survivor_abilities_hud":
				return Bool2String(Left4Fun.L4FCvars.survivor_abilities_hud);
				
			case "l4f_survivor_abilities_removeonincap":
				return Bool2String(Left4Fun.L4FCvars.survivor_abilities_removeonincap);
				
			case "l4f_survivor_abilities_add_onspawn":
				return Bool2String(Left4Fun.L4FCvars.survivor_abilities_add_onspawn);
				
			case "l4f_survivor_abilities_notifications":
				return Bool2String(Left4Fun.L4FCvars.survivor_abilities_notifications);
		}
		
		local idx = cvar.find("l4f_director.");
		if (idx == 0)
		{
			local dvar = cvar.slice(13);
			//Left4Fun.Log(LOG_LEVEL_DEBUG, "dvar: " + dvar);
			
			Left4Fun.DirectorVar = null;
			
			try
			{
				local compiledscript = compilestring("Left4Fun.DirectorVar = DirectorScript.GetDirectorOptions()." + dvar);
				compiledscript();
			}
			catch(exception)
			{
				//Left4Fun.Log(LOG_LEVEL_ERROR, exception);
				//if (Left4Fun.Settings.loglevel >= LOG_LEVEL_ERROR)
				//	Left4Utils.PrintStackTrace();
			}
			
			if (Left4Fun.DirectorVar != null)
				return "" + Left4Fun.DirectorVar;
		}
		else
		{
			idx = cvar.find("l4f_render.");
			if (idx == 0)
			{
				local rvar = cvar.slice(11);
				//Left4Fun.Log(LOG_LEVEL_DEBUG, "rvar: " + rvar);
				
				local args = split(rvar, ".");
				if (args && args.len() > 1)
				{
					local rvar = strip(args[0]);
					local key = strip(args[1]);
					
					if (rvar == "mode")
					{
						if (key in ::Left4Fun.L4FCvars.render_mode)
							return "" + Left4Fun.L4FCvars.render_mode[key];
						else
							return null;
					}
					else if (rvar == "fx")
					{
						if (key in ::Left4Fun.L4FCvars.render_fx)
							return "" + Left4Fun.L4FCvars.render_fx[key];
						else
							return null;
					}
					else if (rvar == "color")
					{
						if (key in ::Left4Fun.L4FCvars.render_color)
							return "" + Left4Fun.L4FCvars.render_color[key];
						else
							return null;
					}
				}
			}
		}
		
		return null;
	}
//}
