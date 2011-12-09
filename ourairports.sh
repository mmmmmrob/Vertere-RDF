#!/bin/bash

echo Describing airports
cat ourairports.com/2011-11-09/airports.csv | ./vertere_mapper.php ourairports.com/airports.csv.spec.ttl > ourairports.com/output_data/full.rdf.nt

echo Describing countries
cat ourairports.com/2011-11-09/countries.csv | ./vertere_mapper.php ourairports.com/countries.csv.spec.ttl >> ourairports.com/output_data/full.rdf.nt

echo Describing regions
cat ourairports.com/2011-11-09/regions.csv | ./vertere_mapper.php ourairports.com/regions.csv.spec.ttl >> ourairports.com/output_data/full.rdf.nt

echo Describing runways
cat ourairports.com/2011-11-09/runways.csv | ./vertere_mapper.php ourairports.com/runways.csv.spec.ttl >> ourairports.com/output_data/full.rdf.nt

echo Sorting and de-duping descriptions
sort -u ourairports.com/output_data/full.rdf.nt > ourairports.com/output_data/sorted.rdf.nt

rm ourairports.com/output_data/full.rdf.nt

#echo De-duping and extending descriptions
#cat ourairports.com/output_data/sorted.rdf.nt | ./vertere_reducer.php > ourairports.com/output_data/ourairports.rdf.nt

#rm ourairports.com/output_data/sorted.rdf.nt
mv ourairports.com/output_data/sorted.rdf.nt ourairports.com/output_data/ourairports.rdf.nt

echo Converting descriptions to turtle
rapper -i ntriples -o turtle -f'xmlns:conv="http://example.com/schema/data_conversion#"' -f'xmlns:bibo="http://example.com/bibo#"' -f'xmlns:fly="http://flybydata.com/schema/"' -f'xmlns:foaf="http://xmlns.com/foaf/0.1/"' -f'xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"' -f'xmlns:georss="http://www.georss.org/georss/"' -f'xmlns:owl="http://www.w3.org/2002/07/owl#"' -f'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"' -f'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"' -f'xmlns:spacerel="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"' -f'xmlns:xsd="http://www.w3.org/2001/XMLSchema#"' ourairports.com/output_data/ourairports.rdf.nt > ourairports.com/output_data/ourairports.rdf.ttl

echo Converting descriptions to rdfxml
rapper -i ntriples -o rdfxml-abbrev -f'xmlns:conv="http://example.com/schema/data_conversion#"' -f'xmlns:bibo="http://example.com/bibo#"' -f'xmlns:fly="http://flybydata.com/schema/"' -f'xmlns:foaf="http://xmlns.com/foaf/0.1/"' -f'xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"' -f'xmlns:georss="http://www.georss.org/georss/"' -f'xmlns:owl="http://www.w3.org/2002/07/owl#"' -f'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"' -f'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"' -f'xmlns:spacerel="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"' -f'xmlns:xsd="http://www.w3.org/2001/XMLSchema#"' ourairports.com/output_data/ourairports.rdf.nt > ourairports.com/output_data/ourairports.rdf.xml

