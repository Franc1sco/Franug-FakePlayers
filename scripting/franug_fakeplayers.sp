/*  SM Franug Fake players
 *
 *  Copyright (C) 2021 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */
#include <sourcemod>
native void FQ_ToggleStatus(bool bEnable);
native void FQ_ResetA2sInfo();
native void FQ_SetNumClients(int iNumClients, bool bResetToDefault = false);
native void FQ_AddFakePlayer(int iIndex, const char[] sName, int iScore, float flTime);
native void FQ_RemoveAllFakePlayer();
public Extension __ext_fakequeries = 
{
	name = "fakequeries",
	file = "fakequeries.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};

#define MIN_REFRESH_TIME 60.0
#define MAX_REFRESH_TIME 3600.0

public Plugin myinfo =
{
    name = "SM Franug Fake players",
    author = "Franc1sco Franug",
    description = "Create fake players",
    version = "0.1",
    url = "https://steamcommunity.com/id/franug"
};

int g_iFakePlayerCount = 0;
Handle array_names;
ConVar cv_maxplayers;

bool firstLoad = true;

public void OnPluginStart()
{
	cv_maxplayers = CreateConVar("sm_fakebots_max", "63", "Max fake bots on server");
	array_names = CreateArray(128);
}

public void OnMapStart()
{
	LoadList();
	if(firstLoad)
	{
		AddFakePlayers();
		CreateTimer(GetRandomFloat(MIN_REFRESH_TIME, MAX_REFRESH_TIME), Timer_RefreshPlayers);
		
		firstLoad = false;
	}
}

public Action Timer_RefreshPlayers(Handle timer)
{
	AddFakePlayers();
	
	CreateTimer(GetRandomFloat(MIN_REFRESH_TIME, MAX_REFRESH_TIME), Timer_RefreshPlayers);
}


public void OnClientDisconnect_Post(int client)
{
	FQ_SetNumClients(g_iFakePlayerCount + GetClientCount());
}

public void OnClientPostAdminCheck(int client)
{
	FQ_SetNumClients(g_iFakePlayerCount + GetClientCount());
}

public void LoadList()
{
	ClearArray(array_names);
	
	new String:path[PLATFORM_MAX_PATH];
	BuildPath(PathType:Path_SM, path, sizeof(path), "configs/franug_fakeplayers.txt");
	
	Handle file = OpenFile(path, "r");
	if(file == INVALID_HANDLE)
	{
		SetFailState("[FAKEPLAYERS] Unable to read file %s", path);
	}
	
	char name[128];
	while(!IsEndOfFile(file) && ReadFileLine(file, name, sizeof(name)))
	{
		if (name[0] == ';' || !IsCharAlpha(name[0]))
		{
			continue;
		}

		PushArrayString(array_names, name);
	}
	
	CloseHandle(file);
}

void AddFakePlayers()
{
	FQ_ResetA2sInfo();
	FQ_RemoveAllFakePlayer();
	
	Handle temp_names = CreateArray(128);
	temp_names = CloneArray(array_names);
	//PrintToServer("BOT NAME RESTART");
	//PrintToServer("-------------------------------------------------");
	g_iFakePlayerCount = 0;
	char name[128];
	while(GetArraySize(temp_names) != 0 && g_iFakePlayerCount < cv_maxplayers.IntValue)
	{
		int luck = GetRandomInt(0, GetArraySize(temp_names)-1);
		GetArrayString(temp_names, luck, name, sizeof(name));
		FQ_AddFakePlayer(g_iFakePlayerCount+1, name, GetRandomInt(0, 200), GetEngineTime()-GetRandomInt(0, 1000));
		g_iFakePlayerCount++;
		RemoveFromArray(temp_names, luck);
		//PrintToServer("Bot name is %s", name);
	}
	//PrintToServer("-------------------------------------------------");
	
	FQ_SetNumClients(g_iFakePlayerCount + GetClientCount());
	FQ_ToggleStatus(true);
	
	CloseHandle(temp_names);
}
