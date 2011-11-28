#!/bin/bash
# mkdir -p rdf/parts
# cd Conversion\ Code;
# 
# echo "Processing ranks into observations and sequences"
# cat ../Source\ Data/WIMD\ 2005-2008-2011\ combined\ ranks.csv | ./wimd2rdf.php > ../rdf/complete.rdf.nt
# #cat ../Source\ Data/WIMD_test.csv | ./wimd2rdf.php > ../rdf/complete.rdf.nt
# 
# echo "Linking postcodes to LSOAs"
# cat ../Source\ Data/Postcode\ to\ LSOA.csv | ./postcode2rdf.php >> ../rdf/complete.rdf.nt
# 
# echo "Processing LAs and Linking LAs to LSOAs"
# cat ../Source\ Data/WIMD\ 2011\ from\ StatsWales.csv | ./la2rdf.php >> ../rdf/complete.rdf.nt
# 
# echo "Extracting GML for LSOAs"
# ./lsoagml2rdf.php >> ../rdf/complete.rdf.nt
# 
# echo "Adding hand written connection to OS for LAs"
# rapper -i turtle -o ntriples ../hand\ written\ rdf/Local\ Authority\ sameAs\ to\ OS.rdf.ttl >> ../rdf/complete.rdf.nt
# 
# echo "Adding additional data from OS to LAs"
# rapper -i turtle -o ntriples ../hand\ written\ rdf/la.unitids.rdf.ttl >> ../rdf/complete.rdf.nt
# 
# echo "Adding hand written schema and data structure defintions"
# rapper -i turtle -o ntriples ../hand\ written\ rdf/def.rdf.ttl >> ../rdf/complete.rdf.nt
# 
# echo "Splitting into parts for uploading"
# cd ../rdf
# rm -f parts/complete_*
# split -l 11000 complete.rdf.nt parts/complete_
# 
# echo "Done"
