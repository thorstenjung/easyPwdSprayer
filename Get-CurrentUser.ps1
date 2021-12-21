[PSCustomObject]@{
'env:USERNAME' = $env:USERNAME
'whoami'       = whoami.exe
'GetCurrent'   = [Security.Principal.WindowsIdentity]::GetCurrent().Name
} | Format-List | Out-File -FilePath C:\temp\whoami.txt
