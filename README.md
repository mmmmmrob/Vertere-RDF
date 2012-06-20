Vertere-RDF
===========

Vertere is a spreadsheet->RDF conversion tool based on a templating mechanism. Lines in CSV or TSV files are read sequentially, each line resulting in one or more RDF resources, while each column value can result in one or more triples about this resource.

(C) 2012 Rob Styles

Contributor: Knud Möller

Usage
-----

Assuming PHP is installed, the following shows how to convert an **input.csv** file with Vertere, using  the mapping specification **mapping.ttl** and writing to **output.nt** in N-Triples (all on the command line):

    cat input.csv | vertere_mapper.php mapping.ttl > output.nt

For more detailed examples, look in the /Examples folder!