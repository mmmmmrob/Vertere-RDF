#!/bin/bash

TEMPLATE_FOLDER="templates/"
VERTERE_FOLDER="../../"

cat /dev/null > output_data/full.rdf.nt

echo Starting with turtle files in hand-written rdf
for file in $(ls handwritten/*.ttl)
do
	rapper -i turtle -o ntriples "$file" >> output_data/full.rdf.nt
done

echo Validating spec files
for file in $(ls templates/*.spec.ttl)
do
	rapper -i turtle -c "$file"
done

echo paninigroup.com sources
cat euro2012/euro2012_paninigroup.tsv | $VERTERE_FOLDER/vertere_mapper.php $TEMPLATE_FOLDER/euro2012_paninigroup.tsv.spec.ttl >> output_data/full.rdf.nt

echo stickermanager.com sources
cat euro2012/euro2012_stickermanager.tsv | $VERTERE_FOLDER/vertere_mapper.php $TEMPLATE_FOLDER/euro2012_stickermanager.tsv.spec.ttl >> output_data/full.rdf.nt

echo constructing and linking player resources
arq --data output_data/full.rdf.nt --query queries/construct_player_resources.rq --results n-triples >> output_data/full.rdf.nt

echo linking team resources
arq --data output_data/full.rdf.nt --query queries/construct_team_links.rq --results n-triples >> output_data/full.rdf.nt


echo Sorting and de-duping descriptions
sort -u output_data/full.rdf.nt > output_data/panini_euro2012.rdf.nt

rm output_data/full.rdf.nt

echo Listing properties used
cat output_data/panini_euro2012.rdf.nt | awk '{ print $2 }' | sort -u > output_data/panini_euro2012.properties_used.txt

echo Listing classes used
cat output_data/panini_euro2012.rdf.nt | awk '{ print $2 " " $3 }' | grep "^<http://www.w3.org/1999/02/22-rdf-syntax-ns#type> " | awk '{ print $2 }' | sort -u > output_data/panini_euro2012.classes_used.txt

echo Converting descriptions to turtle
rapper -i ntriples -o turtle output_data/panini_euro2012.rdf.nt \
	-f 'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"' \
	-f 'xmlns:owl="http://www.w3.org/2002/07/owl#"' \
	-f 'xmlns:xsd="http://www.w3.org/2001/XMLSchema#"' \
	-f 'xmlns:foaf="http://xmlns.com/foaf/0.1/"' \
	-f 'xmlns:panini="http://data.kasabi.com/dataset/panini-stickers/schema/"' \
	> output_data/panini_euro2012.rdf.ttl

echo Preparing for upload
rm upload/*
split -l 9000 output_data/panini_euro2012.rdf.nt panini_euro2012.
mv panini_euro2012.a* upload