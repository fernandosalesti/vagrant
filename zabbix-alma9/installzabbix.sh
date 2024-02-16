#! /bin/bash

# Instalar Zabbix-server 
# 0.1


 # variáveis
 
 SENHAMY="SENHAMYSQL"  # senha root do mysql
 ZABBIXUSER="zabbixuser" # usuario zabbix
 ZABBIXUSERPWD="zabbixsenha" # senha do usuário zabbix
 ZABBIXDB="zabbixdb" # banco de dados do zabbix
 ZABBIXPORT="10051" # porta do zabbix server

 TIMEZONEVR="America/Sao_Paulo"  # Timezone
 
 # Escolha uma das opções a seguir
 
 LOCALEVR="pt_BR.UTF-8"  # Idioma Português
 #LOCALEVR="en_US.UTF-8"  # Idioma English


 # desativar SELINUX
 # sudo setenforce 0

 # Instalar e configurar pacotes de idiomas

 sudo dnf install -y glibc-langpack-en glibc-langpack-pt
 
 sudo localectl set-locale LANG=$LOCALEVR
 sudo timedatectl set-timezone $TIMEZONEVR
 

 # Verificar se existe repo EPEL se existir desabilitar
 
 EPEL=$(sudo dnf repolist --all |grep epel |grep enabled|wc -l)
 EPELACT=0


  if [ $EPEL -ne 0 ]; then
     sudo dnf config-manager --disable epel
     EPELACT=1
  fi



# Instalar e Configurar firewalld

 sudo dnf install -y firewalld
 sudo systemctl enable --now firewalld
 sudo firewall-cmd --permanent --add-port=22/tcp
 sudo firewall-cmd --permanent --add-port=80/tcp
 sudo firewall-cmd --permanent --add-port=443/tcp
 sudo firewall-cmd --permanent --add-port=10050/tcp
 sudo firewall-cmd --permanent --add-port=$ZABBIXPORT/tcp
 sudo firewall-cmd --reload


 
 # Instalar mysql e criar senha para mysql

 sudo dnf install -y mysql mysql-server 

 sudo systemctl enable --now mysqld && echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$SENHAMY'; FLUSH PRIVILEGES;" | mysql -uroot  

 sudo systemctl restart mysqld



 


# Baixar repo e instalar componentes do zabbix

 sudo rpm -Uvh https://repo.zabbix.com/zabbix/6.0/rhel/9/x86_64/zabbix-release-6.0-4.el9.noarch.rpm
 sudo dnf clean all

 sudo dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent

 
# Criar Usuário e banco de dados do zabbix e importar configuraçoes 

echo "CREATE DATABASE $ZABBIXDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin; CREATE USER '$ZABBIXUSER'@'localhost' IDENTIFIED BY '$ZABBIXUSERPWD'; GRANT ALL PRIVILEGES ON $ZABBIXDB.* TO $ZABBIXUSER@localhost; FLUSH PRIVILEGES; SET GLOBAL log_bin_trust_function_creators = 1;" | mysql -uroot -p$SENHAMY

# echo "CREATE DATABASE $ZABBIXDB CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;" | mysql -uroot -p$SENHAMY
# echo "CREATE USER '$ZABBIXUSER'@'localhost' IDENTIFIED BY '$ZABBIXUSERPWD';" | mysql -uroot -p$SENHAMY
# echo "GRANT ALL PRIVILEGES ON $ZABBIXDB.* TO $ZABBIXUSER@localhost; FLUSH PRIVILEGES;" | mysql -uroot -p$SENHAMY
# echo "SET GLOBAL log_bin_trust_function_creators = 1;" | mysql -uroot -p$SENHAMY


zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u$ZABBIXUSER -p$ZABBIXUSERPWD $ZABBIXDB

echo "SET GLOBAL log_bin_trust_function_creators = 0;" | mysql -uroot -p$SENHAMY


# Confirar DB, usuario e senha do zabbix server

sudo sed -i "s/^# ListenPort=10051/ListenPort=$ZABBIXPORT/g" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/^DBName=zabbix/DBName=$ZABBIXDB/g" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/^DBUser=zabbix/DBUser=$ZABBIXUSER/g" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/^# DBPassword=/DBPassword=$ZABBIXUSERPWD/g" /etc/zabbix/zabbix_server.conf



# Confirar porta de conexão ao zabbix server no agent zabbix (active agent)

sudo sed -i "s/^ServerActive=127.0.0.1/ServerActive=127.0.0.1:$ZABBIXPORT/g" /etc/zabbix/zabbix_agentd.conf

# Reiniciar zabbix e dependencias 

sudo systemctl restart zabbix-server zabbix-agent httpd php-fpm
sudo systemctl enable zabbix-server zabbix-agent httpd php-fpm


# Reativar EPEL caso necessário

if [ $EPELACT -eq 1 ]; then
sudo dnf config-manager --enable epel
fi


# Ativar https 

sudo dnf install -y mod_ssl openssl


# Copiar chave, certificado e arquivo de configuração do zabbix para https 

sudo cp /vagrant/tls/zabbix-tls.conf /etc/httpd/conf.d/
sudo cp /vagrant/tls/zabbix.crt /etc/ssl/
sudo cp /vagrant/tls/zabbix.key /etc/ssl/



# Caso os comandos acima não funcionem
# Gere a chave e certificados com o comandos abaixo:

# sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/zabbix.key -out /etc/ssl/zabbix.crt

# Copie o arquivo manualmente para /vagrant/tls/zabbix-tls.conf para /etc/httpd/conf.d/

# Reinicie o apache

sudo systemctl restart httpd