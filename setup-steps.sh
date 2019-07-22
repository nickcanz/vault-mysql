set -exu 


# Mount the database secrets engine
curl -H  "X-Vault-Token:vault" -XPOST localhost:8200/v1/sys/mounts/database -d '{"type":"database"}'

# Get the IP addresses of the two mysql servers
MYSQL_BLUE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql-server-blue)
MYSQL_GREEN_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql-server-green)

# Set up the connection to mysql-blue
curl -XPOST -H  "X-Vault-Token:vault" localhost:8200/v1/database/config/mysql-blue -d"{
  \"plugin_name\": \"mysql-database-plugin\",
  \"allowed_roles\": \"mysql-blue_readonly\",
  \"connection_url\": \"{{username}}:{{password}}@tcp($MYSQL_BLUE_IP:3306)/\",
  \"username\": \"root\",
  \"password\": \"mysql-blue\"
}"

# Make a readonly role for mysql-blue
curl -XPOST -H  "X-Vault-Token:vault" localhost:8200/v1/database/roles/mysql-blue_readonly -d $'{
    "db_name": "mysql-blue",
    "creation_statements": [
      "CREATE USER \'{{name}}\'@\'%\' IDENTIFIED BY \'{{password}}\'", 
      "GRANT SELECT ON *.* TO \'{{name}}\'@\'%\'"
    ],
    "default_ttl": "1h",
    "max_ttl": "24h"
}'


# Set up the connection to mysql-green
curl -XPOST -H  "X-Vault-Token:vault" localhost:8200/v1/database/config/mysql-green -d"{
  \"plugin_name\": \"mysql-database-plugin\",
  \"allowed_roles\": \"mysql-green_readonly\",
  \"connection_url\": \"{{username}}:{{password}}@tcp($MYSQL_GREEN_IP:3306)/\",
  \"username\": \"root\",
  \"password\": \"mysql-green\"
}"

# Make a readonly rule for mysql-green
curl -XPOST -H  "X-Vault-Token:vault" localhost:8200/v1/database/roles/mysql-green_readonly -d $'{
    "db_name": "mysql-green",
    "creation_statements": [
      "CREATE USER \'{{name}}\'@\'%\' IDENTIFIED BY \'{{password}}\'", 
      "GRANT SELECT ON *.* TO \'{{name}}\'@\'%\'"
    ],
    "default_ttl": "1h",
    "max_ttl": "24h"
}'

# Display all the roles
curl -XLIST -H  "X-Vault-Token:vault" localhost:8200/v1/database/roles

# Get a username/password for mysql-blue
curl -XGET -H "X-Vault-Token:vault" localhost:8200/v1/database/creds/mysql-blue_readonly

# Get a username/password for mysql-green
curl -XGET -H "X-Vault-Token:vault" localhost:8200/v1/database/creds/mysql-green_readonly

# Revoke a lease
# lease_ids come from the above creds API call
# curl -XPUT -H "X-Vault-Token:vault" localhost:8200/v1/sys/leases/revoke -d'{ "lease_id": "a1b2c3"}'
