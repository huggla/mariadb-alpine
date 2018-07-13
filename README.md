**Note! I use Docker latest tag for development, which means that it isn't allways working. Date tags are stable.**

# mariadb-alpine
A small and secure Docker image of Mariadb (currently 10.3.8).

## Environment variables
### pre-set runtime variables
* VAR_FINAL_COMMAND="/usr/local/bin/mysqld \$extraConfig"
* VAR_ARGON2_PARAMS="-r" (only used if VAR_ENCRYPT_PW is set to "yes")
* VAR_SALT_FILE="/proc/sys/kernel/hostname" (only used if VAR_ENCRYPT_PW is set to "yes")
* VAR_LINUX_USER="mysql" (also database owner/superuser)
* VAR_param_datadir="/mariadbdata"
* VAR_param_socket="/run/mysqld/mysqld.sock"

### Optional runtime variables
* VAR_param_&lt;mariadb parameter name, dashes replaced by underscores&gt;_&lt;
* VAR_password_file_&lt;VAR_LINUX_USER&gt;
* VAR_password_&lt;VAR_LINUX_USER&gt;
* VAR_ENCRYPT_PW (set to "yes" to hash password with Argon2)

## Capabilities
Can drop all but CHOWN, DAC_OVERRIDE, FOWNER, SETGID and SETUID.

## Tips
Check also out huggla/mariadb-backup.
