# domoticz-tado-user-geolocation

## Introduction

This set of scripts implements a capability that Tado users have been wanting for quite some time - the ability to have per-user geolocation and turn on/off heating for specific zones for specific users based on whether they are home or not.

## Limitations

- If a user has already put a Zone into manual control mode it could be overwritten 
- At present the script sets either the heating to be on, as per programme, or turned down to a reduced value. It doesn't account for whether the user is far away or heading home and will only turn the heating for that zone back on when the user is detected (by Tado) as being back home.
- At present, only one Zone can be controlled per tado user.

## To-Do

- Set a user variable to enable/disable the scripts
- Automate retrieval of ClientID and ClientSecret from Tado website

## Pre-requisites

### User Variables

The following Domoticzz User Variables must be set in order for these scripts to work:
- **TadoUsername** - the username (email address) that you use to login to Tado - must be admin
- **TadoPassword** - the password used to log this account in to Tado
- **TadoAwayTemp** - the Temp, in Celsius, that you wish Tado to set zones to when their matches users are "away".

### Global Data

- **TadoToken** - global variable to receive Tado authentication token. Updated every 6 minutes
- **TadoHomeId** - global variable to receive Tado HomeId value
- **TadoZones** - global variable to receive JSON output of Tado zone info
- **TadoUsers** - global variable to recceive JSON output of Tado user info
- **TadoClientId** - global variable for Tado ClientID - used when calling Tado API. Can be found at https://my.tado.com/webapp/env.js
- **TadoClientSecret** - global variable for Tado - secret to be used when calling Tado API. Can be found at https://my.tado.com/webapp/env.js
- **TadoUserMapping** - maps specific Tado users to a specific Tado zone to control. For example:
- **TadoMode** - global variable storing current Tado mode - Home/Away/etc
- **TadoUserMapping** = { initial = { ["Derek"]="Derek's Study", ["Bob"]=["Bob's Bedroom"] } }

## Instructions
1. Create the Domoticz User Variables TadoUsername and TadoPassword as Strings and set them to your Tado credentials.
2. Create the Domoticz User Variable TadoAwayTemp as an Integer and set it to your desired away temp (in Celsius)
3. Copy the data values from the enclosed global_data.lua and merge it into your global_data.lua in domoticz/scripts/dzvents
4. Edit the TadoUserMapping parameter in global_data.lua to map users to the zone you want to control for each of them. You must use the user names and zone names as they appear in Tado here.
5. Copy the rest of the LUA files into your domoticz/scripts/dzvents folder
6. (Optional) turn on debugging in each LUA file by uncommenting the debug level in the logging section at the start of each script.

## Scripts

### global_data.lua

The content of the enclosed global_data.lua must be added to your existing global_data.lua stored in domoticz/scripts/dzvents

### tado-auth.lua

This script regularly calls the Tado API to authenticate and retrieve an authentication token, which expires every 10 minutes. To ensure the token doesn't expire, this script runs every 6 minutes.

### tado-gethomeid.lua
  
Calls the Tado API to get the HomeID of your Tado setup (every home on Tado has a unique HomeID)

### tado-getstatus.lua

Calls the Tado API multiple times to get:
- List of Tado users, and their status
- List of Tado zones within your home
- Status of each of those Tado zones
    
### tado-userzones.lua

This is the main script that processes the information retrieved by the other scripts.

For each user in the retrieved user list, it checks those users against the mapped zones and when a match is found it will:
- Turn the zone back to automatic if the user is "Home"
- Turn the zone to a manual pre-defined temperature (defined in global_data.lua by the variable TadoAwayTemp) if the user is Away but Tado still thinks someone is home.

The key to this is the mapping of users to managed zones, which is defined in global_data.lua by the variable TadoUserMapping.
