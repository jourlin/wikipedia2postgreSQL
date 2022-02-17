#!/usr/bin/bash
psql -c "DROP TABLE IF EXISTS wiki;"
psql -c "CREATE TABLE wiki(id integer PRIMARY KEY, data xml);"
while IFS=, read -r id file; do
	printf "%d %s\n" "${id}" "${file}";
	psql -c "INSERT INTO wiki(id, data) VALUES(${id}, CAST(pg_read_file('${PWD}/${file}') AS xml));" &
	pid[1]=${!}
	# For each available thread
	for pn in {2..12}; do
		IFS=, read -r id file
		printf '%d %s\n' "$id" "$file";
		psql -c "INSERT INTO wiki(id, data) VALUES(${id}, CAST(pg_read_file('${PWD}/${file}') AS xml));"&
		pid[$pn]=${!}
	done
	for pn in {1..12}; do
		wait ${pid[$pn]}
	done
done <./page_list.csv
	`

