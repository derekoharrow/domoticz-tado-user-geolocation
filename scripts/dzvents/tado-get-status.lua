--
-- TADO-GET-STATUS.LUA
-- ===================
--
-- Get the Tado Zones list, User list and Zones status
--

return {

	logging = {
--		level = domoticz.LOG_DEBUG,			-- Uncomment this line to enable debugging
		marker = "TADO-GET-STATUS"
	},

   on = {
		timer = {'every 2 minutes'},
		httpResponses = { 'TadoGetZonesCallback', 'TadoGetUsersCallback', 'TadoGetStateCallback', 'TadoGetZoneInfoCallback*' }
	},

	execute = function(domoticz,item)

	-- Check TadoToken has been set first. Won't work without it.
		if domoticz.globalData.TadoToken == '' then
			domoticz.log('ERROR: Tado token not set', domoticz.LOG_ERROR)
			return
		end

	-- Check TadoHomeId has been set first. Won't work without it.
		if domoticz.globalData.TadoHomeId == '' then
			domoticz.log('ERROR: Tado HomeId not set', domoticz.LOG_ERROR)
			return
		end
				
		if (item.isTimer) then

		-- Call Tado API to get zones list

			domoticz.log('Making HTTP call to tado to get Zones info', domoticz.LOG_DEBUG)

			domoticz.openURL({
				url = 'https://my.tado.com/api/v2/homes/' .. domoticz.globalData.TadoHomeId .. '/zones',
				method = 'GET',
				headers = { ['Authorization'] = 'Bearer ' .. domoticz.globalData.TadoToken },
				callback = 'TadoGetZonesCallback'
			})

		-- Call Tado API to get users list

			domoticz.log('Making HTTP call to tado to get Users info', domoticz.LOG_DEBUG)

			domoticz.openURL({
				url = 'https://my.tado.com/api/v2/homes/' .. domoticz.globalData.TadoHomeId .. '/users',
				method = 'GET',
				headers = { ['Authorization'] = 'Bearer ' .. domoticz.globalData.TadoToken },
				callback = 'TadoGetUsersCallback'
			})
			
		-- Call Tado API to get Tado status info
		
			domoticz.log('Making HTTP call to tado to get Tado state', domoticz.LOG_DEBUG)

			domoticz.openURL({
				url = 'https://my.tado.com/api/v2/homes/' .. domoticz.globalData.TadoHomeId .. '/state',
				method = 'GET',
				headers = { ['Authorization'] = 'Bearer ' .. domoticz.globalData.TadoToken },
				callback = 'TadoGetStateCallback'
			})
			
			return
			
		end
		
	-- Process HTTP response to token request and store tado authentication token in globalData
		
		if (item.isHTTPResponse) then
		
		-- Process TadoGetZonesCallback trigger event (Response to request for Zones list)
		
			if (item.trigger == 'TadoGetZonesCallback') then
				if (item.ok) then -- success
					if (item.isJSON) then
--						domoticz.log('ZONE 1 = ' .. item.json[1].name, domoticz.LOG_DEBUG)
						if item.json[1].name == nil then
							domoticz.log('ERROR - No Zone info Received. DATA=<START>' .. item.data .. '<END>', domoticz.LOG_ERROR)
						else
							domoticz.globalData.TadoZones = item.json

						-- Iterate through each Zone in the list and place an API call to get that zones specific info
						
							for i=1,#domoticz.globalData.TadoZones,1
							do
								domoticz.log('Process zone ' .. tostring(i), domoticz.LOG_DEBUG)

								domoticz.openURL({
									url = 'https://my.tado.com/api/v2/homes/' .. domoticz.globalData.TadoHomeId .. '/zones/' .. tostring(i) .. '/state',
									method = 'GET',
									headers = { ['Authorization'] = 'Bearer ' .. domoticz.globalData.TadoToken },
									callback = 'TadoGetZoneInfoCallback' .. tostring(i)
								})
							end
							
						end
					end
				else
					domoticz.log('There was an error', domoticz.LOG_ERROR)
				end
				
				return				
			end	

		-- Process TadoGetZonesCallback trigger event (Response to request for Users list)
		
			if (item.trigger == 'TadoGetUsersCallback') then
				if (item.ok) then -- success
					if (item.isJSON) then
						if item.json[1].name == nil then
							domoticz.log('ERROR - No Users info Received. DATA=<START>' .. item.data .. '<END>', domoticz.LOG_ERROR)
						else
							domoticz.globalData.TadoUsers = item.json
						end
					end
				else
					domoticz.log('There was an error', domoticz.LOG_ERROR)
				end
				
				return
			end	

		-- Process TadoGetStateCallback trigger event (Response to request for Tado state)

			if (item.trigger == 'TadoGetStateCallback') then
				if (item.ok) then -- success
					if (item.isJSON) then

						if item.json.presence == nil then
							domoticz.log('ERROR - No Tado Mode  info Received. DATA=<START>' .. item.data .. '<END>', domoticz.LOG_ERROR)
						else
							domoticz.globalData.TadoMode = item.json.presence
						domoticz.log('TADO STATE=' .. domoticz.globalData.TadoMode, domoticz.LOG_DEBUG)
						end
					end
				else
					domoticz.log('There was an error', domoticz.LOG_ERROR)
				end
				
				return
			end	

		-- Process TadoGetZoneInfoCallback* (one of multiple requests for per-zone stats info)
			
			if string.find(item.trigger, 'TadoGetZoneInfoCallback') ~= nil then

--				domoticz.log('DATA='..item.data, domoticz.LOG_DEBUG)		-- Uncomment to Dump all data returned

			-- Get Zone number from trigger suffix
			
				local zone = tonumber(string.sub(item.trigger,24))
				domoticz.log('ZONE=' .. tostring(zone), domoticz.LOG_DEBUG)

			-- Check if Override is turned on or not for this zone
			
				if (item.json.overlayType == 'MANUAL') then
					domoticz.log('... Overlay ON', domoticz.LOG_DEBUG)
					domoticz.globalData.TadoZoneOverlays[zone]=true
				else
					domoticz.log('... Overlay OFF', domoticz.LOG_DEBUG)
					domoticz.globalData.TadoZoneOverlays[zone]=false
				end
				
			-- Get and store Zone current setpoint temp from JSON
			
				local temp = tonumber(item.json.setting.temperature.celsius)

				domoticz.log('... Setpoint(C) = ' .. tostring(temp), domoticz.LOG_DEBUG)

				domoticz.globalData.TadoZoneTemps[zone]=temp

				return
			end
		
			domoticz.log('Unrecognised Callback - ' .. item.trigger, domoticz.LOG_ERROR)

		end
	end
}
