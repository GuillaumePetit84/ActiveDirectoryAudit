# DATA :
$UAC = $USERS | ForEach-Object { Get-ADUser -Filter * -Properties userAccountControl} | Select SamAccountName,userAccountControl

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

            if ($UAC_FINAL[9] -eq "1")
            {
                Write-Host $value.SamAccountName
                Write-Host -ForegroundColor red "[!] L'utilisateur est vulnérable à l'attaque AS_REP roasting"
            }
        }
    }
}