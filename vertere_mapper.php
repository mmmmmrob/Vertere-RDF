#!/usr/bin/env php
<?php
ini_set('memory_limit', '2048M');
define('LIB_DIR', dirname(__FILE__) . '/lib/');
define('MORIARTY_DIR', LIB_DIR.'moriarty/');
define('MORIARTY_ARC_DIR', LIB_DIR.'arc/');
include_once MORIARTY_DIR.'moriarty.inc.php';
include_once MORIARTY_DIR.'simplegraph.class.php';
include_once 'inc/sequencegraph.class.php';
include_once 'inc/csvreader.class.php';
include_once 'inc/vertere.class.php';
include_once 'inc/diagnostics.php';

define('NS_CONV', 'http://example.com/schema/data_conversion#');
define('NS_RDF', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#');

$spec_file = file_get_contents('inc/spec.ttl');
$spec = new SimpleGraph();
$spec->from_turtle($spec_file);

$specs = $spec->get_subjects_of_type(NS_CONV.'Spec');
if (count($specs) > 1) { abort('spec file may only contain one conversion spec'); }
$spec_uri = $specs[0];

//Find format and create reader for it
$format_uri = $spec->get_first_resource($spec_uri, NS_CONV.'format');
$reader = $format_uri == NS_CONV.'CSV' ? new CsvReader(STDIN) : null;
if ($reader == null) { abort("Format ${format_uri} is not supported."); }

//Find uri specs
$uri_spec_seq = $spec->get_first_resource($spec_uri, NS_CONV.'uri_specs');
if (empty($uri_spec_seq)) { abort('Unable to find any sequence of uris to create'); }
$uri_specs = $spec->get_sequence_values($uri_spec_seq);
if (empty($uri_specs)) { abort('Unable to find any sequence of uris to create'); }

$base_uri = $spec->get_first_literal($spec_uri, NS_CONV.'base_uri');

$output_graph = new SimpleGraph();

//Create graph from records
while ($record = $reader->next_record()) {
	$uris = array();
	//Create our URIs and keep them for the property processing
	foreach ( $uri_specs as $uri_spec ) {
		$source_column = $spec->get_first_literal($uri_spec, NS_CONV.'source_column');
		if ($spec->has_resource_triple($uri_spec, NS_RDF.'type', NS_CONV.'UriLookupSpec')) {
			$lookup = $spec->get_first_resource($uri_spec, NS_CONV.'lookup');
			$lookup_graph = $spec->get_subject_subgraph($lookup);
			print_r($lookup_graph); die();
		} else {
			$container = $spec->get_first_literal($uri_spec, NS_CONV.'container');
			$urlify = $spec->get_first_literal($uri_spec, NS_CONV.'urlify');
			$base_uri_override = $spec->get_first_literal($uri_spec, NS_CONV.'base_uri');
			$append_uri = $spec->get_first_literal($uri_spec, NS_CONV.'append_uri');
			$base_to_use = $base_uri_override ? $base_uri_override : $base_uri;
			$uri_part = $urlify == "true" ? Vertere::urlify($record[$source_column]) : $record[$source_column];
			$uri = $container ? "${base_to_use}${container}/${uri_part}${append_uri}" : "${base_to_use}${uri_part}${append_uri}";
		}
		$type = $spec->get_first_resource($uri_spec, NS_CONV.'type');
		if ($type) {
			$output_graph->add_resource_triple($uri, NS_RDF.'type', $type);
		}
		$uris[$uri_spec] = $uri;
	}
	echo $output_graph->to_ntriples();
	$output_graph->remove_all_triples();
}