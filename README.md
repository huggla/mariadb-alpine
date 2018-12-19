# mariadb-alpine
A small and secure Docker image of Mariadb (currently 10.3.10). Will execute .sh and .sql files located in /initdb when a new datastore is created.

20181204: Mariadb 10.3.10, Alpine Edge

## Environment variables
### pre-set runtime variables
* VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig"
* VAR_ARGON2_PARAMS="-r" (only used if VAR_ENCRYPT_PW is set to "yes")
* VAR_SALT_FILE="/proc/sys/kernel/hostname" (only used if VAR_ENCRYPT_PW is set to "yes")
* VAR_LINUX_USER="mysql" (also owner/superuser for databases in VAR_DATABASES)
* VAR_param_datadir="/mariadbdata"
* VAR_param_socket="/run/mysqld/mysqld.sock"
* VAR_param_character_set_server="utf8"
* VAR_param_collation_server="utf8_general_ci"
* VAR_param_port="3306"

### Optional runtime variables
* VAR_param_&lt;mariadb parameter name, dashes replaced by underscores&gt;
* VAR_password_file_&lt;VAR_LINUX_USER&gt;
* VAR_password_&lt;VAR_LINUX_USER&gt;
* VAR_ENCRYPT_PW (set to "yes" to hash password with Argon2)
* VAR_DATABASES (comma separated list of databases to create when a new datastore is created)

## Capabilities
Can drop all but SETPCAP, SETGID and SETUID.

## Tips
Check also out huggla/mariadb-backup.
