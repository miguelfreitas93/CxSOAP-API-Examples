<#
.SYNOPSIS
    Powershell Script to Create an Empty Preset in Checkmarx
.DESCRIPTION
    Powershell Script to Create an Empty Preset in Checkmarx given a specific name
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
    # Checkmarx URL (eg. http://localhost) - Required
    [Parameter(
        Position = 0,
        Mandatory = $true,
        HelpMessage = "Checkmarx URL"
    )][string[]] $domain,
    # Checkmarx Username (eg. admin@cx) - Required
    [Parameter(
        Position = 1,
        Mandatory = $true,
        HelpMessage = "Checkmarx Username (eg. admin@cx) - Required"
    )][string] $sqlServerName,
    # SQL Database - Required
    [Parameter(
        Position = 2,
        Mandatory = $true,
        HelpMessage = "SQL Database"
    )][string] $sqlDatabase
)

######## Checkmarx Config ########
#Install-Module -Name "CredentialManager"
$credentials = Get-StoredCredential -Target "CxPortal" –AsCredentialObject
 
$domain = "http://localhost"
$username = $credentials.UserName
$password = $credentials.Password
$presetName = "Test Preset"


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
######## Create Empty Preset ########
function createEmptyPreset($proxy, $sessionId, $userId, $presetName){
    $proxyType = $proxy.gettype().Namespace
    $preset = new-object ("$proxyType.CxPresetDetails")
    $preset.isUserAllowToDelete = $true
    $preset.isUserAllowToUpdate = $true
    $preset.isPublic = $true
    $preset.IsDuplicate = $false
    $preset.name = $presetName
    $preset.owner = $userId
    $preset.owningteam = "00000000-0000-0000-0000-000000000000"
    $preset.queryIds = @()

    $res = $proxy.CreateNewPreset($sessionId, $preset)
    if($res.IsSuccesfull){
        return $res.preset
    } else{
        Write-Host "Failed to Create Preset ${presetName}:" $res.ErrorMessage
        Write-Host "Preset might already exists or Invalid Preset Name"
        exit 1
    }
}

$proxy = getProxy $domain
$sessionId = login $proxy $username $password
createEmptyPreset $proxy $sessionId $username $presetName
Write-Host "Preset ${presetName} created with success !"
