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

public void OnPluginStart()
{
	array_names = CreateArray(128);

	LoadList();

	char name[128];
	for (int i = 1; i < GetArraySize(array_names); i++)
	{
		GetArrayString(array_names, i, name, sizeof(name));
		FQ_AddFakePlayer(i+1, name, GetRandomInt(0, 60), GetEngineTime()-(i*GetRandomInt(30, 300)));
		g_iFakePlayerCount++;
	}

	FQ_SetNumClients(g_iFakePlayerCount + GetClientCount());

	FQ_ToggleStatus(true);
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
	FQ_ResetA2sInfo();
	FQ_RemoveAllFakePlayer();
	
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
