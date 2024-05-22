function localComputerTools {
	cls
	Write-Host "-----------------------------------"
	Write-Host "  Computer Tools: Local Computer"
	Write-Host "-----------------------------------"
	Write-Host ""
	Write-Host "
(1) System Info
(2) Get User Who Logged In
(3) Rename
(4) Back to Menu
(5) Quit
"
    Write-Host ""
$userChoice = Read-Host "What would you like to do"
switch ($userChoice) {
	'1' {
	cls
# (1) System Info
# Get computer system info
		$computerInfo = Get-CimInstance Win32_ComputerSystem
# Computer name
		Write-Host "--------------"
		Write-Host "Computer Name"
		Write-Host "--------------"
		Write-Host ""
		$hostname = hostname
		$hostname
		Write-Host ""
# Network Info
		Write-Host "--------------------"
		Write-Host "Network Information"
		Write-Host "--------------------"
		Write-Host ""
		$networkInfo = Get-WmiObject win32_networkadapterconfiguration | Where-Object { $_.IPEnabled -eq $true -and $_.MACAddress -ne $null } | Select-Object -First 1

		if ($networkInfo) {
    			$ipAddress = $networkInfo.IPAddress
    			Write-Host "IP Address: $ipAddress"

    		$macAddress = $networkInfo.MacAddress
    			Write-Host "MAC Address: $macAddress"
		} else {
 		   	Write-Host "No network adapter information found."
		}
		Write-Host ""

# Get information about the system BIOS
		$systemBIOS = Get-CimInstance -ClassName Win32_BIOS

	# Display the serial number
		Write-Host "-------------------"
		Write-Host "System Information"
		Write-Host "-------------------"
		Write-Host ""
		Write-Output "Serial Number: $($systemBIOS.SerialNumber)"
# get Computer model
		$computerModel = $computerInfo.Model
	# Get the current date and time
		$currentDateTime = Get-Date

	# Get the last boot time of the system
		$lastBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

	# Calculate the uptime
		$uptimeTimeSpan = $currentDateTime - $lastBootTime 
		$uptime = '{0:00}:{1:00}:{2:00}' -f $uptimeTimeSpan.Hours, $uptimeTimeSpan.Minutes, $uptimeTimeSpan.Seconds
	# Output the uptime
		Write-Output "Computer Uptime: $uptime"

# Get information about the operating system
		$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem

	# Display the operating system information
		Write-Output "Operating System: $($osInfo.Caption)"
	# Gets the CPU information
			$cpuInfo = Get-WmiObject Win32_Processor

# Display CPU model and base speed
			Write-Host ""
			Write-Host "-----------------"
			Write-Host "CPU Information"
			Write-Host "-----------------"
			Write-Host ""
			Write-Host "CPU: $($cpuInfo.Name)"
			Write-Host "CPU Base Speed: $($cpuInfo.MaxClockSpeed) MHz"
			Write-Host ""
	
# Get information about installed RAM
	$RAM = Get-CimInstance -ClassName Win32_PhysicalMemory

	# Calculate total installed RAM in GB. Used ChatGPT for help
   	$totalRAMinGB = ($RAM | Measure-Object -Property Capacity -Sum).Sum / 1GB

   	# Display total installed RAM
		Write-Host "----------------"
		Write-Host "RAM Information"
		Write-Host "----------------"
		Write-Host ""
   		Write-Host "Memory: $([math]::Round($totalRAMinGB)) GB"


   	# Get the performance counter for available RAM. Used ChatGPT for help
  		$availableRAMCounter = Get-Counter "\Memory\Available Bytes"

   	# Get the total installed RAM
   		$totalRAM = $computerInfo.TotalPhysicalMemory

  	# Calculate used memory in bytes
  		$usedRAM = $totalRAM - $availableRAMCounter.CounterSamples.CookedValue

   	# Convert bytes to GB
   		$usedRAMinGB = $usedRAM / 1GB

  	# Output the used RAM in GB
  		Write-Output "Used RAM: $([math]::Round($usedRAMinGB, 2)) GB / $totalRAMinGB GB"


  	# Get RAM speed. Used ChatGPT for help
  		$ramSpeed = Get-WmiObject -Class Win32_PhysicalMemory | Select-Object -First 1 -ExpandProperty Speed
  		$ramSpeedInMHz = $ramSpeed

   	# Display RAM speed
   		Write-Host "RAM is running at $($ramSpeedInMHz) MHz."
  	# Get GPU information using WMI
		Write-Host ""
		Write-Host "----------------"
		Write-Host "GPU Information"
		Write-Host "----------------"
		Write-Host ""
  		$gpuInfo = Get-WmiObject Win32_VideoController

# Display GPU model
  		foreach ($gpu in $gpuInfo) {
      			Write-Host "GPU: $($gpu.Name)"
        }
# Disks
		Write-Host ""
		Write-Host "-----------------------"
		Write-Host "Hard Disk Information"
		Write-Host "-----------------------"
   		Write-Host ""
		$disks = Get-PhysicalDisk

   		foreach ($disk in $disks) {
   			$driveLetter = Get-Partition -DiskNumber $disk.DeviceID | Get-Volume | Select-Object -ExpandProperty DriveLetter


   		foreach ($letter in $driveLetter) {
       			Write-Host "Drive letter: $($driveLetter)"
   		}
       			Write-Host "Disk Model: $($disk.Model)"
	    }
    Write-Host ""
	Read-Host "Press 'Enter' to continue"
	localComputerTools
    }
	'2' {
		cls
# (2) Get User Who Logged In
# Retrieve user profiles and select relevant properties
		$userProfiles = Get-WmiObject -Class Win32_UserProfile | Select-Object -ExpandProperty LocalPath

# Extract usernames from profile paths
		$usernames = $userProfiles | ForEach-Object { Split-Path -Path $_ -Leaf }

# Output the information
		Write-Host "
Here are the users that have logged into the computer
"
		$usernames
    	Write-Host ""
	Read-Host "Press 'Enter' to continue"
	localComputerTools
	}
	'3' {
	cls
# (3) Rename
		$newComputerName = Read-Host "What would you like to your new computer name to be"
		Rename-Computer -NewName $newComputerName
		$restart = Read-Host "Would you like to restart now? (y/n)"
		switch ($restart) {
			'y' {
				shutdown /r
			}
			'n' {
				Write-Host ""
				Read-Host "Press 'Enter' to continue"
				localComputerTools
			}
		}
	}
  
	'4' {
# (4) Back to Menu
	}
	'5' {
# (5) Quit
	exit
	}
}}


