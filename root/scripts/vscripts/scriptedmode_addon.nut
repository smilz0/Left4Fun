Msg("scriptedmode_addon L4F\n");

// Make a call to MapScript and ModeScript, returns whether any calls were made
// NOTE: sadly only does no-argument calls - which makes this way less useful
scripthelp_ScriptMode_SystemCall <- "Makes the passed in call to g_MapScript and g_ModeScript, but it must have Zero args"
function ScriptMode_SystemCall(callname)
{
	local calls = 0;
	if (("Left4Fun" in getroottable()) && (callname in ::Left4Fun))
	{
		::Left4Fun[callname]()
		calls++;
	}
	if (callname in g_MapScript)   // do we allow returning False to say "dont call Mode"? ugh...
	{
		g_MapScript[callname]()
		calls++;
	}
	if (callname in g_ModeScript)
	{
		g_ModeScript[callname]()
		calls++;
	}
	return calls > 0;
}
