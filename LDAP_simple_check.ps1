$Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$AD = $Forest.Sites | % { $_.Servers } | Select Name

$OUT_FILE =  ".\Check_SMB_USAGE.txt"                 
$LOG_NAME = "Directory service"
$INSTANCE_ID = "1073744713"
$ALL = @()
$DOMAIN = (Get-ADDomain | Select-Object NetBIOSName).NetBIOSName

# Reset Content
echo "" > $OUT_FILE

While($true)
{
    ForEach ($AD in $ADS)
    {
        $logs = Get-EventLog -ComputerName $AD -LogName $LOG_NAME -InstanceId $INSTANCE_ID -ErrorAction SilentlyContinue | Select-Object TimeGenerated,Message
        if ($logs)
        {
            ForEach ($log in $logs)
            {
                $MESSAGE = ($log).Message
                $DATE = ($log).TimeGenerated 

                $IPSRC = ($MESSAGE | Select-String -Pattern "\d{1,3}(\.\d{1,3}){3}" -AllMatches).Matches.Value
                try { $DNSSRC = [System.Net.Dns]::GetHostbyAddress($IPSRC).HostName }
                catch { $DNSSRC = $IPSRC}
                $IPDST = [System.Net.Dns]::GetHostAddresses($AD).IPAddressToString
                $User = ($MESSAGE | Select-String  -Pattern "$DOMAIN\\.*" -AllMatches).Matches.Value

                $check = cat $OUT_FILE | Select-String $IPSRC
                if ($check -eq $null)
                {
                    Write-Host "[!] Detect new connection LDAP simple bind communication" -ForegroundColor Green
                    Write-Host "$IPSRC,$DNSSRC to $AD with $User"
                    Write-Host 
                    echo "$IPSRC,$DNSSRC,$IPDST,$User;" >> $OUT_FILE
                }
            }
        }
    }
    Start-Sleep -Seconds 10
}

