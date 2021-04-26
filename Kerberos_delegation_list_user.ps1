# DATA :
$USERS = Get-ADGroupMember -Identity Administrateurs -Recursive | Select SamAccountName
$UAC = $USERS | ForEach-Object { Get-ADUser $_.SamAccountName -Properties userAccountControl} | Select SamAccountName,userAccountControl

# TRANSFORM user :
$TOTAL_LENGTH = 32

$UAC.PSObject.Properties | ForEach-Object {
    foreach ($value in $_.Value)
    {
        if ($value.SamAccountName)
        {
            $UAC_BINARY = [Convert]::ToString($value.userAccountControl,2)
            $OFFSET = $TOTAL_LENGTH - $UAC_BINARY.Length
            $UAC_FULL = "0" * $OFFSET
            $UAC_FINAL = "$UAC_FULL$UAC_BINARY"

            Write-Host $value.SamAccountName

            if ($UAC_FINAL[11] -eq "1")
            {
                Write-Host -ForegroundColor green "[+] L'authentification du compte ne peux pas être délégué"
            }
            else
            {
                Write-Host -ForegroundColor red "[!] L'authentification du compte peux être délégué"
            }
            Write-Host ""
        }
    }
}