//------------------------------------------------------
//     Author : smilzo
//     https://steamcommunity.com/id/smilz0
//------------------------------------------------------

Msg("Including survivor_abilities...\n");

::SurvivorAbilities <-
{
	AbilityTypes = {}
	CharacterDefaults = {}
	PreferredAbilities = {}
	Abilities = {}
	Cooldowns = {}
	LastCooldownUpdate = 0.0
	Events = {
		OnAbilityReady = {}
		OnAbilityUsedUp = {}
		OnAbilityExpired = {}
	}
}

class ::SurvivorAbilities.BaseAbility
{
	constructor(survivor)
	{
		_start_time = Time();
		_usage_amount = 0.0;
		
		local customVal = ::SurvivorAbilities.GetAbilityCooldown(ability_name);
		if (customVal >= 0)
			_ability_cooldown = customVal;
		else
			_ability_cooldown = ability_cooldown;
		
		customVal = ::SurvivorAbilities.GetAbilityMaxUsage(ability_name);
		if (customVal >= 0)
			_ability_maxusage = customVal;
		else
			_ability_maxusage = ability_maxusage;
		
		customVal = ::SurvivorAbilities.GetAbilityDuration(ability_name);
		if (customVal >= 0)
			_ability_duration = customVal;
		else
			_ability_duration = ability_duration;
		
		customVal = ::SurvivorAbilities.GetAbilityRange(ability_name);
		if (customVal >= 0)
			_ability_range = customVal;
		else
			_ability_range = ability_range;
			
		customVal = ::SurvivorAbilities.GetAbilityDamage(ability_name);
		if (customVal >= 0)
			_ability_damage = customVal;
		else
			_ability_damage = ability_damage;
			
		SetSurvivor(survivor);
		
		_ability_id = ability_name + "_" + _survivor_userid + "_" + UniqueString();
	}
	
	function _typeof()
	{
		return "SurvivorAbility";
	}
	
	function _tostring()
	{
		local s = "";
		if (_survivor && _survivor.IsValid())
			s = _survivor.GetPlayerName();
		
		return "SurvivorAbility { " + ability_type + " (" + ability_name + "), id: " + _ability_id + ", survivor: " + s + " (" + _survivor_userid + " - " + _surivor_character + "), cooldown: " + _ability_cooldown + ", maxusage: " + _ability_maxusage + ", duration: " + _ability_duration + ", range: " + _ability_range + ", damage: " + _ability_damage + " }";
	}
	
	function _cmp(other)
	{
		if (!other || (typeof other) != "SurvivorAbility" || !("_ability_id" in other))
			return -1;
		
		if (!other._ability_id || other._ability_id != _ability_id)
			return 1;
		
		return 0;
	}
	
	function GetAbilityID()
	{
		return _ability_id;
	}
	
	function GetSurvivor()
	{
		return _survivor;
	}
	
	function GetSurvivorUserID()
	{
		return _survivor_userid;
	}
	
	function GetSurvivorCharacter()
	{
		return _surivor_character;
	}
	
	function GetStartTime()
	{
		return _start_time;
	}
	
	function GetElapsedTime()
	{
		return Time() - _start_time;
	}
	
	function Use()
	{
		// Nothing to use here
	}
	
	function GetUsageAmount()
	{
		return _usage_amount;
	}
	
	function AddUsageAmount(amount)
	{
		_usage_amount += amount;
		
		Left4Fun.Log(LOG_LEVEL_DEBUG, _survivor.GetPlayerName() + " usage: " + _usage_amount + " (+" + amount + ")");
	}
	
	function SetSurvivor(survivor)
	{
		if (!survivor || !survivor.IsValid() || survivor.GetClassname() != "player")
			throw "Given parameter is not a valid player entity!";
		
		_survivor = survivor;
		_survivor_userid = survivor.GetPlayerUserId();
		_surivor_character = NetProps.GetPropInt(_survivor, "m_survivorCharacter");
	}
	
	function GetAbilityCooldown()
	{
		return _ability_cooldown;
	}
	
