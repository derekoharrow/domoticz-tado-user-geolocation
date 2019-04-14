return {
	helpers = {},
	data = {
		TadoAwayTemp = { initial = 15 },			-- Desired temp to use when person is Away
		TadoToken  = { initial = '' },				-- Placeholder for Tado authentication token
		TadoHomeId = { initial = '' },				-- Placeholder for Tado HomeId
		TadoZones = { initial = '' },				-- Placeholder for Tado Zone info
		TadoZoneModes = { initial = {} },			-- Placeholder for Tado Zone Modes
		TadoZoneTemps = { initial = {} },			-- Placeholder for Tado Zone Temps
		TadoZoneOverlays = { initial = {} },		-- Placeholder for Tado Zone Overlay flags (true/false per zone)
		TadoUsers = { initial = '' },				-- Placeholder for retrieved Tado User information
		TadoMode = { initial = '' },				-- Placeholder for Tado Mode state (HOME/AWAY)
		TadoClientId = { initial = 'tado-web-app' },															-- Check at https://my.tado.com/webapp/env.js
		TadoClientSecret = { initial = 'wZaRN7rpjn3FoNyF5IFuxg9uMzYJcvOoQ8QWiIqS3hfk6gLhVlG57j5YNoZL2Rtc' },	-- Check at https://my.tado.com/webapp/env.js
		TadoUserMapping = { initial = { ["Fred Smith"] = "Fred's bedroom", ["John Doe"] = "John's Study"} }  -- Maps usernames to zone names
	}
}
