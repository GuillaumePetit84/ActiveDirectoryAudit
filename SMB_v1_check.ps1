$Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$ADS = $Forest.Sites | % { $_.Servers } | Select Name

$OUT_FILE =  ".\Check_SMB_USAGE.txt"                 
$LOG_NAME = "Microsoft-Windows-SMBServer/Audit"
$INSTANCE_ID = "3000"
$ALL = @()

$Today = (Get-Date)
$ADS.PSObject.Properties | ForEach-Object {
    foreach ($value in $_.Value)
    {
        if ($value.Name)
        {
            $AD = $value.Name
            Write-Host -ForegroundColor Green "[+] $AD"

            try
            {
                $log = Get-WinEvent -ComputerName $AD -LogName $LOG_NAME -ErrorAction Stop | Select-Object TimeCreated,Message,Id | Where-Object { $_.Id -eq $INSTANCE_ID } | Select-Object -First 10
                Write-Host -ForegroundColor Red "[!] Detect new connection SMB Version 1 connection" 
                $result = @()
                $log.PSObject.Properties | ForEach-Object {
                    foreach ($value in $_.Value)
                    {

                        $IPSRC = ($value.Message | Select-String -Pattern "Adresse du client :.*" -AllMatches).Matches.Value
                        $IPSRC = $IPSRC | %{$_ -replace "Adresse du client : ", ""}
                        $IPSRC = [regex]::split($IPSRC,"\s{1,}")
                        
                        $result += $value.TimeCreated
                        $result += $IPSRC
                        $result += "`n"
                        

                    }

                }
                Write-Host $result 

            }
            catch [Exception] 
            {
                if ($_.Exception -match "Aucun événement correspondant aux critères de sélection spécifiés n'a été trouvé.") 
                {
                    Write-Host -ForegroundColor Green "[+] Aucun hôte n'a tenté d'accéder au serveur via SMBv1"
                }
            }
        }
    }
}