	function SetAbilityCooldown(cooldnown)
	{
		_ability_cooldown = cooldnown;
	}
	
	function GetAbilityMaxUsage()
	{
		return _ability_maxusage;
	}
	
	function SetAbilityMaxUsage(maxusage)
	{
		_ability_maxusage = maxusage;
	}
	
	function GetAbilityDuration()
	{
		return _ability_duration;
	}
	
	function SetAbilityDuration(duration)
	{
		_ability_duration = duration;
	}
	
	function GetAbilityRange()
	{
		return _ability_range;
	}
	
	function SetAbilityRange(range)
	{
		_ability_range = range;
	}
	
	function GetAbilityDamage()
	{
		return _ability_damage;
	}
	
	function SetAbilityDamage(damage)
	{
		_ability_damage = damage;
	}
	
	function IsValid()
	{
		return (_survivor && _survivor.IsValid());
	}
	
	function IsUsedUp()
	{
		return (_ability_maxusage != null && _ability_maxusage > 0.0 && _usage_amount >= _ability_maxusage);
	}
	
	function IsExpired()
	{
		return (_ability_duration != null && _ability_duration > 0.0 && _start_time != null && (Time() - _start_time) >= _ability_duration);
	}
	
	function IsImmuneToDamage(damageType)
	{
		return (damageType & ability_dmg_immunity) != 0;
	}
	
	function Kill()
	{
		// Nothing to kill here
	}
	
	static ability_type = "BaseAbility";
	static ability_name = "base";
	static ability_sounds = [];
	static ability_dmg_immunity = 0;
	
	static ability_cooldown = 0;
	static ability_maxusage = 0;
	static ability_duration = 0;
	static ability_range = 0;
	static ability_damage = 0;	
	
	_ability_cooldown = null;
	_ability_maxusage = null;
	_ability_duration = null;
	_ability_range = null;
	_ability_damage = null;
	
	_ability_id = null;
	_survivor = null;
	_survivor_userid = null;
	_surivor_character = null;
	_start_time = null;
	_usage_amount = null;
}

::SurvivorAbilities.LoadTypes <- function()
{
	::SurvivorAbilities.AbilityTypes <- {};
	
	local lines = Left4Utils.FileToStringList("left4fun/survivorabilities/types.txt");
	if (!lines)
		return 0;

	foreach (line in lines)
	{
		line = strip(line);
		if (line && line != "")
		{
			local abilityType = line;
			local cooldown = null;
			local maxusage = null;
			local duration = null;
			local range = null;
			local damage = null;
			
			// It is possible to override the default values of cooldown, maxusage, duration, range and damage for each ability by adding comma separated values after the ability type (example: Fireman,60,10,40,100,0.1)
			local args = split(line, ",");
			if (args.len() > 1)
			{
				abilityType = strip(args[0]);
				cooldown = strip(args[1]);
			}
			if (args.len() > 2)
				maxusage = strip(args[2]);
			if (args.len() > 3)
				duration = strip(args[3]);
			if (args.len() > 4)
				range = strip(args[4]);
			if (args.len() > 5)
				damage = strip(args[5]);
			
			if (abilityType && abilityType != "")
			{
				if (!cooldown || cooldown == "")
					cooldown = "SurvivorAbilities." + abilityType + ".ability_cooldown"; // Ability's default value
				if (!maxusage || maxusage == "")
					maxusage = "SurvivorAbilities." + abilityType + ".ability_maxusage"; // Ability's default value
				if (!duration || duration == "")
					duration = "SurvivorAbilities." + abilityType + ".ability_duration"; // Ability's default value
				if (!range || range == "")
					range = "SurvivorAbilities." + abilityType + ".ability_range"; // Ability's default value
				if (!damage || damage == "")
					damage = "SurvivorAbilities." + abilityType + ".ability_damage"; // Ability's default value
				
				try
				{
					local str = "IncludeScript(\"survivor_abilities/" + abilityType + ".nut\"); \r\n ::SurvivorAbilities.AbilityTypes[SurvivorAbilities." + abilityType + ".ability_name] <- { cooldown = " + cooldown + ", maxusage = " + maxusage + ", duration = " + duration + ", range = " + range + ", damage = " + damage + ", classobj = SurvivorAbilities." + abilityType + " }; \r\n foreach (sound in ::SurvivorAbilities." + abilityType + ".ability_sounds) { if (!(sound in ::Left4Fun.SoundsToPrecache)) Left4Fun.SoundsToPrecache.push(sound); }";
					//Left4Fun.Log(LOG_LEVEL_DEBUG, str);
					
					local compiledscript = compilestring(str);
					compiledscript();
				}
				catch(exception)
				{
					Left4Fun.Log(LOG_LEVEL_ERROR, "SurvivorAbilities.LoadTypes - Failed to add ability type (" + line + ") - " + exception);
					if (Left4Fun.Settings.loglevel >= LOG_LEVEL_ERROR)
						Left4Utils.PrintStackTrace();
				}
			}
		}
	}
	
	//Left4Utils.PrintTable(SurvivorAbilities.AbilityTypes);
	
	return SurvivorAbilities.AbilityTypes.len();
}

