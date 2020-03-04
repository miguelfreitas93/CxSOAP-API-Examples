######## Checkmarx Config ########
#Install-Module -Name "CredentialManager"
$credentials = Get-StoredCredential -Target "CxPortal" –AsCredentialObject
 
$domain = "http://localhost"
$username = $credentials.UserName
$password = $credentials.Password
$monthsAgo = 6

######## Login ########
$proxy = New-WebServiceProxy -Uri "${domain}/CxWebInterface/Portal/CxWebService.asmx?wsdl"
$proxyType = $proxy.gettype().Namespace
$credentials = new-object ("$proxyType.Credentials")
$credentials.User = $username
$credentials.Pass = $password
$res = $Proxy.Login($credentials, 1033) 
$sessionId = $res.SessionId

if ($res.IsSuccesfull) {
    Write-Host "Login Success!"

    $users = $proxy.GetAllUsers($sessionId).UserDataList
    $totalUsers = $users.Count
    Write-Host "Total Users: ${totalUsers}"
    $activeUsersLessMonths = @()
    $activeUsersMoreMonths = @()
    $inactiveUsersMoreMonths = @()
    foreach ($user in $users) {
        $id = $user.ID
        [datetime]$createdDate = $user.DateCreated
        [datetime]$lastLoginDate = $user.LastLoginDate
        if ((Get-Date).AddMonths(-$monthsAgo) -lt $createdDate) {
            $activeUsersLessMonths += $user
            # Users Created Less than X months ago
            # Write-Host "User ${id} Created at: ${createdDate} Last Login at: ${lastLoginDate}"
        }
        else {
            if ((Get-Date).AddMonths(-$monthsAgo) -lt $lastLoginDate) {
                $activeUsersMoreMonths += $user
                # Users Created More than X months ago but they logged in less than X months ago
                # Write-Host "User ${id} Created at: ${createdDate} Last Login at: ${lastLoginDate}"
            }
            else {
                $inactiveUsersMoreMonths += $user
                # Write-Host "User ${id} Created at: ${createdDate} Last Login at: ${lastLoginDate}"
            }
        }
    }

    function getPercentage($part, $total) {
        return [math]::Round((($part * 100) / $total), 2)
    }

    $totalActiveLessMonths = $activeUsersLessMonths.Count
    $totalActiveMoreMonths = $activeUsersMoreMonths.Count
    $totalInactiveMoreMonths = $inactiveUsersMoreMonths.Count

    Write-Host "Active Users (Less ${monthsAgo} months account created): ${totalActiveLessMonths} ("(getPercentage $totalActiveLessMonths $totalUsers )"%)"
    Write-Host "Active Users (More ${monthsAgo} months account created): ${totalActiveMoreMonths} ("(getPercentage $totalActiveMoreMonths $totalUsers )"%)"
    Write-Host "Inactive Users (More ${monthsAgo} months account created): ${totalInactiveMoreMonths} ("(getPercentage $totalInactiveMoreMonths $totalUsers )"%)`n`n"

    foreach ($activeUserMoreMonths in $activeUsersMoreMonths) {
        $id = $activeUserMoreMonths.ID
        $email = $activeUserMoreMonths.Email
        $role = $activeUserMoreMonths.RoleData.Name
        [datetime]$lastLogin = $activeUserMoreMonths.LastLoginDate
        if (!($email -like "*@checkmarx.com") -and ($email -ne "admin@cx")) {
            #Write-Host "ACTIVE MORE ${monthsAgo} MONTHS - User ${id} - ${email} - ${role} - Last Login : ${lastLogin}"
        }
    }

    foreach ($inactiveUser in $inactiveUsersMoreMonths) {
        $id = $inactiveUser.ID
        $email = $inactiveUser.Email
        $role = $inactiveUser.RoleData.Name
        [datetime]$lastLogin = $inactiveUser.LastLoginDate
        if (!($email -like "*@checkmarx.com") -and ($email -ne "admin@cx")) {
            Write-Host "INACTIVE - User ${id} - ${email} - ${role} - Last Login : ${lastLogin}"
        }
    }

}
else {
    Write-Error "Login Failed!"
}