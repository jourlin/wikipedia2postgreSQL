#/usr/bin/bash
for username in $@
	do 
	 	psql -c "CREATE ROLE $username WITH LOGIN PASSWORD '2001:lOdle';"
	 	psql -c "CREATE DATABASE $username OWNER $username TEMPLATE=template0 ENCODING='UTF8' LC_COLLATE='fr_FR.UTF-8' LC_CTYPE='fr_FR.UTF-8';"
	done
