//------------------------------------------------------
//     Author : smilzo
//     https://steamcommunity.com/id/smilz0
//------------------------------------------------------

Msg("Including left4fun_commands...\n");

//if (!("HandleCommand" in ::Left4Fun))
//{
	::Left4Fun.HandleCommand <- function (player, cmd, args)
	{
		if (player == null || !player.IsValid() /*|| !Left4Fun.IsOnlineAdmin(player)*/)
			return;
			
		Left4Fun.Log(LOG_LEVEL_DEBUG, "Left4Fun.HandleCommand - " + player.GetPlayerName() + " - cmd: " + cmd + " - args: " + args.len());
			
		switch (cmd)
		{
			case "admins":
			{
				Left4Fun.CMD_admins(player, args);
				break;
			}
			case "bspawn":
			{
				Left4Fun.CMD_bspawn(player, args);
				break;
			}
			case "zspawn":
			{
				Left4Fun.CMD_zspawn(player, args);
				break;
			}
			case "help":
			{
				Left4Fun.CMD_help(player, args);
				break;
			}
			case "helpme":
			{
				Left4Fun.CMD_helpme(player, args);
				break;
			}
			case "money":
			{
				Left4Fun.CMD_money(player, args);
				break;
			}
			case "price":
			{
				Left4Fun.CMD_price(player, args);
				break;
			}
			case "buy":
			{
				Left4Fun.CMD_buy(player, args);
				break;
			}
			case "drop_money":
			{
				Left4Fun.CMD_drop_money(player, args);
				break;
			}
			case "give_money":
			{
				Left4Fun.CMD_give_money(player, args);
				break;
			}
			case "team":
			{
				Left4Fun.CMD_team(player, args);
				break;
			}
			case "next_infected":
			{
				Left4Fun.CMD_next_infected(player, args);
				break;
			}
			case "release_tank":
			{
				Left4Fun.CMD_release_tank(player, args);
				break;
			}		
			case "l4f_admin_init":
			{
				Left4Fun.CMD_l4f_admin_init(player, args); // TODO: remove and do it automatically like in L4B
				break;
			}
			case "settings":
			{
				Left4Fun.CMD_settings(player, args);
				break;
			}
			case "pcvar":
			{
				Left4Fun.CMD_pcvar(player, args);
				break;
			}
			case "pcvars":
			{
				Left4Fun.CMD_pcvars(player, args);
				break;
			}
			case "load_cvars":
			{
				Left4Fun.CMD_load_cvars(player, args);
				break;
			}
			case "speak_command":
			{
				Left4Fun.CMD_speak_command(player, args);
				break;
			}
			case "speak_scene":
			{
				Left4Fun.CMD_speak_scene(player, args);
				break;
			}
			case "trolls":
			{
				Left4Fun.CMD_trolls(player, args);
				break;
			}
			case "setprice":
			{
				Left4Fun.CMD_setprice(player, args);
				break;
			}
			case "force_buy":
			{
				Left4Fun.CMD_force_buy(player, args);
				break;
			}
			case "bank_amount":
			{
				Left4Fun.CMD_bank_amount(player, args);
				break;
			}
			case "botcmd":
			{
				Left4Fun.CMD_botcmd(player, args);
				break;
			}
			case "switchteam":
			{
				Left4Fun.CMD_switchteam(player, args);
				break;
			}
			case "setteam":
			{
				Left4Fun.CMD_setteam(player, args);
				break;
			}
			case "help_player":
			{
				Left4Fun.CMD_help_player(player, args);
				break;
			}
			case "end":
			{
				Left4Fun.CMD_end(player, args);
				break;
			}
			case "invisible":
			{
				Left4Fun.CMD_invisible(player, args);
				break;
			}
			case "activate_triggers":
			{
				Left4Fun.CMD_activate_triggers(player, args);
				break;
			}
			case "ping":
			{
				Left4Fun.CMD_ping(player, args);
				break;
			}
			case "ability_set":
			{
				Left4Fun.CMD_ability_set(player, args);
				break;
			}
			case "ability_start":
			{
				Left4Fun.CMD_ability_start(player, args);
				break;
			}
			case "ability_use":
			{
				Left4Fun.CMD_ability_use(player, args);
				break;
			}
			case "ability_stop":
			{
				Left4Fun.CMD_ability_stop(player, args);
				break;
			}
			default:
				//Left4Fun.Log(LOG_LEVEL_DEBUG, "OnUserCommand - Invalid cmd: " + cmd);
				
				if (Left4Fun.Settings.admin_commands)
					Left4Fun.HandleAdminCommand(player, cmd, args);
				break;
		}
	}

	// ------ USER COMMANDS --------

	::Left4Fun.CMD_help <- function (player, args)
	{
		if (Left4Fun.IsOnlineTroll(player))
			return;
		
		local command = Left4Fun.GetArg(0, args);
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_help from " + player.GetPlayerName() + " - command: " + command);
		
		switch (command)
		{
			case "helpme":
			{
				Left4Fun.PrintToPlayerChat(player, "Type '" + PRINTCOLOR_CYAN + "!helpme" + PRINTCOLOR_NORMAL + "' to help yourself if you are incapped/hanging (it takes one of your pain pills, adrenaline or medkit)", PRINTCOLOR_NORMAL);
				
				break;
			}
			case "money":
			{
				Left4Fun.PrintToPlayerChat(player, "If the money HUD is not active you can type '" + PRINTCOLOR_CYAN + "!money" + PRINTCOLOR_NORMAL + "' to see how many credits you have", PRINTCOLOR_NORMAL);
				
				break;
			}
			case "price":
			{
				Left4Fun.PrintToPlayerChat(player, "Type '" + PRINTCOLOR_CYAN + "!price item" + PRINTCOLOR_NORMAL + "' to see the cost of an item - " + PRINTCOLOR_CYAN + "Available items: " + PRINTCOLOR_ORANGE + "ammo, kit, defib, pills, adrenaline, molotov, pipe, bile, ak, m16, scar, spas, m4, hunting, sniper, sg, awp, scout, pump, chrome, ", PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, PRINTCOLOR_ORANGE + "silenced, smg, mp5, saw, gl, m60, pistol, magnum, axe, baseball, cricket, crowbar, frying, guitar, stick, golf, katana, machete, knife, shield, fork, shovel, incendiary, explosive, firework, oxygen, propane, gas, pile, laser, barrel, mg1, mg2", PRINTCOLOR_NORMAL);
				
				break;
			}
			case "buy":
			{
				Left4Fun.PrintToPlayerChat(player, "Type '" + PRINTCOLOR_CYAN + "!buy item" + PRINTCOLOR_NORMAL + "' to buy an item - " + PRINTCOLOR_CYAN + "Available items: " + PRINTCOLOR_ORANGE + "ammo, kit, defib, pills, adrenaline, molotov, pipe, bile, ak, m16, scar, spas, m4, hunting, sniper, sg, awp, scout, pump, chrome, ", PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, PRINTCOLOR_ORANGE + "silenced, smg, mp5, saw, gl, m60, pistol, magnum, axe, baseball, cricket, crowbar, frying, guitar, stick, golf, katana, machete, knife, shield, fork, shovel, incendiary, explosive, firework, oxygen, propane, gas, pile, laser, barrel, mg1, mg2", PRINTCOLOR_NORMAL);
				
				break;
			}
			case "drop_money":
			{
				Left4Fun.PrintToPlayerChat(player, "Type '" + PRINTCOLOR_CYAN + "!drop_money" + PRINTCOLOR_NORMAL + "' to drop 50 credits to the ground", PRINTCOLOR_NORMAL);
				
				break;
			}
			case "give_money":
			{
				Left4Fun.PrintToPlayerChat(player, "Type '" + PRINTCOLOR_CYAN + "!give_money target amount" + PRINTCOLOR_NORMAL + "' to give '" + PRINTCOLOR_CYAN + "amount" + PRINTCOLOR_NORMAL + "' credits to the '" + PRINTCOLOR_CYAN + "target" + PRINTCOLOR_NORMAL + "' survivor", PRINTCOLOR_NORMAL);
				
				break;
			}
			case "team":
			{
				Left4Fun.PrintToPlayerChat(player, "Type '" + PRINTCOLOR_CYAN + "!team" + PRINTCOLOR_NORMAL + "' to switch team", PRINTCOLOR_NORMAL);
				
				break;
			}
			case "next_infected":
			{
				Left4Fun.PrintToPlayerChat(player, "Type '" + PRINTCOLOR_CYAN + "!next_infected" + PRINTCOLOR_NORMAL + "' while in ghost mode to change infected type", PRINTCOLOR_NORMAL);
				
				break;
			}
			case "release_tank":
			{
				Left4Fun.PrintToPlayerChat(player, "Type '" + PRINTCOLOR_CYAN + "!release_tank" + PRINTCOLOR_NORMAL + "' to pass the control of the tank to the next player", PRINTCOLOR_NORMAL);
				
				break;
			}
			default:
			{
				local txt = "";
				
				if (Left4Fun.L4FCvars.helpme == ST_USER.ALL || (Left4Fun.L4FCvars.helpme == ST_USER.ADMINS && Left4Fun.IsOnlineAdmin(player)) || (Left4Fun.L4FCvars.helpme == ST_USER.USERS && !Left4Fun.IsOnlineAdmin(player)))
					txt = "helpme";
				
				if (Left4Fun.L4FCvars.money)
				{
					if (txt != "")
						txt += ", ";
					txt += "money, price, buy, drop_money, give_money";
				}
				
				if (HasPlayerControlledZombies())
				{
					if (txt != "")
						txt += ", ";
					txt += "team, next_infected, release_tank";
				}
				
				Left4Fun.PrintToPlayerChat(player, "Available commands: " + PRINTCOLOR_ORANGE + txt, PRINTCOLOR_NORMAL);
				Left4Fun.PrintToPlayerChat(player, "Type '" + PRINTCOLOR_CYAN + "!help command" + PRINTCOLOR_NORMAL + "' for more info", PRINTCOLOR_NORMAL);
				
				break;
			}
		}
	}

	::Left4Fun.CMD_helpme <- function (player, args)
	{
		local p = Left4Fun.GetSurvivor(player);
		if (!p)
			return;
		
		if (Left4Fun.IsOnlineTroll(p))
			return;
		
		if (Left4Fun.L4FCvars.helpme == ST_USER.ALL || (Left4Fun.L4FCvars.helpme == ST_USER.ADMINS && Left4Fun.IsOnlineAdmin(p)) || (Left4Fun.L4FCvars.helpme == ST_USER.USERS && !Left4Fun.IsOnlineAdmin(p)))
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_helpme from " + p.GetPlayerName());
			
			Left4Fun.SelfHelp(p);
		}
	}

	::Left4Fun.CMD_money <- function (player, args)
	{
		local p = Left4Fun.GetSurvivor(player);
		if (!p)
			return;
		
		if (Left4Fun.IsOnlineTroll(p))
			return;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_money from " + player.GetPlayerName());
		
		Left4Fun.PrintToPlayerChat(player, player.GetPlayerName() + ", you have " + Left4Fun.GetBankItemAmount(player, "money") + " credits", PRINTCOLOR_NORMAL);
	}

	::Left4Fun.CMD_price <- function (player, args)
	{
		local p = Left4Fun.GetSurvivor(player);
		if (!p)
			return;
		
		if (Left4Fun.IsOnlineTroll(p))
			return;
		
		local item = Left4Fun.GetArg(0, args);
		if (!item)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters. Type '!help price' for help", PRINTCOLOR_ORANGE);
			return;
		}
		item = item.tolower();
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_price from " + player.GetPlayerName() + " - item: " + item);
		
		local c = -1;
		local key = Left4Fun.GetSpawnItem(item);
		if (key)
			c = Left4Fun.BuyItems_Spawn[key];
		else
		{
			key = Left4Fun.GetGiveItem(item);
			if (key)
				c = Left4Fun.BuyItems_Give[key].price;
		}
		
		if (c < 0)
			Left4Fun.PrintToPlayerChat(player, "Item " + item + " not found, type '!help price' for the list of available items", PRINTCOLOR_ORANGE);
		else
			Left4Fun.PrintToPlayerChat(player, "Price for " + item + " is " + c + " credits", PRINTCOLOR_NORMAL);
	}

	::Left4Fun.CMD_buy <- function (player, args)
	{
		local p = Left4Fun.GetSurvivor(player);
		if (!p)
			return;
		
		if (Left4Fun.IsOnlineTroll(p))
			return;
		
		local item = Left4Fun.GetArg(0, args);
		if (!item)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters. Type '!help buy' for help", PRINTCOLOR_ORANGE);
			return;
		}
		item = item.tolower();
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_buy from " + player.GetPlayerName() + " - item: " + item);
		
		local c = -1;
		local key = Left4Fun.GetSpawnItem(item);
		if (key)
			c = Left4Fun.SellAndSpawn(player, key);
		else
		{
			key = Left4Fun.GetGiveItem(item);
			if (key)
				c = Left4Fun.SellAndGive(player, key);
		}
		
		if (c > 0)
			Left4Fun.PrintToPlayerChat(player, "Not enough money, item " + item + " costs " + c + " credits", PRINTCOLOR_ORANGE);
		else if (c < 0)
			Left4Fun.PrintToPlayerChat(player, "Item " + item + " not found, type '!help buy' for the list of available items", PRINTCOLOR_ORANGE);
	}

	::Left4Fun.CMD_drop_money <- function (player, args)
	{
		local p = Left4Fun.GetSurvivor(player);
		if (!p)
			return;
		
		if (Left4Fun.IsOnlineTroll(p))
			return;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_drop_money from " + player.GetPlayerName());
		
		local amount = Left4Fun.GetBankItemAmount(player, "money");
		amount = (amount >= 50) ? 50 : amount;
		if (amount > 0)
		{
			Left4Fun.SubBankItemAmount(player, "money", amount);
			local v = player.GetForwardVector();
			v.z = RandomFloat(2, 2.3);
			Left4Fun.SpawnL4FDrop(L4FPICKUP_MONEY_MODEL, L4FPICKUP_MONEY_PTYPE, amount, player.GetOrigin() + (v * 15) + Vector(0, 0, 50), player.GetAngles(), v * 150);
			
			Left4Fun.ChatNotice(player.GetPlayerName() + " dropped " + amount + " credits");
		}
		else
			Left4Fun.PrintToPlayerChat(player, "Not enough money", PRINTCOLOR_ORANGE);
	}

	::Left4Fun.CMD_give_money <- function (player, args)
	{
		local p = Left4Fun.GetSurvivor(player);
		if (!p)
			return;
		
		//if (Left4Fun.IsOnlineTroll(p))
		//	return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters. Type '!help give_money' for help", PRINTCOLOR_ORANGE);
			return;
		}

		local amount = Left4Fun.GetArg(1, args);
		if (!amount)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters. Type '!help give_money' for help", PRINTCOLOR_ORANGE);
			return;
		}
		amount = amount.tointeger();
		if (amount <= 0)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters. Type '!help give_money' for help", PRINTCOLOR_ORANGE);
			return;
		}

		local targets = Left4Fun.GetTargetPlayers(player, target, true);
		if (targets.len() <= 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No player found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_give_money from " + player.GetPlayerName() + " - target: " + target + " - amount: " + amount);
		
		if ((amount * targets.len()) > Left4Fun.GetBankItemAmount(player, "money"))
		{
			Left4Fun.PrintToPlayerChat(player, "Not enough money", PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (t in targets)
		{
			Left4Fun.SubBankItemAmount(player, "money", amount);
			Left4Fun.AddBankItemAmount(t, "money", amount);
		}
		Left4Fun.PrintToPlayerChat(player, "Done", PRINTCOLOR_GREEN);
	}

	::Left4Fun.CMD_team <- function (player, args)
	{
		if (Left4Fun.IsOnlineTroll(player))
			return;
		
		local team = Left4Fun.GetArg(0, args);
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_team from " + player.GetPlayerName() + " - team: " + team);
		
		if (!team)
		{
			if (NetProps.GetPropInt(player, "m_iTeamNum") == TEAM_SURVIVORS)
				team = "i";
			else
				team = "s";
		}
		else
			team = team.tolower();

		if (team == "infected" || team == "i" || team == "3")
			Left4Fun.SwitchTeam(player, 3);
		else if (team == "survivor" || team == "s" || team == "2")
			Left4Fun.SwitchTeam(player, 2);
	}

	::Left4Fun.CMD_next_infected <- function (player, args)
	{
		if (!player.IsGhost())
			return;
		
		if (Left4Fun.IsOnlineTroll(player))
			return;
		
		// TODO: if (Left4Fun.L4FCvars.todo == ST_USER.ALL || (Left4Fun.L4FCvars.todo == ST_USER.ADMINS && Left4Fun.IsOnlineAdmin(p)) || (Left4Fun.L4FCvars.todo == ST_USER.USERS && !Left4Fun.IsOnlineAdmin(p)))
		
		Left4Fun.DO_next_infected(player);
	}

	::Left4Fun.CMD_release_tank <- function (player, args)
	{
		if (player.GetZombieType() != Z_TANK)
			return;
		
		NetProps.SetPropInt(player, "m_frustration", 100);
	}

	// ------ ADMIN COMMANDS --------

	::Left4Fun.CMD_l4f_admin_init <- function (player, args)
	{
		Left4Fun.DoAdminInit(player);
	}

	::Left4Fun.CMD_admins <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;

		local cmd = Left4Fun.GetArg(0, args);
		if (!cmd)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		cmd = cmd.tolower();

		local target = Left4Fun.GetArg(1, args);
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_admins from " + player.GetPlayerName() + " - cmd: " + cmd + " - target: " + target);
		
		if (target)
		{
			target = Left4Utils.GetPlayerFromName(target);
			if (target && IsPlayerABot(target) && NetProps.GetPropInt(target, "m_humanSpectatorUserID") > 0)
				target = g_MapScript.GetPlayerFromUserID(NetProps.GetPropInt(target, "m_humanSpectatorUserID"));
			
			if (target && IsPlayerABot(target))
				target = null;
		}
		
		switch (cmd)
		{
			case "add":
			{
				if (!target)
				{
					Left4Fun.PrintToPlayerChat(player, "Invalid target", PRINTCOLOR_ORANGE);
					return;
				}
				
				local steamid = target.GetNetworkIDString();
				if (!steamid)
				{
					Left4Fun.PrintToPlayerChat(player, "Invalid target", PRINTCOLOR_ORANGE);
					return;
				}
				
				if (steamid in Left4Fun.Admins)
				{
					Left4Fun.PrintToPlayerChat(player, "Player is already in admins list", PRINTCOLOR_ORANGE);
					return;
				}
				
				Left4Fun.Admins[steamid] <- target.GetPlayerName();
				Left4Utils.SaveAdminsToFile("left4fun/cfg/" + Left4Fun.BaseName + "_admins.txt", ::Left4Fun.Admins);
				
				Left4Fun.PrintToPlayerChat(player, "Admin added", PRINTCOLOR_GREEN);
				
				local userid = target.GetPlayerUserId();
				userid = userid.tointeger();
				if (Left4Fun.OnlineAdmins.find(userid) == null)
				{
					Left4Fun.Log(LOG_LEVEL_DEBUG, "Adding admin with userid: " + userid);
				
					Left4Fun.OnlineAdmins.push(userid);
					Left4Fun.OnlineAdmins.sort();
					
					Left4Fun.PrintToPlayerChat(target, "You have been added to the online admins list", PRINTCOLOR_GREEN);
				}
				
				break;
			}
			case "remove":
			{
				if (!target)
				{
					Left4Fun.PrintToPlayerChat(player, "Invalid target", PRINTCOLOR_ORANGE);
					return;
				}
				
				local steamid = target.GetNetworkIDString();
				if (!steamid)
				{
					Left4Fun.PrintToPlayerChat(player, "Invalid target", PRINTCOLOR_ORANGE);
					return;
				}
				
				if (!(steamid in Left4Fun.Admins))
				{
					Left4Fun.PrintToPlayerChat(player, "Player is not in admins list", PRINTCOLOR_ORANGE);
					return;
				}
				
				delete ::Left4Fun.Admins[steamid];
				Left4Utils.SaveAdminsToFile("left4fun/cfg/" + Left4Fun.BaseName + "_admins.txt", ::Left4Fun.Admins);
				
				Left4Fun.PrintToPlayerChat(player, "Admin removed", PRINTCOLOR_GREEN);
				
				if (GetListenServerHost() != target)
				{
					local userid = target.GetPlayerUserId();
					userid = userid.tointeger();
					local idx = Left4Fun.OnlineAdmins.find(userid);
					if (idx != null)
					{
						Left4Fun.OnlineAdmins.remove(idx);
						Left4Fun.Log(LOG_LEVEL_DEBUG, "OnlineAdmin removed with idx: " + idx);
						
						Left4Fun.PrintToPlayerChat(target, "You have been removed from the online admins list", PRINTCOLOR_ORANGE);
					}
				}
				
				break;
			}
			default:
			{
				local humanPlayers = ::Left4Utils.GetHumanPlayers();
				if (!humanPlayers)
				{
					Left4Fun.PrintToPlayerChat(player, "No human player found!", PRINTCOLOR_ORANGE);
					return;
				}
				
				local adminNames = null;
				foreach (human in humanPlayers)
				{
					if (human)
					{
						local steamid = human.GetNetworkIDString();
						if (steamid && (steamid in Left4Fun.Admins))
						{
							if (!adminNames)
								adminNames = human.GetPlayerName();
							else
								adminNames += ", " + human.GetPlayerName();
						}
					}
				}
				
				if (!adminNames)
					Left4Fun.PrintToPlayerChat(player, "No admin online", PRINTCOLOR_NORMAL);
				else
					Left4Fun.PrintToPlayerChat(player, "Admins online: " + adminNames, PRINTCOLOR_NORMAL);
				
				break;
			}
		}
	}

	::Left4Fun.CMD_settings <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local setting = Left4Fun.GetArg(0, args);
		if (!setting)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}

		setting = setting.tolower();
		
		local value = Left4Fun.GetArg(1, args);
		if (!value)
			value = "";

		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_settings from " + player.GetPlayerName() + " - " + setting + " = " + value);

		Left4Fun.ChangeSetting(setting, value, player);
	}

	// for persistent cvars
	::Left4Fun.CMD_pcvar <- function (player, args)
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
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_pcvar from " + player.GetPlayerName() + " - varName: " + varName + " - varValue: " + varValue);
		
		if (varValue)
		{
			if (varName.find("l4f_") == 0)
				Left4Fun.SetL4FCvar(varName, varValue);
			else
				Convars.SetValue(varName, varValue);
			
			Left4Fun.PersistentCVars[varName] <- varValue;
			Left4Fun.SavePersistentCVars();
			
			Left4Fun.PrintToPlayerChat(player, "Done", PRINTCOLOR_GREEN);
		}
		else
		{
			if (varName in Left4Fun.PersistentCVars)
				Left4Fun.PrintToPlayerChat(player, "PCVAR: " + varName + " = " + Left4Fun.PersistentCVars[varName], PRINTCOLOR_NORMAL);
			else
				Left4Fun.PrintToPlayerChat(player, "PCVAR not found: " + varName, PRINTCOLOR_ORANGE);
		}
	}

	// for persistent cvars
	::Left4Fun.CMD_pcvars <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local cmd = Left4Fun.GetArg(0, args);
		local cvar = Left4Fun.GetArg(1, args);
		
		if (!cmd)
			cmd = "list";
		
		if ((cmd == "d" || cmd == "delete") && !cvar)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_pcvars from " + player.GetPlayerName() + " - cmd: " + cmd + " - cvar: " + cvar);
		
		if (cmd == "c" || cmd == "clear")
		{
			Left4Fun.PersistentCVars <- {};
			Left4Fun.SavePersistentCVars();
			
			Left4Fun.PrintToPlayerChat(player, "PCVARS cleared", PRINTCOLOR_GREEN);
		}
		else if (cmd == "d" || cmd == "delete")
		{
			if (cvar in Left4Fun.PersistentCVars)
			{
				delete ::Left4Fun.PersistentCVars[cvar];
				Left4Fun.SavePersistentCVars();
				
				Left4Fun.PrintToPlayerChat(player, "PCVAR " + cvar + " deleted", PRINTCOLOR_GREEN);
			}
			else
				Left4Fun.PrintToPlayerChat(player, "PCVAR " + cvar + " not found", PRINTCOLOR_ORANGE);
		}
		else
		{
			foreach (cvar, value in Left4Fun.PersistentCVars)
				Left4Fun.PrintToPlayerChat(player, "[PCVARS] " + cvar + " = " + value, PRINTCOLOR_NORMAL);
			
			Left4Fun.PrintToPlayerChat(player, "End of persistent cvars", PRINTCOLOR_NORMAL);
		}
	}

	::Left4Fun.CMD_load_cvars <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local fileName = Left4Fun.GetArg(0, args);
		if (!fileName)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}

		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_load_cvars from " + player.GetPlayerName() + " - fileName: " + fileName);

		Left4Fun.Log(LOG_LEVEL_DEBUG, "Loading cvars from " + fileName);
		local n = Left4Fun.LoadCvars(fileName);
		
		Left4Fun.PrintToPlayerChat(player, "Loaded " + n + " cvars from " + fileName, PRINTCOLOR_GREEN);
	}

	::Left4Fun.CMD_bspawn <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local location = Left4Utils.GetLookingPosition(player);
		local angles = QAngle(0, 0, 0);
		
		local botCharacter = Left4Fun.GetArg(0, args);
		if (!botCharacter)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		botCharacter = botCharacter.tolower();
		
		local l4d1behavior = Left4Fun.GetArg(1, args);
		if (!l4d1behavior)
			l4d1behavior = false;
		else
			l4d1behavior = true;
		
		local newChar = Left4Fun.GetArg(2, args);
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_bspawn from " + player.GetPlayerName() + " - botCharacter: " + botCharacter + " - l4d1behavior: " + l4d1behavior + " - newChar: " + newChar);
		
		if (botCharacter == "zoey" && newChar == null)
			Left4Fun.SpawnSurvivor(botCharacter, location, angles, TEAM_SURVIVORS, l4d1behavior, 9);
		else
			Left4Fun.SpawnSurvivor(botCharacter, location, angles, TEAM_SURVIVORS, l4d1behavior, newChar);
	}

	::Left4Fun.CMD_zspawn <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local infectedType = Left4Fun.GetArg(0, args);
		if (!infectedType)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		local amount = Left4Fun.GetArg(1, args);
		if (!amount)
			amount = 1;
		else
			amount = amount.tointeger();
		local location = Left4Utils.GetLookingPosition(player);
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_zspawn from " + player.GetPlayerName() + " - infectedType: " + infectedType + " - amount: " + amount);
		
		for (local i = 0; i < amount; i++)
		{
			if (infectedType == "common")
				Left4Utils.SpawnInfected(Z_COMMON, location);
			else if (infectedType == "smoker" )
				Left4Utils.SpawnInfected(Z_SMOKER, location);
			else if (infectedType == "boomer" )
				Left4Utils.SpawnInfected(Z_BOOMER, location);
			else if (infectedType == "leaker")
				Left4Utils.SpawnLeaker(location );
			else if (infectedType == "hunter")
				Left4Utils.SpawnInfected(Z_HUNTER, location);
			else if (infectedType == "spitter")
				Left4Utils.SpawnInfected(Z_SPITTER, location);
			else if (infectedType == "jockey")
				Left4Utils.SpawnInfected(Z_JOCKEY, location);
			else if (infectedType == "charger")
				Left4Utils.SpawnInfected(Z_CHARGER, location);
			else if (infectedType == "witch")
				Left4Utils.SpawnInfected(Z_WITCH, location);
			else if (infectedType == "tank")
				Left4Utils.SpawnInfected(Z_TANK, location, QAngle(0,0,0), true);
			else if (infectedType == "mob")
				Left4Utils.SpawnInfected(Z_MOB, location);
			else if (infectedType == "witch_bride")
				Left4Utils.SpawnInfected(Z_WITCH_BRIDE, location);
			else if (infectedType == "random")
			{
				local randomType = RandomInt(0, 11);
				
				if (randomType == Z_SURVIVOR)
					randomType = Z_COMMON;
				
				Left4Utils.SpawnInfected(randomType, location, QAngle(0,0,0), true);
			}
		}
	}

	::Left4Fun.CMD_end <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_end from " + player.GetPlayerName());
		
		Left4Utils.EndCampaign();
	}

	// Ex: PlayerLaugh
	::Left4Fun.CMD_speak_command <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		local command = Left4Fun.GetArg(1, args);
		
		if (!target || !command)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_speak_command from " + player.GetPlayerName() + " - target: " + target + " - command: " + command);
		
		local targetPlayers = Left4Fun.GetTargetPlayers(player, target, true);
		if (targetPlayers.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No players found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (targetPlayer in targetPlayers)
		{
			if (targetPlayer)
				DoEntFire("!self", "SpeakResponseConcept", command, 0, null, targetPlayer);
		}
	}

	// Ex: "scenes/TeenGirl/DLC1_C6M3_L4D1FinaleCinematic15.vcd" or just "DLC1_C6M3_L4D1FinaleCinematic15"
	::Left4Fun.CMD_speak_scene <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		local scene = Left4Fun.GetArg(1, args);
		
		if (!target || !scene)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_speak_scene from " + player.GetPlayerName() + " - target: " + target + " - scene: " + scene);
		
		local targetPlayers = Left4Fun.GetTargetPlayers(player, target, true);
		if (targetPlayers.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No players found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (targetPlayer in targetPlayers)
		{
			if (targetPlayer)
				Left4Utils.SpeakScene(targetPlayer, scene);
		}
	}

	::Left4Fun.CMD_trolls <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;

		local cmd = Left4Fun.GetArg(0, args);
		if (!cmd)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		cmd = cmd.tolower();

		local target = Left4Fun.GetArg(1, args);
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_trolls from " + player.GetPlayerName() + " - cmd: " + cmd + " - target: " + target);
		
		if (target)
		{
			target = Left4Utils.GetPlayerFromName(target);
			if (target && IsPlayerABot(target) && NetProps.GetPropInt(target, "m_humanSpectatorUserID") > 0)
				target = g_MapScript.GetPlayerFromUserID(NetProps.GetPropInt(target, "m_humanSpectatorUserID"));
			
			if (target && IsPlayerABot(target))
				target = null;
		}
		
		switch (cmd)
		{
			case "add":
			{
				if (!target)
				{
					Left4Fun.PrintToPlayerChat(player, "Invalid target", PRINTCOLOR_ORANGE);
					return;
				}
				
				local steamid = target.GetNetworkIDString();
				if (!steamid)
				{
					Left4Fun.PrintToPlayerChat(player, "Invalid target", PRINTCOLOR_ORANGE);
					return;
				}
				
				if (steamid in Left4Fun.Trolls)
				{
					Left4Fun.PrintToPlayerChat(player, "Player is already in trolls list", PRINTCOLOR_ORANGE);
					return;
				}
				
				Left4Fun.Trolls[steamid] <- target.GetPlayerName();
				Left4Utils.SaveAdminsToFile("left4fun/cfg/" + Left4Fun.BaseName + "_trolls.txt", ::Left4Fun.Trolls);
				
				Left4Fun.PrintToPlayerChat(player, "Troll added", PRINTCOLOR_GREEN);
				
				local userid = target.GetPlayerUserId();
				userid = userid.tointeger();
				if (Left4Fun.OnlineTrolls.find(userid) == null)
				{
					Left4Fun.Log(LOG_LEVEL_DEBUG, "Adding troll with userid: " + userid);
				
					Left4Fun.OnlineTrolls.push(userid);
					Left4Fun.OnlineTrolls.sort();
				}
				
				break;
			}
			case "remove":
			{
				if (!target)
				{
					Left4Fun.PrintToPlayerChat(player, "Invalid target", PRINTCOLOR_ORANGE);
					return;
				}
				
				local steamid = target.GetNetworkIDString();
				if (!steamid)
				{
					Left4Fun.PrintToPlayerChat(player, "Invalid target", PRINTCOLOR_ORANGE);
					return;
				}
				
				if (!(steamid in Left4Fun.Trolls))
				{
					Left4Fun.PrintToPlayerChat(player, "Player is not in trolls list", PRINTCOLOR_ORANGE);
					return;
				}
				
				delete ::Left4Fun.Trolls[steamid];
				Left4Utils.SaveAdminsToFile("left4fun/cfg/" + Left4Fun.BaseName + "_trolls.txt", ::Left4Fun.Trolls);
				
				Left4Fun.PrintToPlayerChat(player, "Troll removed", PRINTCOLOR_GREEN);
				
				local userid = target.GetPlayerUserId();
				userid = userid.tointeger();
				local idx = Left4Fun.OnlineTrolls.find(userid);
				if (idx != null)
				{
					Left4Fun.OnlineTrolls.remove(idx);
					Left4Fun.Log(LOG_LEVEL_DEBUG, "OnlineTroll removed with idx: " + idx);
				}
				
				break;
			}
			default:
			{
				local humanPlayers = ::Left4Utils.GetHumanPlayers();
				if (!humanPlayers)
				{
					Left4Fun.PrintToPlayerChat(player, "No human player found!", PRINTCOLOR_ORANGE);
					return;
				}
				
				local trollNames = null;
				foreach (human in humanPlayers)
				{
					if (human)
					{
						local steamid = human.GetNetworkIDString();
						if (steamid && (steamid in Left4Fun.Trolls))
						{
							if (!trollNames)
								trollNames = human.GetPlayerName();
							else
								trollNames += ", " + human.GetPlayerName();
						}
					}
				}
				
				if (!trollNames)
					Left4Fun.PrintToPlayerChat(player, "No troll online", PRINTCOLOR_NORMAL);
				else
					Left4Fun.PrintToPlayerChat(player, "Trolls online: " + trollNames, PRINTCOLOR_NORMAL);
				
				break;
			}
		}
	}

	::Left4Fun.CMD_setprice <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local item = Left4Fun.GetArg(0, args);
		if (!item)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}

		local price = Left4Fun.GetArg(1, args);
		if (!price)
			price = 0;
		else
			price = price.tointeger();
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_setprice from " + player.GetPlayerName() + " - item: " + item + " - price: " + price);
		
		local isSpawn = false;
		local key = Left4Fun.GetSpawnItem(item);
		if (key)
			isSpawn = true;
		else
			key = Left4Fun.GetGiveItem(item);
		
		if (!key)
		{
			Left4Fun.PrintToPlayerChat(player, "Item " + item + " not found in store", PRINTCOLOR_ORANGE);
			return;
		}
		
		if (price == 0)
		{
			if (isSpawn)
				price = Left4Fun.BuyItems_Spawn[key];
			else
				price = Left4Fun.BuyItems_Give[key].price;
			
			Left4Fun.PrintToPlayerChat(player, "Item price for " + key + " is " + price, PRINTCOLOR_NORMAL);
		}
		else
		{
			if (isSpawn)
				Left4Fun.BuyItems_Spawn[key] = price;
			else
				Left4Fun.BuyItems_Give[key].price = price;
			
			Left4Fun.SaveStore();
			
			Left4Fun.PrintToPlayerChat(player, "Item price for " + key + " changed to " + price, PRINTCOLOR_GREEN);
		}
	}

	::Left4Fun.CMD_force_buy <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}

		local item = Left4Fun.GetArg(1, args);
		if (!item)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		item = item.tolower();
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_force_buy from " + player.GetPlayerName() + " - target: " + target + " - item: " + item);
		
		local targetPlayers = Left4Fun.GetTargetPlayers(player, target, false);
		if (targetPlayers.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No players found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		local isSpawn = false;
		local key = Left4Fun.GetSpawnItem(item);
		if (key)
			isSpawn = true;
		else
			key = Left4Fun.GetGiveItem(item);
		
		if (!key)
		{
			Left4Fun.PrintToPlayerChat(player, "Item " + item + " not found in store", PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (t in targetPlayers)
		{
			if (isSpawn)
				Left4Fun.SellAndSpawn(t, key);
			else
				Left4Fun.SellAndGive(t, key);
		}
	}

	::Left4Fun.CMD_bank_amount <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}

		local item = Left4Fun.GetArg(1, args);
		if (!item)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		item = item.tolower();
		
		local amount = Left4Fun.GetArg(2, args);
		if (!amount)
			amount = 0;
		else
			amount = amount.tointeger();
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_bank_amount from " + player.GetPlayerName() + " - target: " + target + " - item: " + item + " - amount: " + amount);
		
		local targetPlayers = Left4Fun.GetTargetPlayers(player, target, false);
		if (targetPlayers.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No players found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		if (item != "money" && item != "gifts")
		{
			Left4Fun.PrintToPlayerChat(player, "Not a valid bank item: " + item, PRINTCOLOR_ORANGE);
			return;
		}
		
		if (amount == 0)
		{
			local str = "";
			foreach (t in targetPlayers)
			{
				if (str == "")
					str = t.GetPlayerName() + ": " + Left4Fun.GetBankItemAmount(t, item);
				else
					str += ", " + t.GetPlayerName()+ ": " + Left4Fun.GetBankItemAmount(t, item);
			}
			Left4Fun.PrintToPlayerChat(player, str);
		}
		else
		{
			foreach (t in targetPlayers)
				Left4Fun.SetBankItemAmount(t, item, amount);
			
			Left4Fun.PrintToPlayerChat(player, "Done", PRINTCOLOR_GREEN);
		}
	}

	::Left4Fun.CMD_botcmd <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local cmd = Left4Fun.GetArg(0, args);
		if (!cmd)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		cmd = cmd.tolower();

		local target = Left4Fun.GetArg(1, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		local other = Left4Fun.GetArg(2, args);
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_botcmd from " + player.GetPlayerName() + " - cmd: " + cmd + " - target: " + target + " - other: " + other);
		
		local targetBots = Left4Fun.GetTargetPlayers(player, target, false);
		if (targetBots.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No bots found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		if (other)
		{
			local others = Left4Fun.GetTargetPlayers(player, other, false);
			if (others.len() != 1)
			{
				Left4Fun.PrintToPlayerChat(player, "Unable to find a unique player entity with this name: " + other, PRINTCOLOR_ORANGE);
				return;
			}
			other = others[0];
		}
		
		//Director.ClearCachedBotQueries();
		
		switch (cmd)
		{
			case "move":
			{
				if (!other)
				{
					Left4Fun.PrintToPlayerChat(player, "Invalid destination", PRINTCOLOR_ORANGE);
					return;
				}
				
				foreach (target in targetBots)
				{
					//if (IsPlayerABot(target))
						CommandABot( { cmd = 1, pos = other.GetOrigin(), bot = target } );
				}
				
				break;
			}
			case "attack":
			{
				if (!other)
				{
					Left4Fun.PrintToPlayerChat(player, "Invalid victim", PRINTCOLOR_ORANGE);
					return;
				}
				
				foreach (target in targetBots)
				{
					//if (IsPlayerABot(target))
						CommandABot( { cmd = 0, target = other, bot = target } );
				}
				
				break;
			}
			case "retreat":
			{
				if (!other)
				{
					Left4Fun.PrintToPlayerChat(player, "Invalid from", PRINTCOLOR_ORANGE);
					return;
				}
				
				foreach (target in targetBots)
				{
					//if (IsPlayerABot(target))
						CommandABot( { cmd = 2, target = other, bot = target } );
				}
				
				break;
			}
			default:
			{
				foreach (target in targetBots)
				{
					//if (IsPlayerABot(target))
						CommandABot( { cmd = 3, bot = target } );
				}
				
				break;
			}
			
			Left4Fun.PrintToPlayerChat(player, "Done", PRINTCOLOR_GREEN);
		}
	}

	::Left4Fun.CMD_switchteam <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		local team = Left4Fun.GetArg(1, args);
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_switchteam from " + player.GetPlayerName() + " - target: " + target + " - team: " + team);
		
		local targets = Left4Fun.GetTargetPlayers(player, target, false);
		if (targets.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No player found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (target in targets)
		{
			if (!IsPlayerABot(target))
			{
				local t = team;
				if (!t)
				{
					if (NetProps.GetPropInt(target, "m_iTeamNum") == TEAM_SURVIVORS)
						t = "i";
					else
						t = "s";
				}
				else
					t = team.tolower();
				
				if (t == "infected" || t == "i" || t == "3")
					Left4Fun.SwitchTeam(target, 3);
				else if (t == "survivor" || t == "s" || t == "2")
					Left4Fun.SwitchTeam(target, 2);
			}
		}
		
		Left4Fun.PrintToPlayerChat(player, "Done", PRINTCOLOR_GREEN);
	}

	::Left4Fun.CMD_help_player <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_help_player from " + player.GetPlayerName() + " - target: " + target);
		
		local targets = Left4Fun.GetTargetPlayers(player, target, false);
		if (targets.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No player found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (target in targets)
			Left4Fun.HelpPlayer(target);
	}

	// TODO: remove
	::Left4Fun.CMD_setteam <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		local team = Left4Fun.GetArg(1, args);
		if (team == null)
			team = 0;
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_setteam from " + player.GetPlayerName() + " - target: " + target + " - team: " + team);
		
		local targets = Left4Fun.GetTargetPlayers(player, target, false);
		if (targets.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No player found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (target in targets)
			NetProps.SetPropInt(target, "m_iTeamNum", team.tointeger());
	}

	// TODO: remove
	::Left4Fun.CMD_invisible <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local target = Left4Fun.GetArg(0, args);
		if (!target)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		local sw = Left4Fun.GetArg(1, args);
		if (!sw)
			sw = "false";
		else
			sw = sw.tolower();
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_invisible from " + player.GetPlayerName() + " - target: " + target + " - sw: " + sw);
		
		local targets = Left4Fun.GetTargetPlayers(player, target, false);
		if (targets.len() == 0)
		{
			Left4Fun.PrintToPlayerChat(player, "No entity found matching the given target: " + target, PRINTCOLOR_ORANGE);
			return;
		}
		
		foreach (target in targets)
		{
			if (sw == "true" || sw == "on" || sw == "1")
			{
				ent.__KeyValueFromInt("rendermode", 1);
				//ent.__KeyValueFromInt("renderfx", 0);
				ent.__KeyValueFromString("rendercolor", "0 0 0 0");
			}
			else
			{
				ent.__KeyValueFromInt("rendermode", 0);
				//ent.__KeyValueFromInt("renderfx", 0);
				ent.__KeyValueFromString("rendercolor", "255 255 255 255");
			}
		}
	}

	// TODO: remove
	::Left4Fun.CMD_activate_triggers <- function (player, args)
	{
		if (!Left4Fun.IsOnlineAdmin(player))
			return;
		
		local map = SessionState.MapName.tolower();
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_activate_triggers from " + player.GetPlayerName() + " - map: " + map);
		
		if (map == "c7m3_port")
		{
			local b1 = Entities.FindByName(null, "finale_start_button");  // Starting generator
			local b2 = Entities.FindByName(null, "finale_start_button1"); // Starting generator
			local b3 = Entities.FindByName(null, "finale_start_button2"); // Starting generator
			local b4 = Entities.FindByName(null, "bridge_start_button");  // Bridge button
			local b5 = Entities.FindByName(null, "generator_button");     // Sacrifice generator
			
			local num = 3;
			if (!b1)
				num--;
			if (!b2)
				num--;
			if (!b3)
				num--;
			
			local bridge_start_button = b4 == null;
			local generator_button = b5 == null;
			
			Left4Fun.Log(LOG_LEVEL_DEBUG, "Generators to start: " + num + " - bridge button pressed: " + bridge_start_button);
			
			if (b1)
			{
				Left4Fun.EntInput("finale_start_button", "Kill");
				Left4Fun.EntInput("sound_generator_run", "PlaySound");
				Left4Fun.EntInput("generator_start_particles", "Start");
				Left4Fun.EntInput("generator_model2", "StopGlowing");
				Left4Fun.EntInput("mob_spawner_finale", "Enable"); // "OnPressed" "mob_spawner_finaleEnable0-1"
				Left4Fun.EntInput("radio_game_event_pre", "Kill");
				Left4Fun.EntInput("relay_advance_finale_state", "Trigger", 0, 2);
			}
			else if (b2)
			{
				Left4Fun.EntInput("finale_start_button1", "Kill");
				Left4Fun.EntInput("sound_generator_run1", "PlaySound");
				Left4Fun.EntInput("generator_start_particles1", "Start");
				Left4Fun.EntInput("generator_model1", "StopGlowing");
				Left4Fun.EntInput("mob_spawner_finale", "Enable"); // "OnPressed" "mob_spawner_finaleEnable0-1"
				Left4Fun.EntInput("radio_game_event_pre1", "Kill");
				Left4Fun.EntInput("relay_advance_finale_state", "Trigger", 0, 2);
			}
			else if (b3)
			{
				Left4Fun.EntInput("finale_start_button2", "Kill");
				Left4Fun.EntInput("sound_generator_run2", "PlaySound");
				Left4Fun.EntInput("generator_start_particles2", "Start");
				Left4Fun.EntInput("generator_model3", "StopGlowing");
				Left4Fun.EntInput("mob_spawner_finale", "Enable"); // "OnPressed" "mob_spawner_finaleEnable0-1"
				Left4Fun.EntInput("radio_game_event_pre2", "Kill");
				Left4Fun.EntInput("relay_advance_finale_state", "Trigger", 0, 2);
			}
			else if (!bridge_start_button)
				Left4Fun.EntInput("bridge_start_button", "Press");
			else if (b5)
			{
				Left4Fun.EntInput("generator_final_button_relay", "Trigger");
				Left4Fun.EntInput("sound_generator_run", "PlaySound");
				Left4Fun.EntInput("infected_spawner", "SpawnZombie");
				Left4Fun.EntInput("infected_spawner2", "SpawnZombie");
			}
		}
		else if (map == "TODO")
		{
		}
	}

	::Left4Fun.CMD_ping <- function (player, args)
	{
		if (player.IsDead() || player.IsDying())
			return;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_ping from " + player.GetPlayerName());
		
		Left4Fun.Ping(player);
	}

	Left4Fun.CMD_ability_set <- function (player, args)
	{
		if (!Left4Fun.L4FCvars.survivor_abilities)
			return;
		
		local abilityName = Left4Fun.GetArg(0, args);
		if (!abilityName)
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid parameters", PRINTCOLOR_ORANGE);
			return;
		}
		
		if (Left4Fun.IsOnlineAdmin(player))
		{
			local target = Left4Fun.GetArg(1, args);
			if (target)
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_ability_set from " + player.GetPlayerName() + " - ability: " + abilityName + " - target: " + target);
				
				local targets = Left4Fun.GetTargetPlayers(player, target, true);
				if (targets.len() == 0)
				{
					Left4Fun.PrintToPlayerChat(player, "No survivor found matching the given target: " + target, PRINTCOLOR_ORANGE);
					return;
				}
				
				local resetC = Left4Fun.GetArg(2, args);
				if (resetC && (resetC == "true" || resetC == "1"))
					resetC = true;
				else
					resetC = false;
				
				foreach (target in targets)
					SurvivorAbilities.SetPreferred(target, abilityName, resetC);
				
				Left4Fun.PrintToPlayerChat(player, "Done", PRINTCOLOR_GREEN);
				
				return;
			}
		}
		
		if (!Left4Fun.L4FCvars.survivor_abilities_allow_cmds || !Left4Fun.L4FCvars.survivor_abilities_allow_set || player.IsDead() || player.IsDying() || NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS)
			return;
			
		if (!Left4Fun.IsInSafeSpot(player))
		{
			Left4Fun.PrintToPlayerChat(player, "You must be in a safe spot to set your ability", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_ability_set from " + player.GetPlayerName() + " - ability: " + abilityName);
		
		if (!SurvivorAbilities.SetPreferred(player, abilityName))
		{
			Left4Fun.PrintToPlayerChat(player, "Invalid ability", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.PrintToPlayerChat(player, "Done", PRINTCOLOR_GREEN);
	}

	Left4Fun.CMD_ability_start <- function (player, args)
	{
		if (!Left4Fun.L4FCvars.survivor_abilities)
			return;
		
		if (Left4Fun.IsOnlineAdmin(player))
		{
			local target = Left4Fun.GetArg(0, args);
			if (target)
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_ability_start from " + player.GetPlayerName() + " - target: " + target);
				
				local targets = Left4Fun.GetTargetPlayers(player, target, true);
				if (targets.len() == 0)
				{
					Left4Fun.PrintToPlayerChat(player, "No survivor found matching the given target: " + target, PRINTCOLOR_ORANGE);
					return;
				}
				
				foreach (target in targets)
				{
					if (!target.IsDead() && !target.IsDying() && (!Left4Fun.L4FCvars.survivor_abilities_removeonincap || (!target.IsIncapacitated() && !target.IsHangingFromLedge())) /*&& !Left4Fun.IsInSafeSpot(target)*/)
					{
						if (SurvivorAbilities.AddPreferredAbility(target) && Left4Fun.L4FCvars.survivor_abilities_notifications)
							Left4Fun.PrintToPlayerChat(target, "Ability started", PRINTCOLOR_GREEN);
					}
				}
				
				Left4Fun.PrintToPlayerChat(player, "Done", PRINTCOLOR_GREEN);
				
				return;
			}
		}
		
		if (!Left4Fun.L4FCvars.survivor_abilities_allow_cmds || player.IsDead() || player.IsDying() || (Left4Fun.L4FCvars.survivor_abilities_removeonincap && (player.IsIncapacitated() || player.IsHangingFromLedge())) || NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS)
			return;
		
		if (Left4Fun.IsInSafeSpot(player))
		{
			Left4Fun.PrintToPlayerChat(player, "You must leave the safe spot first", PRINTCOLOR_ORANGE);
			return;
		}
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_ability_start from " + player.GetPlayerName());
		
		local cooldown = SurvivorAbilities.GetSurvivorCooldown(player);
		if (cooldown <= 0.0)
		{
			if (SurvivorAbilities.AddPreferredAbility(player) && Left4Fun.L4FCvars.survivor_abilities_notifications)
				Left4Fun.PrintToPlayerChat(player, "Ability started", PRINTCOLOR_GREEN);
		}
		else
			Left4Fun.PrintToPlayerChat(player, "Ability is in cooldown. Seconds remaining: " + ceil(cooldown), PRINTCOLOR_ORANGE);
	}

	Left4Fun.CMD_ability_use <- function (player, args)
	{
		if (!Left4Fun.L4FCvars.survivor_abilities)
			return;
		
		if (Left4Fun.IsOnlineAdmin(player))
		{
			local target = Left4Fun.GetArg(0, args);
			if (target)
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_ability_use from " + player.GetPlayerName() + " - target: " + target);
				
				local targets = Left4Fun.GetTargetPlayers(player, target, true);
				if (targets.len() == 0)
				{
					Left4Fun.PrintToPlayerChat(player, "No survivor found matching the given target: " + target, PRINTCOLOR_ORANGE);
					return;
				}
				
				foreach (target in targets)
				{
					if (!target.IsDead() && !target.IsDying() && !target.IsIncapacitated() && !target.IsHangingFromLedge())
						SurvivorAbilities.UseAbility(target);
				}
				
				//Left4Fun.PrintToPlayerChat(player, "Done", PRINTCOLOR_GREEN);
				
				return;
			}
		}
		
		if (player.IsDead() || player.IsDying() || player.IsIncapacitated() || player.IsHangingFromLedge() || NetProps.GetPropInt(player, "m_iTeamNum") != TEAM_SURVIVORS)
			return;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_ability_use from " + player.GetPlayerName());
		
		SurvivorAbilities.UseAbility(player);
	}

	Left4Fun.CMD_ability_stop <- function (player, args)
	{
		//if (!Left4Fun.L4FCvars.survivor_abilities)
		//	return;
		
		if (Left4Fun.IsOnlineAdmin(player))
		{
			local target = Left4Fun.GetArg(0, args);
			if (target)
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_ability_stop from " + player.GetPlayerName() + " - target: " + target);
				
				local targets = Left4Fun.GetTargetPlayers(player, target, true);
				if (targets.len() == 0)
				{
					Left4Fun.PrintToPlayerChat(player, "No survivor found matching the given target: " + target, PRINTCOLOR_ORANGE);
					return;
				}
				
				foreach (target in targets)
				{
					if (SurvivorAbilities.RemoveAbility(target) && Left4Fun.L4FCvars.survivor_abilities_notifications)
						Left4Fun.PrintToPlayerChat(target, "Ability stopped", PRINTCOLOR_ORANGE);
				}
				
				Left4Fun.PrintToPlayerChat(player, "Done", PRINTCOLOR_GREEN);
				
				return;
			}
		}
		
		if (!Left4Fun.L4FCvars.survivor_abilities_allow_cmds)
			return;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, "CMD_ability_stop from " + player.GetPlayerName());
		
		if (SurvivorAbilities.RemoveAbility(player) && Left4Fun.L4FCvars.survivor_abilities_notifications)
			Left4Fun.PrintToPlayerChat(player, "Ability stopped", PRINTCOLOR_ORANGE);
	}
//}
