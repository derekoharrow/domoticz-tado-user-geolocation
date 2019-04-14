--
--
-- tado-usergeo.lua
--
-- Processes information from the users list, zones list and zones status and takes action accordingly.
--
-- If Tado mode set to Home (someone is home), but a specific user is away and their relevant zone is on, then turn it off.
--
--

return {

	logging = {
		level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
		marker = 'TADOUSERGEO'
	},
	
	on = {
		timer = {'every minute'}
	},

	execute = function(domoticz)

	-- Check we have the tado user list - can't work without it
	
		if domoticz.globalData.TadoUsers == '' then
			domoticz.log ('TadoUsers not set', domoticz.LOG_DEBUG)
			return
		end

	-- Check we have the tado zones list - can't work without it
	
		if domoticz.globalData.TadoZones == '' then
			domoticz.log ('TadoZones not set', domoticz.LOG_DEBUG)
			return
		end

		local usercount = #domoticz.globalData.TadoUsers
		local zonecount = #domoticz.globalData.TadoZones

		domoticz.log('User count=' .. tostring(usercount), domoticz.LOG_DEBUG)
		domoticz.log('Zone count=' .. tostring(zonecount), domoticz.LOG_DEBUG)

	-- Reset TadoUserMapping (maps users to zones) back to what's in global_data - just in case it's been updated
	
		domoticz.globalData.initialize('TadoUserMapping')
		
	-- Iterate through users in users list
	
		for i=1, usercount, 1
		do
			local username = domoticz.globalData.TadoUsers[i].name
			domoticz.log('User =' .. username, domoticz.LOG_DEBUG)
			local userhome = domoticz.globalData.TadoUsers[i].mobileDevices[1].location.atHome
			if userhome then
				domoticz.log('...HOME', domoticz.LOG_DEBUG)
			else
				domoticz.log('...AWAY', domoticz.LOG_DEBUG)
			end
			local userzone = domoticz.globalData.TadoUserMapping[username]

		-- If user in tado user list is mapped to a zone, then iterate through the zones to get the zone info.
		
			if userzone ~= nil then
				domoticz.log('...Mapped User Zone = ' .. userzone, domoticz.LOG_DEBUG)
				for j=1, zonecount, 1
				do
					local zonename = domoticz.globalData.TadoZones[j].name

				-- Zone matched to user...
				
					if zonename == userzone then
						domoticz.log('...MATCH FOUND - ' .. zonename, domoticz.LOG_DEBUG)
						domoticz.log('......Zone =' .. zonename, domoticz.LOG_DEBUG)
						domoticz.log('......Power = ' .. domoticz.globalData.TadoZoneModes[j], domoticz.LOG_DEBUG)
						domoticz.log('......Temp = ' .. tostring(domoticz.globalData.TadoZoneTemps[j]), domoticz.LOG_DEBUG)

--
-- DO WHATEVER YOU WANT TO DO HERE. CURRENTLY TURNS OFF ZONE IF USER AWAY
--
						if domoticz.globalData.TadoZoneOverlays[j] then
							domoticz.log('......Overlay ON', domoticz.LOG_DEBUG)
						else
							domoticz.log('......Overlay OFF', domoticz.LOG_DEBUG)
						end
						
					-- Someone, but not necessarily everyone, is at home...
						
						if domoticz.globalData.TadoMode == 'HOME' then

						-- User is home
							if userhome then
							
							-- Overlay already set
								if domoticz.globalData.TadoZoneOverlays[j] then
								
								--	Turn off the overlay
									domoticz.log('.........Tado set to HOME, user HOME, Override set - turn off override', domoticz.LOG_DEBUG)
									domoticz.log ("curl -s 'https://my.tado.com/api/v2/homes/" .. domoticz.globalData.TadoHomeId .. "/zones/" .. tostring(j) .. "/overlay' -X DELETE -H 'Authorization: Bearer " .. domoticz.globalData.TadoToken .. "'", domoticz.LOG_DEBUG)
									os.execute ("curl -s 'https://my.tado.com/api/v2/homes/" .. domoticz.globalData.TadoHomeId .. "/zones/" .. tostring(j) .. "/overlay' -X DELETE -H 'Authorization: Bearer " .. domoticz.globalData.TadoToken .. "'")

							-- Overlay not set
								else
								
								-- Do nothing
									domoticz.log('.........Tado set to HOME and user HOME, but no override set', domoticz.LOG_DEBUG)
								end
							
						-- User is away
							else
							
							-- Overlay already set
								if domoticz.globalData.TadoZoneOverlays[j] then
								
								-- Do nothing
									domoticz.log('.........Tado set to HOME and user Away and override set', domoticz.LOG_DEBUG)

							-- No Overlay set
								else
								
								-- Set overlay (turn temp down)
									domoticz.log('.........Tado set to HOME and user AWAY and no Override set - turn temp down until they get back', domoticz.LOG_DEBUG)
									os.execute("curl -s 'https://my.tado.com/api/v2/homes/" .. domoticz.globalData.TadoHomeId .. "/zones/" .. tostring(j) .. "/overlay' -X PUT -H 'Authorization: Bearer " .. domoticz.globalData.TadoToken ..  "' -H 'Content-Type: application/json;charset=utf-8' --data '{\"setting\":{\"type\":\"HEATING\",\"power\":\"ON\",\"temperature\":{\"celsius\":" .. tostring(domoticz.globalData.TadoAwayTemp) .. "}},\"termination\":{\"type\":\"TADO_MODE\"}}'")
								end
							end

					-- Everyone is AWAY...
						
						elseif domoticz.globalData.TadoMode == 'AWAY' then

						-- Odd scenario - Tado says it's in Away mode, but some user reported as being at home - shouldn't happen in normal life...
							if domoticz.globalData.TadoUsers[i].mobileDevices[1].location.atHome then
								domoticz.log('.........What\'s going on here??? Tado set to AWAY and user HOME', domoticz.LOG_DEBUG)

						-- Tado set to away mode and user set to away mode - normal state of affairs, so do nothing...
							else
							end
						end

--
-- DONE DOING STUFF
--

					end
				end
			else
				domoticz.log('....User ' .. username .. ' UNMAPPED', domoticz.LOG_DEBUG)
			end
		end
	end
}
