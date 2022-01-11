if (!("AllowWeaponSpawn" in DirectorScript.GetDirectorOptions()))
{
	DirectorScript.GetDirectorOptions().AllowWeaponSpawn <- function (classname)
	{
		//printl("AllowWeaponSpawn - " + classname);
		
		if (!classname)
			return false;
		
		if (Left4Fun.WeaponsToRemove.find(classname) != null)
			return false;
		
		return true;
	}
}

if (!("ConvertWeaponSpawn" in DirectorScript.GetDirectorOptions()))
{
	DirectorScript.GetDirectorOptions().ConvertWeaponSpawn <- function (classname)
	{
		//printl("ConvertWeaponSpawn - " + classname);
		
		if (classname in Left4Fun.WeaponsToConvert)
			return Left4Fun.WeaponsToConvert[classname];
		
		return 0;
	}
}

/*
if (!("ConvertZombieClass" in DirectorScript.GetDirectorOptions()))
{
	DirectorScript.GetDirectorOptions().ConvertZombieClass <- function (iClass)
	{
		return Left4Fun.ConvertZombieClass(iClass);
	}
}
*/

if (!("GetDefaultItem" in DirectorScript.GetDirectorOptions()))
{
	DirectorScript.GetDirectorOptions().GetDefaultItem <- function (idx)
	{
		//printl("GetDefaultItem - " + idx);
		
		if (Left4Fun.DefaultItems.len() == 0 && idx == 0)
			return "weapon_pistol";
		
		if (idx < Left4Fun.DefaultItems.len())
		{
			return Left4Fun.DefaultItems[idx];
		}
		return 0;
	}
}

if (!("AllowFallenSurvivorItem" in DirectorScript.GetDirectorOptions()))
{
	DirectorScript.GetDirectorOptions().AllowFallenSurvivorItem <- function (classname)
	{
		//printl("AllowFallenSurvivorItem - " + classname);
		
		if (!classname)
			return false;
		
		if (Left4Fun.WeaponsToRemove.find(classname) != null)
			return false;
		
		return true;
	}
}
