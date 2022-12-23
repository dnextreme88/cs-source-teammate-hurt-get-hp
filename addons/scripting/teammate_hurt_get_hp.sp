#include <sourcemod>
#include <morecolors>

#pragma semicolon 1

#define PLUGIN_VERSION "1.0"
#define MAX_FILE_LEN 80

// Plugin definitions
public Plugin:myinfo = {
    name = "Teammate Hurt Get HP",
    author = "dnextreme88",
    description = "Displays a message letting everyone know who attacked a teammate. Created on December 23, 2022.",
    version = PLUGIN_VERSION,
    url = "http://forums.alliedmods.net"
};

public void OnPluginStart() {
    HookEvent("player_hurt", Event_PlayerHurt);
    HookUserMessage(GetUserMessageId("TextMsg"), TextMsg, true);
}

// Thanks to LinLinLin for this snippet (https://forums.alliedmods.net/showthread.php?t=340951)
public Action TextMsg(UserMsg msg_id, Handle bf, int[] players, int playersNum, bool reliable, bool init) {
    static char sUserMess[96];

    if (GetUserMessageType() == UM_Protobuf) {
        PbReadString(bf, "params", sUserMess, sizeof(sUserMess), 0);
    } else {
        BfReadString(bf, sUserMess, sizeof(sUserMess));
    }

    // Hide the default message in cstrike_*.txt (eg. cstrike_english.txt) from the cstrike/resource directory
    if (StrContains(sUserMess, "Game_teammate_attack", false) != -1) {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast) {
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    int victimHp = GetClientHealth(victim);

    if (attacker > 0 && victim > 0 && IsClientInGame(attacker) && IsClientInGame(victim)) {
        for (int i = 1; i <= MaxClients; i++) {
            char colorNames[][] = {"cyan", "green", "yellow", "darkorange", "red"};
            new String:colorToUse[64];

            new String:attackerName[64];
            new String:victimName[64];

            GetClientName(attacker, attackerName, 33);
            GetClientName(victim, victimName, 33);

            if (victimHp >= 80) {
                strcopy(colorToUse, sizeof(colorToUse), colorNames[0]);
            } else if (victimHp >= 60 && victimHp < 80) {
                strcopy(colorToUse, sizeof(colorToUse), colorNames[1]);
            } else if (victimHp >= 40 && victimHp < 60) {
                strcopy(colorToUse, sizeof(colorToUse), colorNames[2]);
            } else if (victimHp >= 20 && victimHp < 40) {
                strcopy(colorToUse, sizeof(colorToUse), colorNames[3]);
            } else if (victimHp < 20) {
                strcopy(colorToUse, sizeof(colorToUse), colorNames[4]);
            }

            if (IsClientInGame(i) && victimHp > 0 && attacker != victim && GetClientTeam(i) == GetClientTeam(attacker) && GetClientTeam(i) == GetClientTeam(victim)) {
                CPrintToChatEx(i, i, "{teamcolor}%s{default} attacked {teamcolor}%s{default} (HP left: {%s}%i{default})", attackerName, victimName, colorToUse, victimHp);
            } else if (IsClientInGame(i) && victimHp > 0 && attacker == victim) {
                CPrintToChatEx(i, i, "{teamcolor}%s{default} attacked himself! (HP left: {%s}%i{default})", attackerName, colorToUse, victimHp);
            }
        }
    }
}