::SurvivorAbilities.LoadCharacterDefaults <- function()
{
	::SurvivorAbilities.CharacterDefaults <- {};
	
	local lines = Left4Utils.FileToStringList("left4fun/survivorabilities/char_defaults.txt");
	if (!lines)
		return 0;

	local i = 0;
	foreach (line in lines)
	{
		line = strip(line);
		if (line != "" && (line in ::SurvivorAbilities.AbilityTypes))
			::SurvivorAbilities.CharacterDefaults[i] <- line;
		i++;
	}
	
	//foreach (key, val in ::SurvivorAbilities.CharacterDefaults)
	//	Left4Fun.Log(LOG_LEVEL_DEBUG, key + ": " + val);
	
	return SurvivorAbilities.CharacterDefaults.len();
}

::SurvivorAbilities.GetAbilityCooldown <- function(abilityName)
{
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return -1;
	
	return ::SurvivorAbilities.AbilityTypes[abilityName].cooldown;
}

// TODO: admin command
::SurvivorAbilities.SetAbilityCooldown <- function(abilityName, cooldown)
{
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return false;
	
	::SurvivorAbilities.AbilityTypes[abilityName].cooldown = cooldown;
	
	return true;
}

::SurvivorAbilities.GetAbilityMaxUsage <- function(abilityName)
{
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return -1;
	
	return ::SurvivorAbilities.AbilityTypes[abilityName].maxusage;
}

::SurvivorAbilities.SetAbilityMaxUsage <- function(abilityName, maxusage)
{
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return false;
	
	::SurvivorAbilities.AbilityTypes[abilityName].maxusage = maxusage;
	
	return true;
}

::SurvivorAbilities.GetAbilityDuration <- function(abilityName)
{
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return -1;
	
	return ::SurvivorAbilities.AbilityTypes[abilityName].duration;
}

::SurvivorAbilities.SetAbilityDuration <- function(abilityName, duration)
{
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return false;
	
	::SurvivorAbilities.AbilityTypes[abilityName].duration = duration;
	
	return true;
}

::SurvivorAbilities.GetAbilityRange <- function(abilityName)
{
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return -1;
	
	return ::SurvivorAbilities.AbilityTypes[abilityName].range;
}

::SurvivorAbilities.SetAbilityRange <- function(abilityName, range)
{
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return false;
	
	::SurvivorAbilities.AbilityTypes[abilityName].range = range;
	
	return true;
}

::SurvivorAbilities.GetAbilityDamage <- function(abilityName)
{
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return -1;
	
	return ::SurvivorAbilities.AbilityTypes[abilityName].damage;
}

::SurvivorAbilities.SetAbilityDamage <- function(abilityName, damage)
{
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return false;
	
	::SurvivorAbilities.AbilityTypes[abilityName].damage = damage;
	
	return true;
}

