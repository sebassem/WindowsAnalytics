# WindowsAnalytics
The script allows to deploy the upgrade readiness script to your azure active directory joined machines using intune.

The script allows to run the upgrade readiness script to the intune managed devices , you have to edit the parameters needed for the upgrade readiness script directly here and then
upload to intune.

## Script steps:
* The scripts downloads the latest deployment script from the internet
* The script adds your varaibles to the the config file
* The script creates a scheduled task that runs once every 30 days
