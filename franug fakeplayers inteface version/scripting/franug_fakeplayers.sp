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
#include <autoexecconfig>
#include <franug_fakeplayers_interface>

public Plugin myinfo =
{
    name = "SM Franug Fake players",
    author = "Franc1sco Franug",
    description = "Create fake players",
    version = "0.3",
    url = "https://steamcommunity.com/id/franug"
};

int g_iFakePlayerCount = 0;
Handle array_names;
ConVar cv_maxrefreshplayers;
ConVar cv_minrefreshplayers;
ConVar cv_maxcountplayers;
ConVar cv_mincountplayers;

ConVar cv_maxscoreplayers;
ConVar cv_minscoreplayers;
ConVar cv_maxtimeplayers;
ConVar cv_mintimeplayers;

bool firstLoad = true;

public void OnPluginStart()
{
	AutoExecConfig_SetFile("franug_fakeplayers");
	
	cv_maxrefreshplayers = AutoExecConfig_CreateConVar("sm_fakebots_max_refresh", "7200.0", "Max fake bots refresh time on server");
	cv_minrefreshplayers = AutoExecConfig_CreateConVar("sm_fakebots_min_refresh", "60.0", "Min fake bots refresh time on server");
	cv_maxcountplayers = AutoExecConfig_CreateConVar("sm_fakebots_max_count", "63", "Max fake bots on server");
	cv_mincountplayers = AutoExecConfig_CreateConVar("sm_fakebots_min_count", "10", "Min fake bots on server");
	cv_maxscoreplayers = AutoExecConfig_CreateConVar("sm_fakebots_max_score", "80", "Max fake bots score on server");
	cv_minscoreplayers = AutoExecConfig_CreateConVar("sm_fakebots_min_score", "0", "Min fake bots score on server");
	cv_maxtimeplayers = AutoExecConfig_CreateConVar("sm_fakebots_max_time", "1000", "Max fake bots join time on server on seconds");
	cv_mintimeplayers = AutoExecConfig_CreateConVar("sm_fakebots_min_time", "0", "Min fake bots join time on server on seconds");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	array_names = CreateArray(128);
}

public void OnConfigsExecuted()
{
	LoadList();
	if(firstLoad)
	{
		AddFakePlayers();
		CreateTimer(GetRandomFloat(cv_minrefreshplayers.FloatValue, cv_maxrefreshplayers.FloatValue), Timer_RefreshPlayers);
		
		firstLoad = false;
	}
}

public Action Timer_RefreshPlayers(Handle timer)
{
	AddFakePlayers();
	
	CreateTimer(GetRandomFloat(cv_minrefreshplayers.FloatValue, cv_maxrefreshplayers.FloatValue), Timer_RefreshPlayers);
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
	FranugFakePlayers_ResetBots();
	
	Handle temp_names = CreateArray(128);
	temp_names = CloneArray(array_names);
	//PrintToServer("BOT NAME RESTART");
	//PrintToServer("-------------------------------------------------");
	g_iFakePlayerCount = 0;
	char name[128];
	int randomMaxBots = GetRandomInt(cv_mincountplayers.IntValue, cv_maxcountplayers.IntValue);
	while(GetArraySize(temp_names) != 0 && g_iFakePlayerCount < randomMaxBots)
	{
		int luck = GetRandomInt(0, GetArraySize(temp_names)-1);
		GetArrayString(temp_names, luck, name, sizeof(name));
		
		FranugFakePlayers_AddBot( 
			name, 
			GetRandomInt(cv_mintimeplayers.IntValue, cv_maxtimeplayers.IntValue),
			GetRandomInt(cv_minscoreplayers.IntValue, cv_maxscoreplayers.IntValue) 
		);
		
		g_iFakePlayerCount++;
		RemoveFromArray(temp_names, luck);
		//PrintToServer("Bot name is %s", name);
	}
	//PrintToServer("-------------------------------------------------");
	
	CloseHandle(temp_names);
}
