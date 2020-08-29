#!/bin/bash

Principal() {
    clear
    echo
    echo "Escolha uma opcao:"
    echo "------------------"
    echo "1. Zabbix Agent"
    echo "2. Zabbix Proxy"
    echo "3. Backup Local [ t01 ]"
    echo "4. Backup Proxmox [ t02 ]"
    echo "5. Backup Elkarbackup [ t03 ]"
    echo "6. Sair"
    echo
    echo -n "Qual a opção desejada? "
    read opcao
    case $opcao in
        1) ZabbixAgent ;;
        2) ZabbixProxy ;;
        3) BackupLocal ;;
        4) BackupProxmox ;;
        5) BackupElkarbackup ;;
        6) exit ;;
        *) echo "Opção desconhecida." ; echo ; Principal ;;
    esac
}

ZabbixAgent() {
    if [ $OS = "Debian" ]; then
        wget https://repo.zabbix.com/zabbix/4.0/debian/pool/main/z/zabbix-release/zabbix-release_4.0-3+"$OS_VER_NAME"_all.deb
        dpkg -i zabbix-release_4.0-3+"$OS_VER_NAME"_all.deb
        apt-get update
        apt-get install zabbix-agent -y
        sleep 1
        echo -e "\e[32m OK \e[m"
        elif [ $OS = "CentOS" ]; then
        rpm -Uvh https://repo.zabbix.com/zabbix/4.0/rhel/$OS_VER/x86_64/zabbix-release-4.0-2.el$OS_VER.noarch.rpm
        yum clean all
        yum install zabbix-agent -y
        sleep 1
        echo -e "\e[32m OK \e[m"
        else
        echo -e "\e[31m $OS - OS não suportado. | Verifique a forma correta de instalar o XtraBackup. \e[m"
        sleep 3
    fi

    echo
    echo -e "\e[36m Digite o IP ou FQDN do Servido Zabbix ou Proxy: \e[m" ; read SERVER_HOST
    echo
    echo -e "\e[36m Digite o ID JOY do Host: \e[m" ; read HOSTNAME
    echo
    sleep 2
    sed -i "74i EnableRemoteCommands=1" /etc/zabbix/zabbix_agentd.conf
    sed -i "84i LogRemoteCommands=1" /etc/zabbix/zabbix_agentd.conf
    sed -i 's/Server=127.0.0.1/Server=$SERVER_HOST/g' /etc/zabbix/zabbix_agentd.conf
    sed -i 's/ServerActive=127.0.0.1/ServerActive=/g' /etc/zabbix/zabbix_agentd.conf
    sed -i 's/Hostname=Zabbix server/Hostname=$HOSTNAME/g' /etc/zabbix/zabbix_agentd.conf
    echo -e "\e[32m OK \e[m"
    sleep 2
    systemctl restart zabbix-agent
    sleep 1

    Principal

}

ZabbixProxy() {
if [ $OS = "Debian" ]; then
        wget https://repo.zabbix.com/zabbix/4.0/debian/pool/main/z/zabbix-release/zabbix-release_4.0-3+"$OS_VER_NAME"_all.deb
        dpkg -i zabbix-release_4.0-3+"$OS_VER_NAME"_all.deb
        apt-get update
        apt-get install zabbix-proxy-sqlite3 -y
        sleep 1
        echo -e "\e[32m OK \e[m"
        elif [ $OS = "CentOS" ]; then
        rpm -Uvh https://repo.zabbix.com/zabbix/4.0/rhel/$OS_VER/x86_64/zabbix-release-4.0-2.el$OS_VER.noarch.rpm
        yum clean all
        yum install zabbix-proxy-sqlite3 -y
        sleep 1
        echo -e "\e[32m OK \e[m"
        else
        echo -e "\e[31m $OS - OS não suportado. | Verifique a forma correta de instalar o XtraBackup. \e[m"
        sleep 3
    fi

    Principal

}

