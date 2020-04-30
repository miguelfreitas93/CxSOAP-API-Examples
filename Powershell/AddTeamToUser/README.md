# Add multiple teams to an existing user

Powershell parameterized script to add multiple teams, in different teams or not, to an existing Checkmarx user.

Please take into account the following considerations when running this script:
- Do not use this script for Application Users
- Assure New team has the same type of the existing User Team (Service Provider, Company or Team)
- Assure the User exists in Checkmarx Server
- Assure the New Team exists in Checkmarx Server
- User Role will remain exactly the same

# Documentation:
```cmd
Get-Help .\AddTeamToExistingUser.ps1 -Detailed

NAME
    .\AddTeamToExistingUser.ps1
    
SYNOPSIS
    Powershell Script to add User to Multiple Teams
    
    
SYNTAX
    .\AddTeamToExistingUser.ps1 [-serverUrl] <String> [-username] <String> [-password] <String> 
    [-newTeamPath] <String> [-userUsername] <String> [<CommonParameters>]
    
    
DESCRIPTION
    Powershell Script to add User to Multiple Teams
    

PARAMETERS
    -serverUrl <String>
        Checkmarx Server URL - Required
        
    -username <String>
        Checkmarx Username - Required
        
    -password <String>
        Checkmarx Password - Required
        
    -newTeamPath <String>
        Checkmarx Teams Paths - Required
        
    -userUsername <String>
        Checkmarx User email - Required
    
REMARKS
    To see the examples, type: "get-help .\AddTeamToExistingUser.ps1 -examples".
    For more information, type: "get-help .\AddTeamToExistingUser.ps1 -detailed".
    For technical information, type: "get-help .\AddTeamToExistingUser.ps1 -full".
```

# Example:

```cmd
.\AddTeamToExistingUser.ps1 http://localhost admin@cx ******** "/CxServer/Service Provider/Company1/Team1" "DOMAIN\Administrator"
```

# Important Note:

This will only work properly for Non-Application Users, since password is not being stored on Checkmarx side.
Creation of Application users will fail, because the user needs to be deleted and recreated again and we cannot recover the his password.

