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

echo Describing customers
cat AdventureWorks_2008R2_LT/Customer.tsv | $VERTERE_FOLDER/vertere_mapper.php $TEMPLATE_FOLDER/customer.tsv.spec.ttl >> output_data/full.rdf.nt

echo Describing addresses
cat AdventureWorks_2008R2_LT/Address.csv | $VERTERE_FOLDER/vertere_mapper.php $TEMPLATE_FOLDER/address.csv.spec.ttl >> output_data/full.rdf.nt

echo Linking customers with addresses
cat AdventureWorks_2008R2_LT/CustomerAddress.csv | $VERTERE_FOLDER/vertere_mapper.php $TEMPLATE_FOLDER/customer_address.csv.spec.ttl >> output_data/full.rdf.nt

echo Describing product categories
cat AdventureWorks_2008R2_LT/ProductCategory.csv | $VERTERE_FOLDER/vertere_mapper.php $TEMPLATE_FOLDER/product_category.csv.spec.ttl >> output_data/full.rdf.nt

echo Describing products
cat AdventureWorks_2008R2_LT/Product.tsv | $VERTERE_FOLDER/vertere_mapper.php $TEMPLATE_FOLDER/product.csv.spec.ttl >> output_data/full.rdf.nt

echo Describing orders
cat AdventureWorks_2008R2_LT/SalesOrderHeader.csv | $VERTERE_FOLDER/vertere_mapper.php $TEMPLATE_FOLDER/sales_order_header.csv.spec.ttl >> output_data/full.rdf.nt

echo Describing order details
cat AdventureWorks_2008R2_LT/SalesOrderDetail.csv | $VERTERE_FOLDER/vertere_mapper.php $TEMPLATE_FOLDER/sales_order_detail.csv.spec.ttl >> output_data/full.rdf.nt

echo Sorting and de-duping descriptions
sort -u output_data/full.rdf.nt > output_data/adventureworks.rdf.nt

rm output_data/full.rdf.nt

#echo De-duping and extending descriptions
#cat ourairports.com/output_data/sorted.rdf.nt | ../vertere_reducer.php > ourairports.com/output_data/ourairports.rdf.nt

echo Listing properties used
cat output_data/adventureworks.rdf.nt | awk '{ print $2 }' | sort -u > output_data/adventureworks.properties_used.txt

echo Listing classes used
cat output_data/adventureworks.rdf.nt | awk '{ print $2 " " $3 }' | grep "^<http://www.w3.org/1999/02/22-rdf-syntax-ns#type> " | awk '{ print $2 }' | sort -u > output_data/adventureworks.classes_used.txt

echo Converting descriptions to turtle
rapper -i ntriples -o turtle output_data/adventureworks.rdf.nt \
	-f 'xmlns:foaf="http://xmlns.com/foaf/0.1/"' \
	-f 'xmlns:schema="http://schema.org/"' \
	-f 'xmlns:vcard="http://www.w3.org/2006/vcard/ns#"' \
	-f 'xmlns:adv="http://data.kasabi.com/dataset/adventure_works/schema/"' \
	-f 'xmlns:xsd="http://www.w3.org/2001/XMLSchema#"' \
	-f 'xmlns:gr="http://purl.org/goodrelations/v1#"' \
	> output_data/adventureworks.rdf.ttl

# echo Converting descriptions to turtle
# rapper -i ntriples -o turtle -f'xmlns:conv="http://example.com/schema/data_conversion#"' -f'xmlns:bibo="http://example.com/bibo#"' -f'xmlns:fly="http://data.kasabi.com/dataset/airports/schema/"' -f'xmlns:foaf="http://xmlns.com/foaf/0.1/"' -f'xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"' -f'xmlns:georss="http://www.georss.org/georss/"' -f'xmlns:owl="http://www.w3.org/2002/07/owl#"' -f'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"' -f'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"' -f'xmlns:spacerel="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"' -f'xmlns:xsd="http://www.w3.org/2001/XMLSchema#"' ourairports.com/output_data/ourairports.rdf.nt > ourairports.com/output_data/ourairports.rdf.ttl
# 
# echo Converting descriptions to rdfxml
# rapper -i ntriples -o rdfxml-abbrev -f'xmlns:conv="http://example.com/schema/data_conversion#"' -f'xmlns:bibo="http://example.com/bibo#"' -f'xmlns:fly="http://data.kasabi.com/dataset/airports/schema/"' -f'xmlns:foaf="http://xmlns.com/foaf/0.1/"' -f'xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"' -f'xmlns:georss="http://www.georss.org/georss/"' -f'xmlns:owl="http://www.w3.org/2002/07/owl#"' -f'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"' -f'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"' -f'xmlns:spacerel="http://data.ordnancesurvey.co.uk/ontology/spatialrelations/"' -f'xmlns:xsd="http://www.w3.org/2001/XMLSchema#"' ourairports.com/output_data/ourairports.rdf.nt > ourairports.com/output_data/ourairports.rdf.xml
# 

echo Preparing for upload
rm upload/*
split -l 9000 output_data/adventureworks.rdf.nt adventureworks.
mv adventureworks.a* upload