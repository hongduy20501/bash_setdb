set -ex

data_path=/u01/share/mysql
export a=$(ip route show default | grep -Eo 'dev [a-z0-9]+' | awk '{print $2}')
my_ip=$(ip address show $a | grep inet | head -n 1 | grep -Eo 'inet ([0-9.]+)' | awk '{print $2}')

echo "IP hiện tại: ${my_ip}"

if [ -z "$(which mysql)" ]; then
  sudo apt-get -qq update
  sudo apt-get -qq install -y mysql-server mysql-client
fi

if [ $(service mysql status | grep -c running) != 1 ]; then
  echo "error"
  exit 1
fi

if [ $(systemctl is-enabled apparmor.service) == enabled ] || [ $(systemctl is-active apparmor.service) ==active ]; then
          # system is-enable/is-active
          sudo systemctl disable apparmor --now
          echo "Reboot máy !!!"
          exit 1
fi

export datadir=$(sed -E 's/#? (datadir)\s+= (.+)/\1 \2/' /etc/mysql/mysql.conf.d/mysqld.cnf | grep datadir | awk '{print $2}')
echo ${datadir}

if [ ${datadir} != ${data_path} ]; then
	sudo service mysql stop

	sudo mkdir -p $(dirname ${data_path})
	sudo mv /var/lib/mysql /u01/share
	sudo chown mysql:mysql -R /u01/share/mysql #(-R == tất cả thư mục con)
	sudo sed -i -E 's/#? (datadir)\t= (.+)/\1 = \/u01\/share\/mysql/' /etc/mysql/mysql.conf.d/mysqld.cnf
	sudo sed -i -E 's/(^bind-address)\s+= (.+)/\1 = ${my_ip}/' /etc/mysql/mysql.conf.d/mysqld.cnf
	sudo sed -i -E 's/#? (server-id)\s+= (.+)/\1 = 1/' /etc/mysql/mysql.conf.d/mysqld.cnf

	sudo service mysql start
fi

# neu mysql chua run
while [ $(service mysql status | grep -c runing) != 1 ]; do true; done

mysql -u root -p root -e 'SELECT 1';

#if [$(which ser)]
#pass=hongduy

#if [ $(có thể login bằng empty password)]; then
  #đổi password
#fi

#if [ $(nếu không login bằng password)]; then
 # echo "Lỗi hệ thống"
  #exit 1
#fi

#if [ check tài khoản slave chưa tồn tại ]; then
 # tạo tài khoản
#fi

if ! echo 'SELECT 1' | MYSQL_PWD="hongduy" mysql -h mysql &>/dev/null; then
  if echo 'SELECT 1' | mysql -h mysql &>/dev/null; then
    echo "ALTER USER root@'%' IDENTIFIED BY 'hongduy'; FLUSH PRIVILEGES;" | mysql -h mysql
  else
    exit 1
  fi
fi

if ! echo 'SELECT 1' | MYSQL_PWD="slave@e123" mysql -h mysql -u slave &>/dev/null; then
  echo "CREATE USER IF NOT EXISTS slave@'%'; ALTER USER slave@'%' IDENTIFIED BY 'slave@e123'; FLUSH PRIVILEGES;" | MYSQL_PWD="hongduy" mysql -h mysql
fi

echo 'CREATE DATABASE IF NOT EXISTS doopage; GRANT ALL PRIVILEGES ON doopage.* TO slave@"%";' | MYSQL_PWD="hongduy" mysql -h mysql
echo 'CREATE DATABASE IF NOT EXISTS opensips; GRANT ALL PRIVILEGES ON opensips.* TO slave@"%";' | MYSQL_PWD="hongduy" mysql -h mysql
echo 'FLUSH PRIVILEGES;' | MYSQL_PWD="hongduy" mysql -h mysql

#sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'hongduy'";
#mysql -uroot -p$pass -e "CREATE USER 'root'@'%' IDENTIFIED BY 'hongduy'"
#mysql -uroot -p$pass -e "ALTER USER 'root'@'%' INDENTIFIED WITH mysql_native_password BY 'hongduy'";
#mysql -uroot -p$pass -e "GRANT ALL ON *.* TO root@'%'; FLUSH PRIVILEGES;";
#mysql -uroot -p$pass -e "GRANT GRANT OPTION ON *.* TO 'root'@'%';"
#mysql -uroot -p$pass -e "DROP USER 'root'@'localhost'";
#mysql -uroot -p$pass -e "CREATE USER 'slave'@'10.238.153.254' IDENTIFIED BY 'slaveduy'";
#mysql -uroot -p$pass -e "GRANT REPLICATION SLAVE ON *.* TO 'slave'@'10.238.153.254'; FLUSH PRIVILEDES;";
#mysql -uroot -p$pass -e "ALTER USER 'slave'@'10.238.153.254' IDENTIFIED WITH mysql_native_password BY 'slaveduy'";
echo "ok"

