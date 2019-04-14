return {

	logging = {
		level = domoticz.LOG_DEBUG, -- Uncomment to override the dzVents global logging setting
		marker = 'TADOTEST'
	},
	
	on = {
		timer = {'every minute'}
	},

	execute = function(domoticz)

		if domoticz.globalData.TadoUsers == '' then
			domoticz.log ('TadoUsers not set', domoticz.LOG_DEBUG)
			return
		end

		if domoticz.globalData.TadoZones == '' then
			domoticz.log ('TadoZones not set', domoticz.LOG_DEBUG)
			return
		end

		local usercount = #domoticz.globalData.TadoUsers
		local zonecount = #domoticz.globalData.TadoZones

		domoticz.log('User count=' .. tostring(usercount), domoticz.LOG_DEBUG)
		domoticz.log('Zone count=' .. tostring(zonecount), domoticz.LOG_DEBUG)
		
		domoticz.globalData.initialize('TadoUserMapping')
		
		for i=1, usercount, 1
		do
			local username = domoticz.globalData.TadoUsers[i].name
			domoticz.log('User =' .. username, domoticz.LOG_DEBUG)
			local userzone = domoticz.globalData.TadoUserMapping[username]
			if userzone ~= nil then
				domoticz.log('....Mapped User Zone = ' .. userzone, domoticz.LOG_DEBUG)
				for j=1, zonecount, 1
				do
					local zonename = domoticz.globalData.TadoZones[j].name
					domoticz.log('Zone =' .. zonename, domoticz.LOG_DEBUG)
					if zonename == userzone then
						domoticz.log('.. MATCH FOUND', domoticz.LOG_DEBUG)
					end
				end
			else
				domoticz.log('....User ' .. username .. ' UNMAPPED', domoticz.LOG_DEBUG)
			end
		end


	end

}