::SurvivorAbilities.SetPreferred <- function(survivor, abilityName, resetCooldown = true)
{
	if (!survivor || !survivor.IsValid())
		return false;
	
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return false;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Setting preferred ability " + abilityName + " for survivor " + survivor.GetPlayerName());
	
	::SurvivorAbilities.PreferredAbilities[survivor.GetPlayerUserId()] <- abilityName;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "PreferredAbilities.len() = " + SurvivorAbilities.PreferredAbilities.len());
	
	if (resetCooldown)
		SurvivorAbilities.ResetCooldown(survivor);
	
	return true;
}

::SurvivorAbilities.GetPreferred <- function(survivor)
{
	if (!survivor || !survivor.IsValid())
		return null;
	
	if (survivor.GetPlayerUserId() in ::SurvivorAbilities.PreferredAbilities)
		return ::SurvivorAbilities.PreferredAbilities[survivor.GetPlayerUserId()];
	
	local char = NetProps.GetPropInt(survivor, "m_survivorCharacter");
	if (char in ::SurvivorAbilities.CharacterDefaults)
		return ::SurvivorAbilities.CharacterDefaults[char];
	
	return null;
}

::SurvivorAbilities.RemovePreferred <- function(survivor)
{
	if (!survivor || !survivor.IsValid())
		return false;
	
	if (!(survivor.GetPlayerUserId() in ::SurvivorAbilities.PreferredAbilities))
		return false;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Removing preferred ability for survivor " + survivor.GetPlayerName());
	
	delete ::SurvivorAbilities.PreferredAbilities[survivor.GetPlayerUserId()];
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "PreferredAbilities.len() = " + SurvivorAbilities.PreferredAbilities.len());
	
	return true;
}

::SurvivorAbilities.AddPreferredAbility <- function(survivor)
{
	local abilityName = SurvivorAbilities.GetPreferred(survivor);
	if (!abilityName)
		return null;
	
	return SurvivorAbilities.AddAbility(survivor, abilityName);
}

::SurvivorAbilities.AddAbility <- function(survivor, abilityName)
{
	if (!survivor || !survivor.IsValid())
		return null;
	
	if (!(abilityName in ::SurvivorAbilities.AbilityTypes))
		return null; // Given abilityName is not a valid ability
	
	local userid = survivor.GetPlayerUserId();
	if (userid in ::SurvivorAbilities.Abilities)
		return null; // Given survivor has another active ability
	
	if (!(userid in ::SurvivorAbilities.Cooldowns))
	{
		Left4Fun.Log(LOG_LEVEL_ERROR, "SurvivorAbilities.AddAbility - survivor " + survivor.GetPlayerName() + " has no cooldnown entry!");
		return null; // This shouldn't happen
	}
	
	if (::SurvivorAbilities.Cooldowns[userid] > 0.0)
		return null; // Cooldown in progress
	
	local ability = ::SurvivorAbilities.AbilityTypes[abilityName].classobj(survivor);
	if (ability)
		::SurvivorAbilities.Abilities[userid] <- ability;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "Added ability: " + ability);
	
	return ability;
}

::SurvivorAbilities.UseAbility <- function(survivor)
{
	if (!survivor || !survivor.IsValid())
		return false;
	
	local userid = survivor.GetPlayerUserId();
	if (!(userid in ::SurvivorAbilities.Abilities))
		return false;

	::SurvivorAbilities.Abilities[userid].Use();

	return true;
}

::SurvivorAbilities.RemoveAbility <- function(survivor)
{
	if (survivor && survivor.IsValid())
		return SurvivorAbilities.RemoveAbilityByUserid(survivor.GetPlayerUserId(), survivor);
	
	if (survivor && ("GetPlayerUserId" in survivor))
		return SurvivorAbilities.RemoveAbilityByUserid(survivor.GetPlayerUserId());
	
	return false;
}