function networkComputerTools {
	cls
	$remoteComputer = Read-Host "What network computer would you like to connect to"
	$remoteComputer 
	cls
	Write-Host "-----------------------------------"
	Write-Host " Computer Tools: Network Computer"
	Write-Host "-----------------------------------"
	Write-Host "
(1) System Info
(2) Get User Who Logged In
(3) Rename
(4) Remote Shutdown
(5) Remote Restart
(6) Back to Menu
(7) Quit
"
    Write-Host ""
$userChoice = Read-Host "What would you like to do"
switch ($userChoice) {
	'1' {
	cls
	Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
# (1) System Info
# Get computer system info
		$computerInfo = Get-CimInstance Win32_ComputerSystem
# Computer name
		Write-Host "--------------"
		Write-Host "Computer Name"
		Write-Host "--------------"
		Write-Host ""
		$hostname = hostname
		$hostname
		Write-Host ""
# Network Info
		Write-Host "--------------------"
		Write-Host "Network Information"
		Write-Host "--------------------"
		Write-Host ""
		$networkInfo = Get-WmiObject win32_networkadapterconfiguration | Where-Object { $_.IPEnabled -eq $true -and $_.MACAddress -ne $null } | Select-Object -First 1

		if ($networkInfo) {
    			$ipAddress = $networkInfo.IPAddress
    			Write-Host "IP Address: $ipAddress"

    		$macAddress = $networkInfo.MacAddress
    			Write-Host "MAC Address: $macAddress"
		} else {
 		   	Write-Host "No network adapter information found."
		}
		Write-Host ""

# Get information about the system BIOS
		$systemBIOS = Get-CimInstance -ClassName Win32_BIOS

	# Display the serial number
		Write-Host "-------------------"
		Write-Host "System Information"
		Write-Host "-------------------"
		Write-Host ""
		Write-Output "Serial Number: $($systemBIOS.SerialNumber)"
# get Computer model
		$computerModel = $computerInfo.Model
	# Get the current date and time
		$currentDateTime = Get-Date

	# Get the last boot time of the system
		$lastBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

	# Calculate the uptime
		$uptimeTimeSpan = $currentDateTime - $lastBootTime 
		$uptime = '{0:00}:{1:00}:{2:00}' -f $uptimeTimeSpan.Hours, $uptimeTimeSpan.Minutes, $uptimeTimeSpan.Seconds
	# Output the uptime
		Write-Output "Computer Uptime: $uptime"

# Get information about the operating system
		$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem

	# Display the operating system information
		Write-Output "Operating System: $($osInfo.Caption)"
	# Gets the CPU information
			$cpuInfo = Get-WmiObject Win32_Processor

# Display CPU model and base speed
			Write-Host ""
			Write-Host "-----------------"
			Write-Host "CPU Information"
			Write-Host "-----------------"
			Write-Host ""
			Write-Host "CPU: $($cpuInfo.Name)"
			Write-Host "CPU Base Speed: $($cpuInfo.MaxClockSpeed) MHz"
			Write-Host ""
	
# Get information about installed RAM
	$RAM = Get-CimInstance -ClassName Win32_PhysicalMemory

	# Calculate total installed RAM in GB. Used ChatGPT for help
   	$totalRAMinGB = ($RAM | Measure-Object -Property Capacity -Sum).Sum / 1GB

   	# Display total installed RAM
		Write-Host "----------------"
		Write-Host "RAM Information"
		Write-Host "----------------"
		Write-Host ""
   		Write-Host "Memory: $([math]::Round($totalRAMinGB)) GB"


   	# Get the performance counter for available RAM. Used ChatGPT for help
  		$availableRAMCounter = Get-Counter "\Memory\Available Bytes"

   	# Get the total installed RAM
   		$totalRAM = $computerInfo.TotalPhysicalMemory

  	# Calculate used memory in bytes
  		$usedRAM = $totalRAM - $availableRAMCounter.CounterSamples.CookedValue

   	# Convert bytes to GB
   		$usedRAMinGB = $usedRAM / 1GB

  	# Output the used RAM in GB
  		Write-Output "Used RAM: $([math]::Round($usedRAMinGB, 2)) GB / $totalRAMinGB GB"


  	# Get RAM speed. Used ChatGPT for help
  		$ramSpeed = Get-WmiObject -Class Win32_PhysicalMemory | Select-Object -First 1 -ExpandProperty Speed
  		$ramSpeedInMHz = $ramSpeed

   	# Display RAM speed
   		Write-Host "RAM is running at $($ramSpeedInMHz) MHz."
  	# Get GPU information using WMI
		Write-Host ""
		Write-Host "----------------"
		Write-Host "GPU Information"
		Write-Host "----------------"
		Write-Host ""
  		$gpuInfo = Get-WmiObject Win32_VideoController

# Display GPU model
  		foreach ($gpu in $gpuInfo) {
      			Write-Host "GPU: $($gpu.Name)"
        }
# Disks
		Write-Host ""
		Write-Host "-----------------------"
		Write-Host "Hard Disk Information"
		Write-Host "-----------------------"
   		Write-Host ""
		$disks = Get-PhysicalDisk

   		foreach ($disk in $disks) {
   			$driveLetter = Get-Partition -DiskNumber $disk.DeviceID | Get-Volume | Select-Object -ExpandProperty DriveLetter


   		foreach ($letter in $driveLetter) {
       			Write-Host "Drive letter: $($driveLetter)"
   		}
       			Write-Host "Disk Model: $($disk.Model)"
	    }
    Write-Host ""
	Read-Host "Press 'Enter' to continue"
    }}
	'2' {
		cls
# (2) Get User Who Logged In
# Retrieve user profiles and select relevant properties
			Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
$userProfiles = Get-WmiObject -Class Win32_UserProfile | Select-Object -ExpandProperty LocalPath

# Extract usernames from profile paths
		$usernames = $userProfiles | ForEach-Object { Split-Path -Path $_ -Leaf }

# Output the information
		Write-Host "
Here are the users that have logged into the computer
"
		$usernames
    	Write-Host ""
	Read-Host "Press 'Enter' to continue"
	}}

	'3' {
	cls
# (3) Rename
		$newComputerName = Read-Host "What would you like to your new computer name to be"
		Rename-Computer -ComputerName $remoteComputer -NewName $newComputerName
		$restart = Read-Host "Would you like to restart now? (y/n)"
		switch ($restart) {
			'y' {
				shutdown /r /m \\$remoteComputer
			}
			'n' {
				Write-Host ""
				Read-Host "Press 'Enter' to continue"
			}
		}
	}
	'4' {
# (4) Remote Shutdown
		cls
		shutdown /m \\$remoteComputer
		Write-Host "$remoteComputer is shutting down..."
		Read-Host "
Press 'Enter' to continue"
	}
	'5' {
# (5) Remote Restart
		cls
		shutdown /r /m \\$remoteComputer
		Write-Host "$remoteComputer is restarting..."
		Read-Host "
Press 'Enter' to continue"
	}
	'6' {
# (6) Back to Menu
	}
	'7' {
# (7) Quit
	exit
	}

}}

# Pick options
do {
	# Clears screen
	cls
	# Title
	Write-Host "----------------------------"
	Write-Host "       Computer Tools"
	Write-Host "----------------------------"
	# Get user input
	$choice = Read-Host "
(1) Local computer
(2) Connect to network computer
(3) Exit

What would you like do?"

	cls

	switch($choice) {
		'1' {
			localComputerTools
		}
		'2' {
			networkComputerTools
		}
    } 
} until ($choice -eq '3')