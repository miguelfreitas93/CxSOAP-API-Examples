<#
.SYNOPSIS
    Powershell Script to add Team to Existing User
.DESCRIPTION
    Powershell Script to add Team to Existing User
.PARAMETER Path
    The path to the .
.PARAMETER LiteralPath
    Specifies a path to one or more locations. Unlike Path, the value of
    LiteralPath is used exactly as it is typed. No characters are interpreted
    as wildcards. If the path includes escape characters, enclose it in single
    quotation marks. Single quotation marks tell Windows PowerShell not to
    interpret any characters as escape sequences.
#>
Param(
    # Checkmarx Server URL - Required
    [Parameter(
        Position = 0,
        Mandatory = $true,
        HelpMessage = "Checkmarx Server URL (eg. http://localhost)"
    )][string] $serverUrl,
    # Checkmarx Username - Required
    [Parameter(
        Position = 1,
        Mandatory = $true,
        HelpMessage = "Checkmarx Username (eg. admin@cx)"
    )][string] $username,
    # Checkmarx Password - Required
    [Parameter(
        Position = 2,
        Mandatory = $true,
        HelpMessage = "Checkmarx Password (eg. admin@cx)"
    )][string] $password,
    # Checkmarx Teams Paths - Required
    [Parameter(
        Position = 3,
        Mandatory = $true,
        HelpMessage = "Checkmarx New Teams Path (eg. /CxServer/SP/Company1/Team1)"
    )][string] $newTeamPath,
    # Checkmarx User email - Required
    [Parameter(
        Position = 4,
        Mandatory = $true,
        HelpMessage = "Checkmarx User Username (eg. Domain\12345)"
    )][string] $userUsername
)
######## Checkmarx Config ########
Write-Host "Connecting to '${serverUrl}' with Username '${username}'"

# Available User Types:
# Application
# Domain
# OpenID
# SAML
# SSO
# LDAP
# None
# This will only work for Non-Application Users, since password is not being stored on Checkmarx side.
# Creation of Application users will fail, because the user needs to be deleted and recreated again and we cannot recover the password
$userType="Domain" 

if($userUsername.Count -eq 0){
    Write-Host "No User Username Provided. Please provide user email, for example: first.last@company.com"
    exit 1
} else {
    Write-Host "User Username: ${userUsername}"
}
if($newTeamPath.Count -eq 0){
    Write-Host "No New Team Paths provided. Please provide new team paths, for example: /CxServer/SP/Company1/Team1"
    exit 1
} else {
    Write-Host "New Team Path: ${newTeamPath}"
}

######## Get Proxy ########
function getProxy($domain){
    return New-WebServiceProxy -Uri ${domain}/CxWebInterface/Portal/CxWebService.asmx?wsdl
}
######## Login ########
function login($proxy, $user, $pass){
    $proxyType = $proxy.gettype().Namespace

    $credentials = new-object ("$proxyType.Credentials")
    $credentials.User = $user
    $credentials.Pass = $pass
    $res = $proxy.Login($credentials, 1033) 
    
    if($res.IsSuccesfull){
        return $res.SessionId
    } else{
        Write-Host "Login Failed : " $res.ErrorMessage
        exit 1
    }
}
######## Get All Teams ########
function getTeams($proxy, $sessionId){
    $res = $proxy.GetAllTeams($sessionId)
    if($res.IsSuccesfull){
        return $res.TeamDataList
    } else{
        Write-Host "Failed to Get Teams : " $res.ErrorMessage
        exit 1
    }
}
######## Get Team Full Path ########
function getTeamFullPath($proxy, $sessionId, $teamId){
    $res = $proxy.GetTeamFullPaths($sessionId, $teamId, $teamId)
    return $res.sourceTeamFullPath
}
function getTeamId($proxy, $sessionId, $teamPath){
    $teams = getTeams $proxy $sessionId
    foreach($team in $teams){
        $teamId = $team.Team.Guid
        $teamFullPath = getTeamFullPath $proxy $sessionId $teamId
        if($teamFullPath -eq $teamPath){
            return $teamId
        }
    }
    Write-Error "Failed to retrieve team ID of ${teamPath}"
    Write-Error "Team ${teamPath} might not exist"
    exit 1
}
######## Get All Users ########
function getUsers($proxy, $sessionId){
    $res = $proxy.GetAllUsers($sessionId)
    if($res.IsSuccesfull){
        return $res.UserDataList
    } else{
        Write-Host "Failed to Get Users : " $res.ErrorMessage
        exit 1
    }
}

function getUserIdByEmail($proxy, $sessionId, $username){
    $users = getUsers $proxy $sessionId
    foreach($user in $users){
        if($user.UserName -eq $username){
            return $user.ID
        }
    }
    Write-Error "User ${username} was not found"
    exit 1
}
######## Get User By ID ########
function getUser($proxy, $sessionId, $userId){
    $res = $proxy.GetUserById($sessionId, $userId)
    if($res.IsSuccesfull){
        return $res.UserData
    } else{
        Write-Host "Failed to Get Users : " $res.ErrorMessage
        exit 1
    }
}
######## Delete User By ID ########
function deleteUserById($proxy, $sessionId, $userId){
    $res = $proxy.DeleteUser($sessionId, $userId)
    if($res.IsSuccesfull){
        return $res.IsSuccesfull
    } else{
        Write-Host "Failed to Delete User ${userId} : " $res.ErrorMessage
        exit 1
    }
}

$proxy = getProxy $serverUrl
$sessionId = login $proxy $username $password

$userId = getUserIdByEmail $proxy $sessionId $userUsername
$user = getUser $proxy $sessionId $userId
#Write-Host ($user | ConvertTo-Json -Depth 1)
$proxyType = $proxy.gettype().Namespace

$userData = new-object ("$proxyType.UserData")

$teamId = getTeamId $proxy $sessionId $newTeamPath
$team = new-object ("$proxyType.Group")
$team.Guid = $teamId

$user.GroupList += $team

$userData.IsActive = $user.IsActive
$userData.RoleData = $user.RoleData
$userData.FirstName = $user.FirstName
$userData.LastName = $user.LastName
$userData.UserPreferedLanguageLCID = $user.UserPreferedLanguageLCID
$userData.Password = $user.Password
$userData.JobTitle = $user.JobTitle
$userData.Email = $user.Email
$userData.UserName = $user.Username
$userData.UPN = $user.UPN
$userData.Phone = $user.Phone
$userData.CellPhone = $user.CellPhone
$userData.Skype = $user.Skype
$userData.CompanyID = $user.CompanyID
$userData.CompanyName = $user.CompanyName
$userData.willExpireAfterDays = $user.willExpireAfterDays
$userData.country = $user.country
$userData.AuditUser = $user.AuditUser
$userData.GroupList = $user.GroupList
$userData.LastLoginDate = $user.LastLoginDate
$userData.LimitAccessByIPAddress = $user.LimitAccessByIPAddress
$userData.AllowedIPs = $user.AllowedIPs
Write-Host "`n"
#Write-Host ($userData | ConvertTo-Json -Depth 1)

$userDeleted = deleteUserById $proxy $sessionId $userId
$res = $proxy.AddNewUser($sessionId, $userData, $userType)
if($res.IsSuccesfull){
    Write-Host "User ${userUsername} Updated with Success!"
} else{
    Write-Error "Failed to Add New User" $res.ErrorMessage
    Write-Error "User with ${userUsername} might already exist"
}