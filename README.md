#Winserver Log Parser

<b>Usage example is added as a comment in each script. Tested WinServer was using American/British date format</b>

<br><br>

<b>Failed Logins Parser</b>
<br>
This script failed_logins.ps1 enables user to display all failed login attempts from specified period of time. It can cover remote logins and local logins, both individually and combined.
Tracking logins requires enabling logins audit in GPE. 

<br><br>

<b>Installation Dates</b>
<br>
The script installed_apps.ps1 displays list of executable programms installed in period of time given by the user. It's data is loaded from Windows Register, but unfortunately,
not all installers save installation date to the registry. In that case you can use script repair_dates.ps1 which updates registry with dates from installed files properties.

<br><br>
