#!/bin/bash

PROJECT_FOLDER="adventureWorks"



cat /dev/null > $PROJECT_FOLDER/output_data/full.rdf.nt

# echo Starting with turtle files in hand-written rdf
# for file in $(ls $PROJECT_FOLDER/handwritten/*.rdf.ttl)
# do
# 	rapper -i turtle -o ntriples "$file" >> $PROJECT_FOLDER/output_data/full.rdf.nt
# done

echo Validating spec files
for file in $(ls $PROJECT_FOLDER/*.spec.ttl)
do
	rapper -i turtle -c "$file"
done


# echo Describing customers
# cat $PROJECT_FOLDER/AdventureWorks_2008R2_LT/Customer.tsv | ../vertere_mapper.php $PROJECT_FOLDER/customer.tsv.spec.ttl >> $PROJECT_FOLDER/output_data/full.rdf.nt
# 
# echo Describing addresses
# cat $PROJECT_FOLDER/AdventureWorks_2008R2_LT/Address.csv | ../vertere_mapper.php $PROJECT_FOLDER/address.csv.spec.ttl >> $PROJECT_FOLDER/output_data/full.rdf.nt
# 
# echo Linking customers with addresses
# cat $PROJECT_FOLDER/AdventureWorks_2008R2_LT/CustomerAddress.csv | ../vertere_mapper.php $PROJECT_FOLDER/customer_address.csv.spec.ttl >> $PROJECT_FOLDER/output_data/full.rdf.nt

echo Describing product categories
cat $PROJECT_FOLDER/AdventureWorks_2008R2_LT/ProductCategory.csv | ../vertere_mapper.php $PROJECT_FOLDER/product_category.csv.spec.ttl >> $PROJECT_FOLDER/output_data/full.rdf.nt

echo Describing products
cat $PROJECT_FOLDER/AdventureWorks_2008R2_LT/Product.tsv | ../vertere_mapper.php $PROJECT_FOLDER/product.csv.spec.ttl >> $PROJECT_FOLDER/output_data/full.rdf.nt

echo Sorting and de-duping descriptions
sort -u $PROJECT_FOLDER/output_data/full.rdf.nt > $PROJECT_FOLDER/output_data/adventureworks.rdf.nt

# rm $PROJECT_FOLDER/output_data/full.rdf.nt

#echo De-duping and extending descriptions
#cat ourairports.com/output_data/sorted.rdf.nt | ../vertere_reducer.php > ourairports.com/output_data/ourairports.rdf.nt

echo Listing properties used
cat $PROJECT_FOLDER/output_data/adventureworks.rdf.nt | awk '{ print $2 }' | sort -u > $PROJECT_FOLDER/output_data/adventureworks.properties_used.txt

echo Listing classes used
cat $PROJECT_FOLDER/output_data/adventureworks.rdf.nt | awk '{ print $2 " " $3 }' | grep "^<http://www.w3.org/1999/02/22-rdf-syntax-ns#type> " | awk '{ print $2 }' | sort -u > $PROJECT_FOLDER/output_data/adventureworks.classes_used.txt

# echo Converting descriptions to turtle
# rapper -i ntriples -o turtle -f'xmlns:conv="http://example.com/schema/data_conversion#"' -f'xmlns:bibo="http://example.com/bibo#"' -f'xmlns:fly="http://data.kasabi.com/dataset/airports/schema/"' -f'xmlns:foaf="http://xmlns.com/foaf/0.1/"' -f'xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"' -f'xmlns:georss="http://www.georss.org/georss/"' -f'xmlns:owl="http://www.w3.org/2002/07/owl#"' -f'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"' -f'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"' -f'xmlns:spacerel="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"' -f'xmlns:xsd="http://www.w3.org/2001/XMLSchema#"' ourairports.com/output_data/ourairports.rdf.nt > ourairports.com/output_data/ourairports.rdf.ttl
# 
# echo Converting descriptions to rdfxml
# rapper -i ntriples -o rdfxml-abbrev -f'xmlns:conv="http://example.com/schema/data_conversion#"' -f'xmlns:bibo="http://example.com/bibo#"' -f'xmlns:fly="http://data.kasabi.com/dataset/airports/schema/"' -f'xmlns:foaf="http://xmlns.com/foaf/0.1/"' -f'xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"' -f'xmlns:georss="http://www.georss.org/georss/"' -f'xmlns:owl="http://www.w3.org/2002/07/owl#"' -f'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"' -f'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"' -f'xmlns:spacerel="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"' -f'xmlns:xsd="http://www.w3.org/2001/XMLSchema#"' ourairports.com/output_data/ourairports.rdf.nt > ourairports.com/output_data/ourairports.rdf.xml
# 
