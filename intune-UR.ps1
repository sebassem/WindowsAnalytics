<#
.SYNOPSIS

Deploy the upgrade readiness script to your intune managed devices


.DESCRIPTION

The script allows to run the upgrade readiness script to the intune managed devices , you have to edit the parameters needed for the upgrade readiness script directly here and then
upload to intune.

Script steps:
-------------
The scripts downloads the latest deployment script from the internet
the script adds your varaibles to the the config file
the script creates a scheduled task that runs once every 30 days

#>
################Edit Variables##########################
$downloadpath = "c:\UA-upgradeReadiness"
$logfile = "$downloadpath\log.txt"
$logPath = "\\cm1\wadiagnostics"
$commercialID ="xxxxxxxxxxxxxxxxxxxxxxxx"
$AllowIEData = "false"
$IEOptInLevel = "3"
$DeviceNameOptIn ="true"
$AppInsightsOptIn="true"
$ClientProxy= "Direct"
###################################################



function Get-TimeStamp {
    
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}

##Create the download folder
try{
    if(-not (Test-Path $downloadpath)){
        New-Item -Path $downloadpath -ItemType Directory
    }
    else{
        ##cleanup previous runs
        Remove-Item $downloadpath -Force -Recurse
        New-Item -Path $downloadpath -ItemType Directory
    }
}
catch{
    Write-Output "$(Get-TimeStamp) $_.Exception.Message" | Out-file $logfile -append
    throw "Cannot create folder on C drive"
    
}

##Get the download URL from the download center
try{
    $WebResponse = Invoke-WebRequest "https://www.microsoft.com/en-us/download/confirmation.aspx?id=53327" -UseBasicParsing
    $downloadURL=($WebResponse.Links | select href | where {$_.href -like "*zip"})[0].href.tostring()

}
catch{
    
    Write-Output "$(Get-TimeStamp) $_.Exception.Message" | Out-file $logfile -append
    throw "Couldn't reach the download URL"

}

##Download the UR script to a folder on the C drive and extract
try{
    $output = "$downloadpath\upgradeReadiness.zip"
    (New-Object System.Net.WebClient).DownloadFile($downloadURL, $output)
    $output | Expand-Archive -Force -DestinationPath "$downloadpath\script"
}
catch{
    Write-Output "$(Get-TimeStamp) $_.Exception.Message" | Out-file $logfile -append
    throw "Couldn't download or extract the file"
}

##Edit the config file for the deployment script
try{
    $configfile = "$downloadpath\script\deployment\RunConfig.bat"
    (Get-Content $configfile).replace('set logPath=\\set\path\here', 'set logPath='+$logPath) | Set-Content $configfile
    (Get-Content $configfile).replace('set commercialIDValue=Unknown', 'set commercialIDValue='+$commercialID) | Set-Content $configfile
    (Get-Content $configfile).replace('set AllowIEData=disabled', 'set AllowIEData='+$AllowIEData) | Set-Content $configfile
    (Get-Content $configfile).replace('set IEOptInLevel=0', 'set IEOptInLevel='+$IEOptInLevel) | Set-Content $configfile
    (Get-Content $configfile).replace('set DeviceNameOptIn=true', 'set DeviceNameOptIn='+$DeviceNameOptIn) | Set-Content $configfile
    (Get-Content $configfile).replace('set AppInsightsOptIn=true', 'set AppInsightsOptIn='+$AppInsightsOptIn) | Set-Content $configfile
    (Get-Content $configfile).replace('set ClientProxy=Direct', 'set ClientProxy='+$ClientProxy) | Set-Content $configfile
}
catch{
     Write-Output "$(Get-TimeStamp) $_.Exception.Message" | Out-file $logfile -append
    throw "One or more of the script parameters are not correct"
}

##create the scheduled task

try{
    if(Get-ScheduledTask -TaskName "Upgrade readiness script" -ErrorAction SilentlyContinue){
        Unregister-ScheduledTask -TaskName "Upgrade readiness script" -Confirm:$false
    }
    $taskAction = New-ScheduledTaskAction -Execute "$downloadpath\script\Deployment\RunConfig.bat"
    $tasktrigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -At 9am -DaysOfWeek Tuesday -RandomDelay (New-TimeSpan -minutes 30)
    $taskoptions = New-ScheduledTaskSettingsSet -DisallowDemandStart -StartWhenAvailable
    $taskprincipal = New-ScheduledTaskPrincipal -UserId "NTAuthority\SYSTEM" -LogonType ServiceAccount
    New-ScheduledTask -Description "Upgrade readiness script" -Action $taskaction -Principal $taskprincipal -Settings $taskoptions -Trigger $tasktrigger
    Register-ScheduledTask -TaskName "Upgrade readiness script" -Action $taskAction -User "SYSTEM" -Trigger $tasktrigger
    Start-ScheduledTask -TaskName "Upgrade readiness script"
}
catch{
     Write-Output "$(Get-TimeStamp) $_.Exception.Message" | Out-file $logfile -append
    throw "Cannot create the scheduled task"
}

