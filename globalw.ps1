function BackupLocal
{
     param (
           [string]$Title = 'Script Global Joy IT'
     )
     clear
     Write-Host "================ $Title ================"
     Write-Host ""
     Write-Host "1: Digite '1' para Criar estrutura padrao de pastas da Joy IT  "
     Write-Host "2: Digite '2' para CPJ [ template - t07 ] "
     Write-Host "3: Digite '3' para Iperius [ template - t04 ]"
     Write-Host "S: Digite 's' para sair."
}

do
{
     BackupLocal
     $input = Read-Host "Escolha um opcao"
     switch ($input)
     {
          '1' {
               Write-Host "Criando estrutura de pastas padrao"
               md c:\joy\backup
               md c:\joy\scripts
               md c:\joy\aplicativos
               md c:\joy\scripts\zabbix
          }     
          '2' {
               Write-Host "Criando estrutura de pastas padrao do template"
               md c:\joy\backup\cpj\sql
               md c:\joy\backup\cpj\archive
               md c:\joy\scripts\cpj
               Write-Host ""

               Write-Host "Baixando scripts"              
               wget https://raw.githubusercontent.com/joyitcwb/Scrips_Infra/master/scripts/t07_s002_status.ps1 -Outfile c:\joy\scripts\zabbix\t07_s002_status.ps1
               wget https://raw.githubusercontent.com/joyitcwb/Scrips_Infra/master/scripts/t00_s003_RotateCpj.ps1 -Outfile c:\joy\scripts\cpj\t00_s003_RotateCpj.ps1
               Write-Host ""

               Write-Host "Inserindo Userparmeter do teplate no zabbix_agentd.conf"
               $fileContents = Get-Content "C:\Program Files\Zabbix Agent\zabbix_agentd.conf"
               $fileContents[2] += "`r`n### Joy IT"
               $fileContents[2] += "`r`nUserParameter=backuplocalw.status,powershell.exe -noprofile -executionpolicy bypass -File c:\joy\scripts\zabbix\t07_s002_status.ps1`r`n"
               $fileContents | Set-Content "C:\Program Files\Zabbix Agent\zabbix_agentd.conf"
               Write-Host ""
               
               Write-Host "Reiniciando o servico do Zabbix Agent"
               Restart-Service -Name "Zabbix Agent"
               Write-Host ""            

               'You chose option #2'
           } '3' {
               
               Write-Host "Baixando scripts" 
               wget https://raw.githubusercontent.com/joyitcwb/Scrips_Infra/master/scripts/t04_s001_discovery.ps1 -Outfile c:\joy\scripts\zabbix\t04_s001_discovery.ps1
               Write-Host ""

               Write-Host "Inserindo Userparmeter do teplate no zabbix_agentd.conf"               
               $fileContents = Get-Content "C:\Program Files\Zabbix Agent\zabbix_agentd.conf"
               $fileContents[2] += "`r`n### Joy IT"
               $fileContents[2] += "`r`nUserParameter=discovery.backup.iperius[*],powershell.exe -noprofile -executionpolicy bypass -File C:\joy\scripts\zabbix\t04_s001_discovery.ps1 `$1 `n"
               $fileContents[2] += "`r`nUserParameter=discovery.backup.iperius.dados[*],powershell.exe -noprofile -executionpolicy bypass -File C:\joy\scripts\zabbix\t04_s001_discovery.ps1 `$1 `$2 `r`n"
               $fileContents | Set-Content "C:\Program Files\Zabbix Agent\zabbix_agentd.conf"
               Write-Host ""

               Write-Host "Reiniciando o servico do Zabbix Agent"
               Restart-Service -Name "Zabbix Agent"
               Write-Host ""

               'You chose option #3'          
           } 's' {
                return
           }
     }
     pause
}
until ($input -eq 's')