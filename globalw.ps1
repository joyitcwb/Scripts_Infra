
#Cria estrura de pastas Joy

md c:\joy\backup
md c:\joy\scripts
md c:\joy\aplicativos

#Cria estrura de pastas 

function BackupLocal
{
     param (
           [string]$Title = 'Script Global Joy IT'
     )
     clear
     Write-Host "================ $Title ================"
    
     Write-Host "1: Digite '1' para CPJ [ template - t07 ] "
     Write-Host "2: Digite '2' para Iperius [ template - t04 ]"
     Write-Host "S: Digite 's' para sair."
}

do
{
     BackupLocal
     $input = Read-Host "Escolha um opção"
     switch ($input)
     {
           '1' {
               md c:\joy\backup\cpj
               md c:\joy\scripts\zabbix
               wget https://raw.githubusercontent.com/joyitcwb/Scrips_Infra/master/scripts/t07_s002_status.ps1 -Outfile c:\joy\scripts\zabbix
               
               $fileContents = Get-Content C:\Program Files\Zabbix Agent\zabbix_agentd.conf

               $fileContents[2] += "`r`n####Joy IT"
               $fileContents[2] += "`r`nUserParameter=discovery.backup.iperius[*],powershell.exe -noprofile -executionpolicy bypass -File c:\zabbix\scripts\discovery.backup.iperius.ps1"
               $fileContents[2] += "`r`nUserParameter=discovery.backup.iperius.dados[*],powershell.exe -noprofile -executionpolicy bypass -File c:\zabbix\scripts\discovery.backup.iperius.ps1`r`n"
               
               $fileContents | C:\Program Files\Zabbix Agent\zabbix_agentd.conf
               Restart-Service -Name "Zabbix Agent"            

                'You chose option #1'
           } '2' {
                cls
                'You chose option #2'          
           } 's' {
                return
           }
     }
     pause
}
until ($input -eq 's')