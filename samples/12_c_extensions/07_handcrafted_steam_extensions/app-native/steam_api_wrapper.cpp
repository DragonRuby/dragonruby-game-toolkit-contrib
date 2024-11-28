extern "C" {
#include "steam_api_wrapper.h"
}

#include <stdio.h>
#include "steam/steam_api.h"

void SteamAPIWrapper_Init()
{
  SteamAPI_Init();
}

const char *SteamAPIWrapper_GetCurrentUserSteamName()
{
  return SteamFriends()->GetPersonaName();
}
