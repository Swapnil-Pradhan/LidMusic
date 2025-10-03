property lastState : ""
property userPowerMode : ""
property helperDir : (POSIX path of (path to library folder from user domain)) & "Application Support/LidMusic/"
property helperURL : "https://github.com/Swapnil-Pradhan/LidMusic/archive/refs/tags/helper.zip"

on run
	-- Install helpers if not already installed
	set helperPath to helperDir & "checkLowPower.sh"
	if not (do shell script "[ -f " & quoted form of helperPath & " ] && echo exists || echo missing") is "exists" then
		try
			-- Create folder
			do shell script "mkdir -p " & quoted form of helperDir
			
			-- Download helper.zip
			set zipPath to helperDir & "helper.zip"
			do shell script "curl -L " & quoted form of helperURL & " -o " & quoted form of zipPath with administrator privileges
			
			-- Extract files into helperDir
			do shell script "unzip -o " & quoted form of zipPath & " -d " & quoted form of helperDir with administrator privileges
			
			-- Move all .sh files from subfolder (GitHub wraps with LidMusic-*)
			do shell script "find " & quoted form of helperDir & " -type f -name '*.sh' -exec mv {} " & quoted form of helperDir & " \\;" with administrator privileges
			
			-- Now chmod after files exist (fixed line)
			do shell script "find " & quoted form of helperDir & " -name '*.sh' -exec chmod +x {} \\;" with administrator privileges
			
			-- Cleanup zip and leftover extracted folder
			do shell script "rm -f " & quoted form of zipPath
			do shell script "find " & quoted form of helperDir & " -type d -name 'LidMusic-*' -exec rm -rf {} +" with administrator privileges
			
			-- Configure sudoers (safe: only for these scripts)
			set currentUser to do shell script "whoami"
			set sudoersLine to currentUser & " ALL=(ALL) NOPASSWD: " & helperDir & "nosleep.sh, " & helperDir & "sleep.sh, " & helperDir & "checkLowPower.sh, " & helperDir & "lowPowerOn.sh, " & helperDir & "lowPowerOff.sh"
			do shell script "echo '" & sudoersLine & "' | sudo tee /etc/sudoers.d/LidMusicHelper" with administrator privileges
			do shell script "chmod 440 /etc/sudoers.d/LidMusicHelper" with administrator privileges
			
			display dialog "LidMusic helpers installed successfully!" buttons {"OK"} default button "OK"
		on error errMsg
			display dialog "Failed to install LidMusic helpers: " & errMsg buttons {"OK"} default button "OK"
		end try
	end if
end run

on idle
	set anyPlaying to false
	
	-- Check Music
	if application "Music" is running then
		tell application "Music"
			try
				if player state is playing then set anyPlaying to true
			end try
		end tell
	end if
	
	-- Check Spotify
	if application "Spotify" is running then
		tell application "Spotify"
			try
				if player state is playing then set anyPlaying to true
			end try
		end tell
	end if
	
	-- Decide state
	set currentState to ""
	if anyPlaying then
		set currentState to "playing"
	else
		set currentState to "paused"
	end if
	
	-- Only act when state changes
	if currentState ­ lastState then
		set lastState to currentState
		
		if currentState is "playing" then
			do shell script quoted form of (helperDir & "nosleep.sh") with administrator privileges
			set userPowerMode to do shell script "pmset -g | grep 'lowpowermode' | awk '{print $2}'"
			if userPowerMode = "0" then
				do shell script quoted form of (helperDir & "lowPowerOn.sh") with administrator privileges
			end if
		else
			do shell script quoted form of (helperDir & "sleep.sh") with administrator privileges
			if userPowerMode = "0" then
				do shell script quoted form of (helperDir & "lowPowerOff.sh") with administrator privileges
			end if
		end if
	end if
	
	return 2 -- run again every 2 seconds
end idle