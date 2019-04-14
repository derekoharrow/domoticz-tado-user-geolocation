# domoticz-tado

User-level geolocation for Tado 
These scripts perform the following:

tado-auth.lua
=============
  
  Calls the Tado API to login and authenticate
    
tado-gethomeid.lua
==================
  
Once logged in, this script calls the Tado API to get the HomeID (required for all subsequent API calls)
    
tado-getstatus.lua
==================
  
Gets the status of the Tado Zones and Tado Users
    
tado-userzones.lua
==================
  
Checks users against their mapped zones.
If Tado mode is set to Home (ie. someone is at home), AND a specific user is away, then turn off their mapped zone.

global_data.lua
===============

  TadoToken - global variable to receive Tado authentication token. Updated every 6 minutes
  TadoHomeId - global variable to receive Tado HomeId value
  TadoZones - global variable to receive JSON output of Tado zone info
  TadoUsers - global variable to recceive JSON output of Tado user info
  TadoClientId - global variable for Tado ClientID - used when calling Tado API. Can be found at https://my.tado.com/webapp/env.js
  TadoClientSecret - global variable for Tado - secret to be used when calling Tado API. Can be found at https://my.tado.com/webapp/env.js

Domoticz User Variables
=======================

  TadoUsername - the username (email address) that you use to login to Tado - must be admin
  TadoPassword - the password used to log this account in to Tado
  
 
