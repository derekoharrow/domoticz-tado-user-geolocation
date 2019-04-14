--
-- TADO-AUTH.LUA
-- =============
--
-- Every 6 minutes, authenticate with Tado and get/refresh authentication token.
--
-- Token is stored in domoticz.globalData.TadoToken
--

return {

	logging = {
--		level = domoticz.LOG_DEBUG,					-- Uncomment this line to enable debugging
		marker = "TADO-AUTH"
	},

   on = {
		timer = {'every 6 minutes'},				-- Expires every 10 minutes, but LUA only allows 6 minute checking...
		httpResponses = { 'TadoAuthCallback' }
	},

	execute = function(domoticz,item)

	-- Make a call to Tado to request authorisation token	
		if (item.isTimer) then
			domoticz.log('Making HTTP call to tado', domoticz.LOG_DEBUG)
			domoticz.openURL({
				url = 'https://auth.tado.com/oauth/token',
				headers = {['Content-type'] = 'application/x-www-form-urlencoded'},
				method = 'POST',
				callback = 'TadoAuthCallback',
--				postData = "client_id=public-api-preview&client_secret=4HJGRffVR8xb3XdEUQpjgZ1VplJi6Xgw&grant_type=password&password=" .. domoticz.variables('TadoPassword').value .. "&scope=home.user&username=" .. domoticz.variables('TadoUsername').value
				postData = "client_id=" .. domoticz.globalData.TadoClientId .. "&public-api-preview&client_secret=" .. domoticz.globalData.TadoClientSecret .. "&grant_type=password&password=" .. domoticz.variables('TadoPassword').value .. "&scope=home.user&username=" .. domoticz.variables('TadoUsername').value
			})

		end
		
		-- Process HTTP response to token request and store tado authentication token in globalData
		
		if (item.isHTTPResponse) then
		
		-- Process TadoAuthCallback trigger event
			if (item.trigger == 'TadoAuthCallback') then
				if (item.ok) then -- success
					if (item.isJSON) then
						domoticz.globalData.TadoToken = item.json.access_token
						if domoticz.globalData.TadoToken == nil then
							domoticz.log('ERROR - No Token Received. DATA=<START>' .. item.data .. '<END>', domoticz.LOG_DEBUG)
						else
							domoticz.log('Access token=<START>' .. domoticz.globalData.TadoToken .. '<END>', domoticz.LOG_DEBUG)
						end
					end
				else
					domoticz.globalData.TadoToken = ''
					domoticz.log('There was an error', domoticz.LOG_ERROR)
				end
			end	

		end
	end
}
