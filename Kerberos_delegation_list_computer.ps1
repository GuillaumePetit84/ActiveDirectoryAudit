# DATA :
$COMPUTERS = @()
$COMPUTERS = Get-ADComputer -Filter * -Properties userAccountControl,msDS-AllowedToDelegateTo,msDS-AllowedToActOnBehalfOfOtherIdentity | Select Name,userAccountControl,msDS-AllowedToDelegateTo,msDS-AllowedToActOnBehalfOfOtherIdentity
$UAC_FINAL = @()


# TRANSFORM user :
$TOTAL_LENGTH = 32

# TRANSFORM computer :
$UAC_FINAL = @()


$COMPUTERS.PSObject.Properties | ForEach-Object {
    foreach ($value in $_.Value)
    {
        $UAC_BINARY = [Convert]::ToString($value.userAccountControl,2)
        $OFFSET = $TOTAL_LENGTH - $UAC_BINARY.Length
        $UAC_FULL = "0" * $OFFSET
        $UAC_FINAL = "$UAC_FULL$UAC_BINARY"

        $kerberos_constraint = ($value | Select-Object -OutVariable msDS-AllowedToDelegateTo | Select msDS-AllowedToDelegateTo  | Out-String)

        if ($UAC_FINAL[12] -eq "1" -or $kerberos_constraint -match "{.+}")
        {
            Write-Host $value.Name
            if ($value.'msDS-AllowedToDelegateTo' -gt 0)
            {
                Write-Host -ForegroundColor green "[+] Délégation Kerberos contrainte"
                $result = $kerberos_constraint | Select-String -Pattern "{.+}" | % {"$($_.matches.groups[0])"}
                Write-Host $result
            }
            else
            {
                Write-Host -ForegroundColor red "[!] Délégation Kerberos non contrainte"
            }
            Write-Host ""
        }
    }
}