::SurvivorAbilities.RemoveAbilityByUserid <- function(userid, survivor = null)
{
	if (!(userid in ::SurvivorAbilities.Abilities))
		return false;
	
	::SurvivorAbilities.Abilities[userid].Kill();
	delete ::SurvivorAbilities.Abilities[userid];

	foreach (key, val in ::SurvivorAbilities.Abilities)
		Left4Fun.Log(LOG_LEVEL_DEBUG, key + ": " + val);
	
	if (!survivor)
		survivor = g_MapScript.GetPlayerFromUserID(userid);

	if (survivor && survivor.IsValid)
		SurvivorAbilities.ResetCooldown(survivor);
	else
	{
		Left4Fun.Log(LOG_LEVEL_DEBUG, "SurvivorAbilities.RemoveAbilityByUserid - survivor with userid " + userid + " is no longer valid!");
		
		if (userid in ::SurvivorAbilities.Cooldowns)
			delete ::SurvivorAbilities.Cooldowns[userid];
		
		//Left4Utils.PrintTable(SurvivorAbilities.Cooldowns);
	}

	return true;
}

::SurvivorAbilities.TransferAbility <- function(survivorFrom, survivorTo)
{
	if (!survivorFrom || !survivorTo || !survivorFrom.IsValid() || !survivorTo.IsValid())
		return false;
	
	local useridFrom = survivorFrom.GetPlayerUserId();
	if (!(useridFrom in ::SurvivorAbilities.Abilities))
		return false;
	
	local useridTo = survivorTo.GetPlayerUserId();
	if (useridTo in ::SurvivorAbilities.Abilities)
		return false;
	
	local ability = ::SurvivorAbilities.Abilities[useridFrom];
	delete ::SurvivorAbilities.Abilities[useridFrom];
	
	ability.SetSurvivor(survivorTo);
	::SurvivorAbilities.Abilities[useridTo] <- ability;

	return true;
}

::SurvivorAbilities.IsImmuneToDamage <- function(survivor, damageType)
{
	//if (!survivor || !survivor.IsValid())
	//	return false;
	
	local userid = survivor.GetPlayerUserId();
	if (!(userid in ::SurvivorAbilities.Abilities))
		return false;
	
	return ::SurvivorAbilities.Abilities[userid].IsImmuneToDamage(damageType);
}

::SurvivorAbilities.ResetCooldown <- function(survivor)
{
	if (!survivor || !survivor.IsValid())
		return;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "SurvivorAbilities.ResetCooldown - " + survivor.GetPlayerName());
	
	local abilityName = SurvivorAbilities.GetPreferred(survivor);
	if (!abilityName)
		return;
	
	::SurvivorAbilities.Cooldowns[survivor.GetPlayerUserId()] <- SurvivorAbilities.GetAbilityCooldown(abilityName).tofloat();
	
	//Left4Utils.PrintTable(SurvivorAbilities.Cooldowns);
}

::SurvivorAbilities.SurvivorIn <- function(survivor)
{
	if (!survivor || !survivor.IsValid())
		return;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "SurvivorAbilities.SurvivorIn - " + survivor.GetPlayerName());
	
	SurvivorAbilities.ResetCooldown(survivor);
}

::SurvivorAbilities.SurvivorOut <- function(survivor)
{
	if (!survivor || !survivor.IsValid())
		return;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "SurvivorAbilities.SurvivorOut - " + survivor.GetPlayerName());
	
	SurvivorAbilities.RemoveAbility(survivor);
	
	if (!(survivor.GetPlayerUserId() in ::SurvivorAbilities.Cooldowns))
		return;
	
	delete ::SurvivorAbilities.Cooldowns[survivor.GetPlayerUserId()];
	
	//Left4Utils.PrintTable(SurvivorAbilities.Cooldowns);
}

