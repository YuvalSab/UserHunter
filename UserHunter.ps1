Function UserHunter {
    param(
        [string]$UserName,
        [string]$DomainName
    )

    Write-Host "[*] Start User Hunting!" -ForegroundColor Yellow
    Start-Sleep 1
    Write-Host "[*] Note that this operation is very noisy.. " -ForegroundColor Yellow 
    Write-Host "----------------------------------------------"
    Start-Sleep 1
    $domain = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$DomainName")
    $searcher = New-Object System.DirectoryServices.DirectorySearcher($domain)
    $searcher.Filter = "(&(objectCategory=computer)(!userAccountControl:1.2.840.113556.1.4.803:=8192))"
    $searcher.PropertiesToLoad.AddRange(@("name"))
    $computers = $searcher.FindAll() | ForEach-Object { $_.Properties["name"] }

    $activeSessions = @()
    foreach ($computer in $computers) {
        $session = (quser /server:$computer 2>$null | Select-String -Pattern $UserName)
        if ($session) {
            $activeSessions += $computer
        }
    }

    if ($activeSessions.Count -gt 0) {
        Write-Host "[+] Active Sessions Were Found ON:" -ForegroundColor Green
        $activeSessions | Format-Table -AutoSize
    } else {
        Write-Host "[-] No active sessions were found..." -ForegroundColor Red
    }
}

# Usage:
# UserHunter -UserName "<Target User>" -DomainName "<Domain.com>"
