#!/bin/bash

# Script for checking ProxMox virtual machines backup. For use in Zabbix. Skygge@2016
# Modified: MR_Andrew, 2018.
# Special thanks: Max Dark, Marinero from cyberforum.ru
# Modified: JOY IT, 2021.

#Variables

backupconfig='/etc/pve/vzdump.cron'
storageconfig='/etc/pve/storage.cfg'
configdir='/etc/pve/local/qemu-server'

# Check every VM for existing backup files and check if they're newer than 7 days
# Verifique em cada VM os arquivos de backup existentes e verifique se eles são mais novos que 7 dias
parameters=$(cat $backupconfig | egrep "($1|\-\-all)" | head -1 | sed 's/  */ /g')

if [ "$parameters" = "" ]; then
        # echo "Invalid VM number, or backup for VM $1 is not configured."
        # echo "Número de VM inválido ou backup para VM $1 não está configurado."
        echo 0
else
        # read backup configuration file into an array and find the backup storage parameter
        # ler o arquivo de configuração de backup em uma matriz e encontrar o parâmetro de armazenamento de backup
        IFS=' ' read -r -a array <<<"$parameters"
        for index in "${!array[@]}"; do
                if [ "${array[index]}" = "--storage" ]; then
                        z=$((index + 1))
                        backupstorage=${array[$z]}
                fi
        done

        # read physical backup path from storage configuration file for VM $1
        # ler o caminho de backup físico do arquivo de configuração de armazenamento para VM $1
        backupdirectory=$(cat $storageconfig | grep -w -A 1 $backupstorage | grep path | rev | cut -d " " -f 1 | rev)

    TIMEOUT=$(timeout 2s ls $backupdirectory)
    if [ "$TIMEOUT" = "" ]; then
       # echo "O local de backup da VM $1 esta inacessivel."
       echo 5
    else

        if [ -d $backupdirectory/dump ]; then
                # check if backup file(s) exists on backup path for VM $1
                # verifique se o(s) arquivo(s) de backup existe(m) no caminho de backup para VM $1
                backup=$(ls $backupdirectory/dump/ | grep "$1" | grep -v -E "log|tmp|dat" | wc -l)
                if [ "$backup" = "0" ]; then
                        # echo "VM $1 has no backup file."
                        # echo "VM $1 não tem arquivo de backup."
                        echo 2
                else
                        # check if backup file is newer than $2 day(s) for VM $1
                        # verifica se o arquivo de backup é mais recente que $2 dia(s) para VM $1
                        newbackup=$(find $backupdirectory/dump/ -type f -name "*$1*" -not -name "*.log" -not -name "*.tmp" -not -name "*.dat" -mtime -$2 | sort -nr | head -1 | wc -l)
                        if [ "$newbackup" = "0" ]; then
                                # echo "VM $1 backup is older than $2 day(s)."
                                # echo "O backup da VM $1 é mais antigo do que $2 dia(s)."
                                echo 3
                        else
                                # check last log file for errors
                                # verifica o último arquivo de log em busca de erros
                                backuplastlog=$(ls $backupdirectory/dump/ | grep "$1" | grep log | tail -1)
                                backupresult=$(cat $backupdirectory/dump/$backuplastlog | grep -i -E "ERROR|FAILED")
                                if [ "$backupresult" = "" ]; then
                                        # echo "VM $1 backup is OK, no errors found."
                                        # echo "O backup da VM $1 está OK, nenhum erro encontrado."
                                        echo 7
                                else
                                        # echo "VM $1 backup finished with errors. Please, check logs."
                                        # echo "O Backup da VM $1 foi concluído com erros. Por favor, verifique os logs."
                                        echo 4
                                fi
                        fi
                fi
        else
                # echo "Backup directory for VM $1 does not exists."
                # echo "O diretório de backup para VM $1 não existe."
                echo 1
        fi
    fi
fi
