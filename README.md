# Winserver Log Parser
The project consists of PowerShell scripts on Windows Server 2022 that provide readable logs for:
- Internet Information Services (ISS) server
- Failed login attempts to the system
- Information about programmes installed within a specified time period
- Changes that occured in the system registry

The server was obtained as a configured Virtual Hard Drive from Microsoft's official evaluation center. The system dates are in British format ("mm/dd/yyyy hh:mm:ss AM/PM"), which is crucial when providing dates to the scripts.

## Running Scripts
When running scripts, it is required to be logged in with an account that has administrator privileges.

## Monitoring IIS Server Logs
### System Configuration
Roles related to the Web Server (suggested by Windows + Basic Authentication) and Management Tools (suggested by Windows) have been installed using Server Manager.

IIS Server is configured to generate daily log files for the entire server in W3C format. The configuration was done through the GUI, and log files are located at the default path: C:\inetpub\logs\wmsvc\W3SVC1.

### Script Operation
The script (iis_parser.ps1) takes two dates (down to seconds) from the user and displays logs between them. It iterates through log files in the W3SVC1 folder, verifying file names with the regular expression "ex*.log". For each file, it checks the content based on another regular expression describing the possible log format. It verifies if the file is within the specified time range, considering date format standardization. If there's a match with the given time, the logs, specifically their crucial elements from an administrator's perspective, are displayed.

### Script Parameters
- startDate [date] – specifies the lower time range for script log search. If not provided, the lower time range will not be considered.
- endDate [date] – specifies the upper time range for script log search. If not provided, the upper time range will not be considered.

### Running the Script
Example script invocation for iis_parser.ps1:
.\iis_parser.ps1 -startDate "01/01/2024 00:00:00 AM" -endDate "01/02/2024 00:00:00 AM"

## List of Failed System Logins
### System Configuration
Using Edit Group Policy, enable auditing of failed logins under:
"Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration > System Audit Policies > Logon/Logoff."

Remote Access server role has been installed via Server Manager, allowing remote system access using Microsoft's Remote Desktop Protocol.

### Script Operation
The script (failed_logins.ps1) retrieves information about events related to failed logins (ID = 4625) from the Windows Event Log. It allows specifying the time range of interest with second accuracy. The script can filter remote logins (LogonType=3) and local logins (LogonType=2). Output can be displayed in a simplified version containing key information or in a full version containing event creation date and the complete event message.

### Script Parameters
- dateFrom [date] – specifies the lower time range for script log search. If not provided, the lower time range will not be considered.
- dateTo [date] – specifies the upper time range for script log search. If not provided, the upper time range will not be considered.
- detailed [switch] – when set, the output will be in the form of full, original Windows Event Log messages.
- remoteOnly [switch] – when set, the script will only return information about remote logins.
- localOnly [switch] – when set, the script will only return information about local logins.

### Running the Script
Example script invocation for failed_logins.ps1:
.\failed_logins.ps1 -dateFrom "01/01/2024 00:00:00 AM" -dateTo "01/02/2024 00:00:00 AM" -detailed -remoteOnly

## List Of Installed Programs in a Given Period
### Script Operation
The script (installed_apps.ps1) searches through the "Uninstall" registry folders (HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion and HKLM:\Software\Microsoft\Windows\CurrentVersion) and lists installed programs whose installation date (down to the day) matches the specified time frames. Programs without installation dates are listed at the bottom as warnings.

A second script (repair_dates.ps1) attempts to solve the issue of missing dates. Based on the registry path, it finds the program folder and copies its creation date to the appropriate registry location.

### Script Parameters
#### installed_apps.ps1:
- startDate [date] – specifies the lower time range for script log search. If not provided, the lower time range will not be considered.
- endDate [date] – specifies the upper time range for script log search. If not provided, the upper time range will not be considered.
- hideWarnings [switch] – disables displaying warnings about installed programs for which the installation date could not be determined from the registry.
  
####repair_dates.ps1:
- Does not require any parameters.

### Running the Script
Example script invocation for installed_apps.ps1:
.\installed_apps.ps1 -startDate "01/01/2024 00:00:00 AM" -endDate "01/02/2024 00:00:00 AM" -hideWarnings

Example script invocation for repair_dates.ps1:
.\repair_dates.ps1

## Registry Changes Analysis
### System Configuration
To monitor registry changes, proper Audit Policies must be set in Group Policy Editor, similar to the example for logging. Choose the "Audit Registry Properties" option, focusing on successful attempts.

Select the registry key within which you want to monitor changes. In this example, we will monitor changes in the key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip, where changes will involve value modifications in the key, and information about them will be sent to the administrator.

### Script Operation
The script (registry_tracking.ps1) searches the event log based on IDs 4657 and 4663, optionally within the specified time range. It then outputs information about the events in a simplified form (id, time, domain, user, key path, value name, old value, new value) or in a full form (entire message).

### Script Parameters
- dateFrom [date] – specifies the lower time range for which the script searches logs. If not provided, the lower time range will not be considered.
- dateTo [date] – specifies the upper time range for which the script searches logs. If not provided, the upper time range will not be considered.

### Running the Script
Example script invocation for registry_tracking.ps1:
./registry_tracking -dateFrom '11/25/2023 8:22:07 PM' -dateTo '11/25/2023 8:23:00 PM'
