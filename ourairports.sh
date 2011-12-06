#!/bin/bash

echo Describing airports
cat ourairports.com/2011-11-09/airports.csv | ./vertere_mapper.php ourairports.com/airports.csv.spec.ttl > ourairports.com/output_data/full.rdf.nt

echo Describing countries
cat ourairports.com/2011-11-09/countries.csv | ./vertere_mapper.php ourairports.com/countries.csv.spec.ttl >> ourairports.com/output_data/full.rdf.nt

echo Describing regions
cat ourairports.com/2011-11-09/regions.csv | ./vertere_mapper.php ourairports.com/regions.csv.spec.ttl >> ourairports.com/output_data/full.rdf.nt

echo Sorting descriptions
sort -u ourairports.com/output_data/full.rdf.nt > ourairports.com/output_data/sorted.rdf.nt

rm ourairports.com/output_data/full.rdf.nt

#echo Extending descriptions
#cat ourairports.com/output_data/sorted.rdf.nt | ./vertere_reducer.php > ourairports.com/output_data/ourairports.rdf.nt

#rm ourairports.com/output_data/sorted.rdf.nt
mv ourairports.com/output_data/sorted.rdf.nt ourairports.com/output_data/ourairports.rdf.nt

echo Converting descriptions to turtle
rapper -i ntriples -o turtle ourairports.com/output_data/ourairports.rdf.nt > ourairports.com/output_data/ourairports.rdf.ttl

echo Converting descriptions to rdfxml
rapper -i ntriples -o rdfxml-abbrev ourairports.com/output_data/ourairports.rdf.nt > ourairports.com/output_data/ourairports.rdf.xml

