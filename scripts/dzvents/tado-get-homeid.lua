--
-- TADO-GET-HOMEID.LUA
-- =============
--
-- Every 15 minutes, get the Tado Home ID 
--
-- ID is stored in domoticz.globalData.TadoHomeID
--

return {

	logging = {
--		level = domoticz.LOG_DEBUG,			-- Uncomment this line to enable debugging
		marker = "TADO-GET-HOMEID"
	},

   on = {
		timer = {'every 15 minutes'},
		httpResponses = { 'TadoGetHomeIdCallback' }
	},

	execute = function(domoticz,item)

	-- Check TadoToken has been set first. Won't work without it.
		if domoticz.globalData.TadoToken == '' then
			domoticz.log('ERROR: Tado token not set', domoticz.LOG_ERROR)
			return
		end
		
	-- Make a call to Tado to request the HomeId
		if (item.isTimer) then
			domoticz.log('Making HTTP call to tado to get HomeId', domoticz.LOG_DEBUG)
			domoticz.openURL({
				url = 'https://my.tado.com/api/v1/me/',
				method = 'GET',
				headers = { ['Authorization'] = 'Bearer ' .. domoticz.globalData.TadoToken },
				callback = 'TadoGetHomeIdCallback'
			})
		end
		
	-- Process HTTP response to token request and store tado authentication token in globalData
		if (item.isHTTPResponse) then
		
		-- Process TadoAuthCallback trigger event			
			if (item.trigger == 'TadoGetHomeIdCallback') then
				if (item.ok) then -- success
					if (item.isJSON) then
					domoticz.log('DATA=<START>' .. item.data .. '<END>', domoticz.LOG_DEBUG)
						if item.json.homeId == nil then
							domoticz.log('ERROR - No TadoHomeId Received. DATA=<START>' .. item.data .. '<END>', domoticz.LOG_ERROR)
						else
							domoticz.globalData.TadoHomeId = item.json.homeId
							domoticz.log('Tado HomeId=<START>' .. domoticz.globalData.TadoHomeId .. '<END>', domoticz.LOG_DEBUG)
						end
					end
				else
					domoticz.log('There was an error', domoticz.LOG_ERROR)
				end
			end	

		end
	end
}