ZabbixAgentConf(){
    clear
    echo -e "\e[36m Digite o IP ou FQDN do Servido Zabbix ou Proxy: \e[m" ; read SERVER_HOST
    echo
    echo -e "\e[36m Digite o ID JOY do Host: \e[m" ; read HOSTNAME
    echo
    sleep 2 
    sed -i "74i EnableRemoteCommands=1" /etc/zabbix/zabbix_agentd.conf
    sed -i "83i LogRemoteCommands=1" /etc/zabbix/zabbix_agentd.conf
    sed -i 's/Server=127.0.0.1/Server=$SERVER_HOST/g' /etc/zabbix/zabbix_agentd.conf
    sed -i 's/ServerActive=127.0.0.1/ServerActive=/g' /etc/zabbix/zabbix_agentd.conf
    sed -i 's/Hostname=Zabbix server/Hostname=$HOSTNAME/g' /etc/zabbix/zabbix_agentd.conf
    echo -e "\e[32m OK \e[m"
}


BackupProxmox() {
    Template_t02
    Principal
}

BackupLocal() {
    clear
    echo "Escolha uma opção (Template Zabbix 01)"
    echo "--------------------------------------"
    echo "1. Mysql"
    echo "2. Hestia"
    echo "3. Otrs"
    echo "4. Zimbra"
    echo "5. Postgresql"
    echo "6. Continuar"
    echo
    echo -n "Qual a opção desejada? "
    read opcao
    case $opcao in
        1) Mysql ;;
        2) Hestia ;;
        3) Otrs ;;
        4) Zimbra ;; 
        5) Postgresql ;;
        6) Template_t01 ;;
        *) echo "Opção desconhecida." ; echo ; BackupLocal ;;
    esac    
} 

Dir() {
      
    echo "Criando -p $DIR_BKP e $DIR_SCP"
    sleep 1
    if [ -d "$DIR_BKP" ] && [ -d "$DIR_SCP" ]; then
    echo " Diretorios ja existem, skip."
    sleep 2
    else
    mkdir $DIR_BKP
    mkdir $DIR_SCP
    echo "Diretorios criados."
    sleep 2
    fi
}

Mysql() {
    clear
    DIR_SCP=/joy/scripts/mysql       
    DIR_BKP=/joy/backup/mysql
    Dir
    echo
    echo -e "\e[36m Digite o usuario do MySQL: \e[m" ; read USER
    echo
    echo -e "\e[36m Digite a senha para usuario do MySQL: $USER \e[m" ; read SECRET
    echo
    MYSQL=`mysql --version`
    
    echo "Digite [ 1 ]: Para versao Mysql < ou = 5.7 ou Mariadb < ou = 10.2"
    echo "Digite [ 2 ]: Para versao = ou > Mysql 8"
    echo "Digite [ 3 ]: Para versao = ou > Mariadb 10.3 ou >"
    echo -e "\e[36m A versao do MySQL e: $MYSQL \e[m" ; read MY_OPTION
    if [ $MY_OPTION = "1" ] ; then
        SCRIPT=t00_s001_Xtrabackup.sh
        echo
        echo -e "\e[36m Instalando XtraBackup... \e[m" 
        sleep 2
            if [ $OS = "Debian" ]; then
            apt-get install curl
            wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
            dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
            apt-get update
            apt-get install percona-xtrabackup-24 -y
            echo -e "\e[32m OK \e[m"
            elif [ $OS = "CentOS" ]; then
            yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm -y
            yum install  percona-xtrabackup-24 -y
            echo -e "\e[32m OK \e[m"
            else
            echo -e "\e[31m $OS - OS não suportado. | Verifique a forma correta de instalar o XtraBackup. \e[m"
            sleep 3
            fi
        Deploy_Script_Mysql 
    
    elif [ $MY_OPTION = "2" ] ; then
        SCRIPT=t00_s001_Xtrabackup.sh
        echo
        echo -e "\e[36m Instalando XtraBackup... \e[m" 
        sleep 2
        if [ $OS = "Debian" ]; then
        wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
        dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
        apt-get update
        percona-release setup ps80
        apt-get install percona-xtrabackup-80 -y
        echo -e "\e[32m OK \e[m"
        elif [ $OS = "CentOS" ]; then
        yum install perl-DBD-MySQL -y
        yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm -y
        yum install  percona-xtrabackup-80 -y
        echo -e "\e[32m OK \e[m"
        else
        echo -e "\e[31m $OS - OS não suportado. | Verifique a forma correta de instalar o XtraBackup. \e[m"
        sleep 3
        fi
        Deploy_Script_Mysql        
        
    elif [ $MY_OPTION = "3" ] ; then
        SCRIPT=t00_s002_Mariabackup.sh
        echo
        echo -e "\e[36m Instalando MariaBackup... \e[m"
        echo
        sleep 2
        if [ $OS = "Debian" ]; then
        apt-get install mariadb-backup -y
        echo -e "\e[32m OK \e[m"
        elif [ $OS = "CentOS" ]; then
        yum install  MariaDB-backup -y
        echo -e "\e[32m OK \e[m"
        else
        echo -e "\e[31m $OS - OS não suportado. | Verifique a forma correta de instalar o MariaBackup. \e[m"
        sleep 3
        fi
        Deploy_Script_Mysql

    else
    echo -e "\e[31m $OS - Opcao invalida. | Digite uma das opcoes validas. \e[m" 
    sleep 3
    Mysql
    fi
    BackupLocal

}

