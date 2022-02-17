#!/usr/bin/bash
INPUTURL=https://dumps.wikimedia.org/frwiki/20220201/frwiki-20220201-pages-articles-multistream.xml.bz2
COMPRESSED_FILE=`basename ${INPUTURL}`
XMLFILE=`basename ${INPUTURL} .bz2`
# Required packages :
download:
	sudo apt install lbzip2
	sudo apt install xml-twig-tools
	# Download wikimedia dump
	wget ${INPUTURL}
uncompress:
	# uncompress
	lbunzip2 ${COMPRESSED_FILE}
split:
	xml_split ${XMLFILE} 
	find -name "*multistream-*.xml" -print |nl|tr '\t' ','> ./page_list.csv
import:
	bash import.sh
