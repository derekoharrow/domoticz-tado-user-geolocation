--
-- TADO-GET-STATUS.LUA
-- ===================
--
-- Every 15 minutes, get the Tado Zones information
--
-- Token is stored in domoticz.globalData.TadoZones
--

return {

	logging = {
--		level = domoticz.LOG_DEBUG,			-- Uncomment this line to enable debugging
		marker = "TADO-GET-STATUS"
	},

   on = {
		timer = {'every 2 minutes'},
		httpResponses = { 'TadoGetZonesCallback', 'TadoGetUsersCallback' }
	},

	execute = function(domoticz,item)

		-- Check TadoToken has been set first. Won't work without it.
		if domoticz.globalData.TadoToken == '' then
			domoticz.log('ERROR: Tado token not set', domoticz.LOG_ERROR)
			return
		end
		if domoticz.globalData.TadoHomeId == '' then
			domoticz.log('ERROR: Tado HomeId not set', domoticz.LOG_ERROR)
			return
		end
				
		if (item.isTimer) then
			domoticz.log('Making HTTP call to tado to get Zones info', domoticz.LOG_DEBUG)

			domoticz.openURL({
				url = 'https://my.tado.com/api/v2/homes/' .. domoticz.globalData.TadoHomeId .. '/zones',
				method = 'GET',
				headers = { ['Authorization'] = 'Bearer ' .. domoticz.globalData.TadoToken },
				callback = 'TadoGetZonesCallback'
			})

			domoticz.log('Making HTTP call to tado to get Users info', domoticz.LOG_DEBUG)

			domoticz.openURL({
				url = 'https://my.tado.com/api/v2/homes/' .. domoticz.globalData.TadoHomeId .. '/users',
				method = 'GET',
				headers = { ['Authorization'] = 'Bearer ' .. domoticz.globalData.TadoToken },
				callback = 'TadoGetUsersCallback'
			})
			
			return
			
		end
		
		-- Process HTTP response to token request and store tado authentication token in globalData
		
		if (item.isHTTPResponse) then
		
			-- Process TadoGetZonesCallback trigger event			
			if (item.trigger == 'TadoGetZonesCallback') then
				if (item.ok) then -- success
					if (item.isJSON) then
--						domoticz.log('ZONE 1 = ' .. item.json[1].name, domoticz.LOG_DEBUG)
						if item.json[1].name == nil then
							domoticz.log('ERROR - No Zone info Received. DATA=<START>' .. item.data .. '<END>', domoticz.LOG_ERROR)
						else
							domoticz.globalData.TadoZones = item.json
						end
					end
				else
					domoticz.log('There was an error', domoticz.LOG_ERROR)
				end
				
				return
				
			end	

			-- Process TadoGetUsersCallback trigger event			
			if (item.trigger == 'TadoGetUsersCallback') then
				if (item.ok) then -- success
					if (item.isJSON) then
--						domoticz.log('USER 1 = ' .. item.json[1].name, domoticz.LOG_DEBUG)

						if item.json[1].name == nil then
							domoticz.log('ERROR - No Users info Received. DATA=<START>' .. item.data .. '<END>', domoticz.LOG_ERROR)
						else
							domoticz.globalData.TadoUsers = item.json
						end
					end
				else
					domoticz.log('There was an error', domoticz.LOG_ERROR)
				end
			end	

		end
	end
}