Deploy_Script_Mysql() {
      echo -e "\e[36m Baixando e configurando o script... \e[m"
      wget -O $DIR_SCP/$SCRIPT https://raw.githubusercontent.com/joyitcwb/Scrips_Infra/master/scripts/$SCRIPT
      chmod +x $DIR_SCP/$SCRIPT
      sed -i "94i USER=$USER" $DIR_SCP/$SCRIPT
      sed -i "94i SECRET=$SECRET"  $DIR_SCP/$SCRIPT
      echo -e "\e[32m OK \e[m"
      echo
      echo -e "\e[36m Digite a Hora do backup do MySQL: \e[m" ; read HORA
      echo
      echo -e "\e[36m Digite o Minuto do backup do MySQL: \e[m" ; read MIN
      echo
      echo -e "\e[36m Adicionando tarefa no cron... \e[m" 
      cronjob=" $MIN $HORA * * * $DIR_SCP/$SCRIPT full #Script Backup XtraBackup | Seg-Dom as $HORA:$MIN"
      (crontab -u root -l; echo "$cronjob" ) | crontab -u root -
      echo -e "\e[32m OK \e[m"
      sleep 3

}

Hestia() {
    clear       
    DIR=/joy/backup/hestia
    Dir
}
Otrs() {
    clear       
    DIR=/joy/backup/otrs
    Dir
}

Zimbra() {
    clear       
    DIR=/joy/backup/zimbra
    Dir
}

Postgresql() {
    clear       
    DIR=/joy/backup/postgresql
    Dir
}


Template_t01() {
    clear
    echo -e "\e[36m Fazendo o download dos scripts do template t01... \e[m" 
    echo
    sleep 2
    wget -c -P /joy/scripts/zabbix https://raw.githubusercontent.com/joyitcwb/Scrips_Infra/master/scripts/t01_s001_discovery.sh
    wget -c -P /joy/scripts/zabbix https://raw.githubusercontent.com/joyitcwb/Scrips_Infra/master/scripts/t01_s002_status.sh
    chmod +x /joy/scripts/zabbix/t01_s001_discovery.sh
    chmod +x /joy/scripts/zabbix/t01_s002_status.sh
    echo -e "\e[32m OK \e[m"
    
    echo
    echo -e "\e[36m Atualizando zabbix_agent.conf... \e[m" 
    echo
    sleep 2 
    sed -i "4i UserParameter=backup.discovery,/joy/scripts/zabbix/t01_s001_discovery.sh" /etc/zabbix/zabbix_agentd.conf
    sed -i "4i UserParameter=backup.status[*],/joy/scripts/zabbix/t01_s002_status.sh "'$'1"" /etc/zabbix/zabbix_agentd.conf
    sed -i "4i ### Joy IT" /etc/zabbix/zabbix_agentd.conf
    echo -e "\e[32m OK \e[m"

    echo
    echo -e "\e[36m Reiniciando Zabbix Agent... \e[m"
    echo
    sleep 2
    # systemctl restart zabbix-agent
    sleep 1
    echo -e "\e[32m OK \e[m"
}

