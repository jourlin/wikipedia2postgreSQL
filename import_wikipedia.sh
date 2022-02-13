#!/usr/bin/bash
# Required packages :
sudo apt install lbzip2
sudo apt install xml-twig-tools
INPUTURL=https://dumps.wikimedia.org/frwiki/20220201/frwiki-20220201-pages-articles-multistream.xml.bz2
# Download wikimedia dump
wget $INPUTURL
# uncompress
lbunzip2 `basename $INPUTURL`
# split -> one file per page
xml_split `basename $INPUTURL .bz2`
find -name "*multistream-*.xml" -print |nl|tr '\t' ','> page_list.csv
psql -c "DROP TABLE IF EXISTS wiki;"
psql -c "CREATE TABLE wiki(id integer PRIMARY KEY, data xml)"
while IFS=, read -r id file; do 
    printf '%d %s\n' "$id" "$file"; 
    psql -c "INSERT INTO wiki(id, data) VALUES($id, CAST(pg_read_file('${PWD}/$file') AS xml));"&
    pid[1]=${!}
    # For each available thread
    for pn in {2..12}; do
        IFS=, read -r id file
        printf '%d %s\n' "$id" "$file"; 
        psql -c "INSERT INTO wiki(id, data) VALUES($id, CAST(pg_read_file('${PWD}/$file') AS xml));"&
        pid[$pn]=${!}
    done
    for pn in {1..12}; do
        wait ${pid[$pn]}
    done
done <  page_list.csv
