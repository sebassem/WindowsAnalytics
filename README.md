# WindowsAnalytics
The script allows to deploy the upgrade readiness script to your azure active directory joined machines using intune.

The script allows to run the upgrade readiness script to the intune managed devices , you have to edit the parameters needed for the upgrade readiness script directly here and then
upload to intune.

## Usage:

1. Download the intune-UR.ps1 script and save it to your computer.
2. Edit the script using any text editor to supply the variables in the following section :
    ```powershell 
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
     ```
| Variable name | Description |
| ------------- | ------------- |
| downloadpath  | This is the path where the upgrade readiness script will be downloaded from the internet |
| logfile       | This is the name of the logfile that will be generated for troubleshooting this script |
| logPath  | This is the path where the logfile for each device will be created , it can be a UNC path and it can be a local path  |
| commercialID | This is the commericalID of your OMS Workspace |
| AllowIEData | This is the IE diagnostics optIn option | 
| IEOptInLevel | This is the level of the IE optIN option |
| DeviceNameOptIn | This is the DeviceNameOptIn option to send the device name to the diagnostic data management service |
| AppInsightsOptIn | This is the AppInsightsOptIn to collect and send diagnostic and debugging data to Microsoft | 
| ClientProxy | This is used to specofy the proxy setup that you have in your environment |

**You can find detailed information about the upgrade readiness script and it's variables in this [link](https://docs.microsoft.com/en-us/windows/deployment/upgrade/upgrade-readiness-deployment-script#running-the-script)**
