cat ourairports.com/2011-11-09/airports.csv | ./vertere_mapper.php ourairports.com/airports.csv.spec.ttl | sort | ./vertere_reducer.php > ourairports.com/airports.rdf.nt

rapper -i ntriples -c airports.rdf.nt