::SurvivorAbilities.SurvivorReplace <- function(survivorIn, survivorOut)
{
	if (!survivorIn || !survivorOut || !survivorIn.IsValid() || !survivorOut.IsValid())
		return;
	
	Left4Fun.Log(LOG_LEVEL_DEBUG, "SurvivorAbilities.SurvivorReplace - " + survivorIn.GetPlayerName() + " (" + NetProps.GetPropInt(survivorIn, "m_iTeamNum") + ") -> " + survivorOut.GetPlayerName() + " (" + NetProps.GetPropInt(survivorOut, "m_iTeamNum") + ")");
	
	local cooldown = -1;
	if (survivorOut.GetPlayerUserId() in ::SurvivorAbilities.Cooldowns)
	{
		::SurvivorAbilities.Cooldowns[survivorIn.GetPlayerUserId()] <- ::SurvivorAbilities.Cooldowns[survivorOut.GetPlayerUserId()];
		delete ::SurvivorAbilities.Cooldowns[survivorOut.GetPlayerUserId()];
	}
	else if (survivorOut.IsDead() || survivorOut.IsDying())
		return; // Survivor died and got replaced by human/bot, don't recreate a cooldown for him
	else
	{
		// this shouldn't happen btw
		Left4Fun.Log(LOG_LEVEL_ERROR, "SurvivorAbilities.SurvivorReplace - survivorOut had no cooldown!");
		
		SurvivorAbilities.ResetCooldown(survivorIn);
	}

	SurvivorAbilities.TransferAbility(survivorOut, survivorIn);
}

::SurvivorAbilities.GetSurvivorCooldown <- function(survivor)
{
	if (!survivor || !survivor.IsValid())
		return;
	
	if (!(survivor.GetPlayerUserId() in ::SurvivorAbilities.Cooldowns))
		return -1;
	
	return ::SurvivorAbilities.Cooldowns[survivor.GetPlayerUserId()];
}

::SurvivorAbilities.CleanupAbilities <- function()
{
	foreach (k, v in ::SurvivorAbilities.Abilities)
		v.Kill();
	
	SurvivorAbilities.Abilities.clear();
}

::SurvivorAbilities.Update <- function(updateCooldown = true)
{
	if (updateCooldown)
	{
		// Cooldown
		local elapsed = 0.0;
		
		if (SurvivorAbilities.LastCooldownUpdate != 0.0)
			elapsed = Time() - SurvivorAbilities.LastCooldownUpdate;
		
		if (elapsed > 0.0)
		{
			foreach (key, val in ::SurvivorAbilities.Cooldowns)
			{
				if (val > 0.0)
				{
					local c = val - elapsed;
					if (c < 0.0)
						c = 0.0;

					::SurvivorAbilities.Cooldowns[key] <- c;
					
					if (c <= 0.0)
					{
						Left4Fun.Log(LOG_LEVEL_DEBUG, "SurvivorAbilities.Update - Ability ready for player " + key);
						
						foreach (func in ::SurvivorAbilities.Events.OnAbilityReady)
							func(key);
					}
				}
			}
		}
	}
	SurvivorAbilities.LastCooldownUpdate = Time();
	
	// Validity / Max Usage / Duration
	local toRemove = [];
	
	foreach (key, val in ::SurvivorAbilities.Abilities)
	{
		if (val.IsValid())
		{
			if (val.IsUsedUp())
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "SurvivorAbilities.Update - Ability " + val.ability_name + " of player " + key + " used up");
				
				foreach (func in ::SurvivorAbilities.Events.OnAbilityUsedUp)
					func(key, val);
				
				toRemove.push(key);
			}
			else if (val.IsExpired())
			{
				Left4Fun.Log(LOG_LEVEL_DEBUG, "SurvivorAbilities.Update - Ability " + val.ability_name + " of player " + key + " expired");
				
				foreach (func in ::SurvivorAbilities.Events.OnAbilityExpired)
					func(key, val);
				
				toRemove.push(key);
			}
		}
		else
		{
			Left4Fun.Log(LOG_LEVEL_DEBUG, "SurvivorAbilities.Update - Ability " + val.ability_name + " of player " + key + " is no longer valid");
			toRemove.push(key);
		}
	}
	
	foreach (userid in toRemove)
		SurvivorAbilities.RemoveAbilityByUserid(userid);
}
