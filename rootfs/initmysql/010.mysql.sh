#!/bin/sh

# Set in parent scripts:
# ---------------------------------------------------------
# set -e +a +m +s +i +f
# VAR_*
# All functions in /start/functions
# ---------------------------------------------------------

initMysql(){
   local prio="010"
   local dbname="mysql"
   local sqlFile="/initmysql/$prio.$dbname.sql"
   /bin/touch "$sqlFile"
   /bin/chmod go= "$sqlFile"
   local rootPw="$(makePwForUser root)"
   local userPw="$(makePwForUser $VAR_LINUX_USER)"
   /bin/cat << EOF > "$sqlFile"
USE $dbname;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' identified by '$rootPw' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' identified by '$rootPw' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("") WHERE user='root' AND host='localhost';
EOF
   local IFS=$(echo -en "\n\b,")
   local db=""
   for db in $VAR_DATABASES
   do
      db="$(trim "$db")"
      echo "CREATE DATABASE IF NOT EXISTS \`$db\` CHARACTER SET $VAR_param_character_set_server COLLATE $VAR_param_collation_server;" >> "$sqlFile"
      echo "GRANT ALL ON \`$db\`.* to '$VAR_LINUX_USER'@'%' IDENTIFIED BY '$userPw';" >> "$sqlFile"
      echo "GRANT ALL ON \`$db\`.* to '$VAR_LINUX_USER'@'localhost' IDENTIFIED BY '$userPw';" >> "$sqlFile"
   done
   printInitPassword root "$rootPw"
}

initMysql