Template_t02() {
    clear
    echo -e "\e[36m Fazendo o download dos scripts do template t02... \e[m" 
    echo
    sleep 2
    wget -c -P /joy/scripts/zabbix https://raw.githubusercontent.com/joyitcwb/Scrips_Infra/master/scripts/t02_s001_discovery.sh
    wget -c -P /joy/scripts/zabbix https://raw.githubusercontent.com/joyitcwb/Scrips_Infra/master/scripts/t02_s002_status.sh
    chmod +x /joy/scripts/zabbix/t02_s001_discovery.sh
    chmod +x /joy/scripts/zabbix/t02_s002_status.sh
    echo -e "\e[32m OK \e[m"
    
    echo
    echo -e "\e[36m Atualizando zabbix_agent.conf... \e[m" 
    echo
    sleep 2 
    sed -i "4i UserParameter=backup.discovery,/joy/scripts/zabbix/t02_s001_discovery.sh" /etc/zabbix/zabbix_agentd.conf
    sed -i "4i UserParameter=backup.status[*],/joy/scripts/zabbix/t02_s002_status.sh "'$'1"" /etc/zabbix/zabbix_agentd.conf
    sed -i "4i ### Joy IT" /etc/zabbix/zabbix_agentd.conf
    echo -e "\e[32m OK \e[m"

    echo
    echo -e "\e[36m Reiniciando Zabbix Agent... \e[m"
    echo
    sleep 2
    # systemctl restart zabbix-agent
    sleep 1
    echo -e "\e[32m OK \e[m"
}

###

OS=`hostnamectl | grep Operating | cut -d: -f2 | cut -d' ' -f2`
OS_VER=`hostnamectl | grep Operating | cut -d: -f2 | cut -d' ' -f4`

echo
echo -e "\e[36m Instalando jq \e[m" 
sleep 2
if [ $OS = "Debian" ]; then
OS_VER_NAME=`hostnamectl | grep Operating | cut -d: -f2 | cut -d' ' -f5 | sed -e 's/[()]//g'`
apt-get install jq -y
echo -e "\e[32m OK \e[m"
elif [ $OS = "CentOS" ]; then
yum install jq -y
echo -e "\e[32m OK \e[m"
else
echo -e "\e[31m $OS - OS não suportado. | Verifique a forma correta de instalar o jq. \e[m"
sleep 3
fi

echo
echo -e "\e[36m Criando /joy/backup \e[m" 
sleep 2
mkdir -p /joy/backup
echo -e "\e[32m OK \e[m"

echo
echo -e "\e[36m Criando /joy/scripts \e[m"
sleep 2
mkdir -p /joy/scripts
echo -e "\e[32m OK \e[m"

echo
echo -e "\e[36m Criando /joy/storage \e[m"
sleep 2
mkdir -p /joy/storage
echo -e "\e[32m OK \e[m"
sleep 2

Principal

echo
echo -e "\e[36m Copiando o script global.sh /joy/scripts/global \e[m"
sleep 2
SCRIPT=`pwd`
mkdir -p /joy/scripts/global
cp $SCRIPT/global.sh /joy/scripts/global
echo -e "\e[32m OK \e[m"
sleep 2
