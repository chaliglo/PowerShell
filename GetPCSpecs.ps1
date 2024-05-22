# Function that gets the CPU informations
function getCPU {
   # Title
   Write-Host "CPU Spec
"
   # Gets the CPU information
   $cpuInfo = Get-WmiObject Win32_Processor

   # Display CPU model and base speed
   Write-Host "CPU: $($cpuInfo.Name)"
   Write-Host "CPU Base Speed: $($cpuInfo.MaxClockSpeed) MHz"
}


# Function that gets all Storage Disk information
function getDisk {
   # Title
   Write-Host "Disk Drive Spec
"
   # Get information about physical disks
   $disks = Get-PhysicalDisk

   # Display information about each disk and determine whether it's an SSD or HDD. Used ChatGPT for help
   foreach ($disk in $disks) {
       $driveType = if ($disk.MediaType -eq "SSD") { "SSD" } else { "HDD" }
  
   # Get drive letters. Used ChatGPT for help
   $driveLetter = Get-Partition -DiskNumber $disk.DeviceID | Get-Volume | Select-Object -ExpandProperty DriveLetter


   # Display drive letters. Used ChatGPT for help
   foreach ($letter in $driveLetter) {
       Write-Host "Drive Letter: $($driveLetter)"
   }
       # Displays name of disk
       Write-Host "Disk Model: $($disk.Model)"

       # Displays size of disk. Got how to round number here: https://stackoverflow.com/questions/52148464/powershell-round-up-function
       Write-Host "Disk Size: $([math]::Round($disk.Size / 1GB, 2)) GB"

       # Displays what kind of disk it is
       Write-Host "Disk Type: $driveType"

       Write-Host "------------------------"
   }
}


# Function to get RAM information
function getRAM {
   # Title
   Write-Host "RAM Spec
"
   # Get information about installed RAM
   $RAM = Get-CimInstance -ClassName Win32_PhysicalMemory

   # Calculate total installed RAM in GB. Used ChatGPT for help
   $totalRAMinGB = ($RAM | Measure-Object -Property Capacity -Sum).Sum / 1GB

   # Display total installed RAM
   Write-Host "Memory: $totalRAMinGB GB"


   # Get the performance counter for available RAM. Used ChatGPT for help
   $availableRAMCounter = Get-Counter "\Memory\Available Bytes"

   # Get the total installed RAM
   $totalRAM = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory

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
}


# Function to get GPU information
function getGPU {
   # Title
   Write-Host "GPU Spec
"
   # Get GPU information using WMI
   $gpuInfo = Get-WmiObject Win32_VideoController

   # Display GPU model
   foreach ($gpu in $gpuInfo) {
       Write-Host "GPU: $($gpu.Name)"
       Write-Host "------------------------"
   }
}



function getSummary {
   # Title
   Write-Host "PC Spec Summary
"

   # CPU
   $cpuInfo = Get-WmiObject Win32_Processor

   Write-Host "CPU Model: $($cpuInfo.Name)"
   Write-Host "------------------------"

   $gpuInfo = Get-WmiObject Win32_VideoController

   # GPU
   foreach ($gpu in $gpuInfo) {
       Write-Host "GPU Model: $($gpu.Name)"
       Write-Host "------------------------"
   }

   # RAM
   $RAM = Get-CimInstance -ClassName Win32_PhysicalMemory
   $totalRAM = ($RAM | Measure-Object -Property Capacity -Sum).Sum / 1GB

   Write-Host "Memory: $totalRAM GB"
   Write-Host "------------------------"


   # Disks
   $disks = Get-PhysicalDisk

   foreach ($disk in $disks) {
   $driveLetter = Get-Partition -DiskNumber $disk.DeviceID | Get-Volume | Select-Object -ExpandProperty DriveLetter


   foreach ($letter in $driveLetter) {
       Write-Host "Drive letter: $($driveLetter)"
   }
       Write-Host "Disk Model: $($disk.Model)"
       Write-Host "------------------------"
   }
}



function getData {
   # Array to hold the data
   $getDataArray = @()

   # CPU
   $cpuInfo = Get-WmiObject Win32_Processor
   
   # Adds into array
   $getDataArray += "CPU Model: $($cpuInfo.Name)"

   $gpuInfo = Get-WmiObject Win32_VideoController

   # GPU
   foreach ($gpu in $gpuInfo) {
       $getDataArray += "GPU Model: $($gpu.Name)"
   }

   # RAM
   $RAM = Get-CimInstance -ClassName Win32_PhysicalMemory

   $totalRAMinGB = ($RAM | Measure-Object -Property Capacity -Sum).Sum / 1GB

   $getDataArray += "Memory: totalRAMinGB GB"

   # Disks
   $disks = Get-PhysicalDisk

   foreach ($disk in $disks) {
   $driveLetter = Get-Partition -DiskNumber $disk.DeviceID | Get-Volume | Select-Object -ExpandProperty DriveLetter

   foreach ($letter in $driveLetter) {
       $getDataArray += "Drive letter: $($driveLetter)"
   }
       $getDataArray += "Disk Model: $($disk.Model)"
   }
   # Shows content in array
   $getDataArray
}

# Got inspiration from workplace supervisor script in using "do". Learned more at https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_do?view=powershell-7.4
do {
   # To make the CLS clean
   cls
   # Get user's input
   $decision = Read-Host "What PC Spec would you like to look at?

(1) PC Spec Summary
(2) CPU
(3) GPU
(4) RAM (memory)
(5) Storage

Please select a number from 1-5 or type 'q' to quit"

cls
# Got inspiration from workplace supervisor script in using "do". Learned more at https://lazyadmin.nl/powershell/powershell-switch-statement/
   switch ($decision) {
      '1' {
         # Calls getSummary Function
         getSummary

         Write-Host "" 

         $saveInfo = Read-Host "Would you like to save this info? (y/n)"

         switch ($saveInfo) {
            'y' {

               # Variable to hold hostname
               $hostname = hostname

               # Variable to hold
               $filePath = "C:\Temp\$hostname.txt"

               # Variable to hold
               $data = getData

               # if condition to test if path is exist and if it doesn't, it will make the path. Used ChatGPT for help
               if (-not (Test-Path -Path C:\Temp -PathType Container)) {
               New-Item -Path C:\Temp -ItemType Directory -Force

               # Outputs data into a text file
               $data | Out-File -FilePath $filePath
                  }

               # Message to let you know where text file was saved
               Write-Host "
Info has been saved in C:\Temp as $hostname.txt
"
               Read-Host "Press 'Enter' to continue"
            }
            'n' {
               Write-Host "" 
               Read-Host "Press 'Enter' to continue"
            }
         }
      }
      '2' {
         getCPU 
         Write-Host "" 
         Read-Host "Press 'Enter' to continue"
      }
      '3' {
         getGPU 
         Write-Host "" 
         Read-Host "Press 'Enter' to continue"
      }
      '4' {
         getRAM
         Write-Host "" 
         Read-Host "Press 'Enter' to continue"
      }
      '5' {
         getDisk
         Write-Host ""
         Read-Host "Press 'Enter' to continue"
      }
   } 
} until($decision -eq 'q') # exits out of script when entering the letter 'q'
