set -ex

if [ -z "$(which mysql)"]; then
  sudo apt-get -qq update
  sudo apt-get -qq install -y mysql-server mysql-client
fi

if [$(service mysql status | grep -c running) != 1]; then
  echo "error"
  exit 1
fi

if [$(sudo service apparmor status | grep -c exited) == 2]; then
  sudo systemclt disable apparmor
fi

sudo mkdir -p /u01/share
sudo mv /var/lib/mysql /u01/share
sudo chown mysql:mysql /u01/share
sudo sed -i -E 's/#? (datadir)\t= (.+)/\1 = \/u01\/share\/mysql/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i -E 's/(bind-address)\s+= (.+)/\1 = 10.238.153.6/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i -E 's/#? (server-id)\s+= (.+)/\1 = 1/' /etc/mysql/mysql.conf.d/mysqld.cnf

sudo service mysql restart

if [$(which ser)]
pass=hongduy

sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'hongduy'";
mysql -uroot -p$pass -e "CREATE USER 'root'@'%' IDENTIFIED BY 'hongduy'"
mysql -uroot -p$pass -e "ALTER USER 'root'@'%' INDENTIFIED WITH mysql_native_password BY 'hongduy'";
mysql -uroot -p$pass -e "GRANT ALL ON *.* TO root@'%'; FLUSH PRIVILEGES;";
mysql -uroot -p$pass -e "GRANT GRANT OPTION ON *.* TO 'root'@'%';"
mysql -uroot -p$pass -e "DROP USER 'root'@'localhost'";
mysql -uroot -p$pass -e "CREATE USER 'slave'@'10.238.153.254' IDENTIFIED BY 'slaveduy'";
mysql -uroot -p$pass -e "GRANT REPLICATION SLAVE ON *.* TO 'slave'@'10.238.153.254'; FLUSH PRIVILEDES;";
mysql -uroot -p$pass -e "ALTER USER 'slave'@'10.238.153.254' IDENTIFIED WITH mysql_native_password BY 'slaveduy'";
echo "ok"

