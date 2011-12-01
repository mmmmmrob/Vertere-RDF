<?php
include_once MORIARTY_DIR.'moriarty.inc.php';
include_once MORIARTY_DIR.'simplegraph.class.php';

class Vertere {

	private $spec, $spec_uri, $resources, $base_uri, $lookups = array();

	public function __construct($spec, $spec_uri) {
		$this->spec = $spec;
		$this->spec_uri = $spec_uri;
		
		//Find resource specs
		$this->resources = $spec->get_resource_triple_values($this->spec_uri, NS_CONV.'resource');
		if (empty($this->resources)) { throw new Exception('Unable to find any resource specs to work from'); }
		
		$this->base_uri = $spec->get_first_literal($this->spec_uri, NS_CONV.'base_uri');
	}
	
	public function convert_array_to_graph($record) {
		$uris = $this->create_uris($record);
		// $graph = new SimpleGraph();
		// $this->create_relationships($graph, $uris, $record);
		return $uris;
	}
	
	// private function create_relationships(&$graph, $uris, $record) {
	// 	foreach ( $this->resources as $resource ) {
	// 		
	// 	}
	// }
	
	private function create_uris($record) {
		$uris = array();
		foreach ( $this->resources as $resource ) {
			if (!isset($uris[$resource])) {
				$this->create_uri($record, $uris, $resource);
			}
		}
		return $uris;
	}
	
	private function create_uri($record, &$uris, $resource) {
		$spec = $this->spec;
		$identity = $spec->get_first_resource($resource, NS_CONV.'identity');
		$source_column = $spec->get_first_literal($identity, NS_CONV.'source_column');
		$source_column--; //make the source column zero-indexed
		$source_value = $record[$source_column];

		if (empty($source_value)) {
			return;
		}

		//Check for lookups
		$lookup = $spec->get_first_resource($identity, NS_CONV.'lookup');
		if($lookup != null) {
			$lookup_value = $this->lookup($lookup, $source_value);
			if ($lookup_value != null && $lookup_value['type'] == 'uri') {
				$uris[$resource] = $lookup_value['value'];
				return;
			} else {
				$source_value = $lookup_value['value'];
			}
		}
		
		//Decide on base_uri
		$base_uri = $spec->get_first_literal($identity, NS_CONV.'base_uri');
		if ($base_uri === null) { $base_uri = $this->base_uri; }

		//Decide if the resource should be nested (overrides the base_uri)
		$nest_under = $spec->get_first_resource($identity, NS_CONV.'nest_under');
		if ($nest_under != null) {
			if (!isset($uris[$nest_under])) {
				$this->create_uri($record, $uris, $nest_under);
			}
			$base_uri = $uris[$nest_under];
			if (!preg_match('%[/#]$%', $base_uri)) { $base_uri .= '/'; }
		}
		
		$container = $spec->get_first_literal($identity, NS_CONV.'container');
		if (!empty($container) && !preg_match('%[/#]$%', $container)) { $container .= '/'; }
		
		//$processes = $spec->get_first_resource($identity, NS_CONV.'process');
		$source_value = $this->process($identity, $source_value);

		$uris[$resource] = "${base_uri}${container}${source_value}";
	}
	
	public function process($resource, $value) {
		$processes = $this->spec->get_first_resource($resource, NS_CONV.'process');
		if ($processes != null) {
			$process_steps = $this->spec->get_list_values($processes);
			foreach ($process_steps as $step) {
				switch ($step) {
					case NS_CONV.'normalise':
						$value = strtolower(str_replace(' ', '_', trim($value)));
						break;

					case NS_CONV.'title_case':
						$value = ucwords($value);
						break;

					case NS_CONV.'regex':
						$regex_pattern = $this->spec->get_first_literal($resource, NS_CONV.'regex_match');
						foreach (array('%','/','@','!','^',',','.','-') as $candidate_delimeter) {
							if(strpos($candidate_delimeter, $regex_pattern) === false) {
								$delimeter = $candidate_delimeter;
								break;
							}
						}
						$regex_output = $this->spec->get_first_literal($resource, NS_CONV.'regex_output');
						$value = preg_replace("${delimeter}${regex_pattern}${delimeter}", $regex_output, $value);
						break;

					default:
						throw new Exception("Unknown process requested: ${step}");
				}
			}
		}
		return $value;
	}
	
	public function lookup($lookup, $key) {
		//Make lookups quicker by banging them into a PHP array
		if (!isset($this->lookups[$lookup])) {
			$entries = $this->spec->get_subject_property_values($lookup, NS_CONV.'lookup_entry');
			if (empty($entries)) { throw new Exception("Lookup ${lookup} had no lookup entries"); }
			foreach ($entries as $entry) {
				//Accept lookups with several keys mapped to a single value
				$lookup_keys = $this->spec->get_subject_property_values($entry['value'], NS_CONV.'lookup_key');
				foreach ($lookup_keys as $lookup_key_array) {
					$lookup_key = $lookup_key_array['value'];
					if (isset($this->lookups[$lookup][$lookup_key])) { throw new Exception("Lookup <${lookup}> contained a duplicate key"); }
					$lookup_values = $this->spec->get_subject_property_values($entry['value'], NS_CONV.'lookup_value');
					if (count($lookup_values) != 1) { throw new Exception("Lookup ${lookup} has an entry ${entry['value']} that does not have exactly one lookup value assigned."); }
					$this->lookups[$lookup][$lookup_key] = $lookup_values[0];
				}
			}
		}
		return isset($this->lookups[$lookup][$key]) ? $this->lookups[$lookup][$key] : null;
	}

	public static function normalise($part) {
		return rawurlencode(str_replace(' ', '_', strtolower(trim($part))));
	}

}

// 
// //Create our statements from the statement specs
// foreach ( $statement_specs as $statement_spec ) {
// 	$subject_from = $spec->get_first_resource($statement_spec, NS_CONV.'subject_from');
// 	if (!isset($uris[$subject_from])) { continue; } //If no subject, then can't make statement
// 	$subject = $uris[$subject_from];
// 	$property = $spec->get_first_resource($statement_spec, NS_CONV.'property');
// 	if (empty($property)) { abort("${statement_spec} does not contain a property."); }
// 	$source_column = $spec->get_first_literal($statement_spec, NS_CONV.'source_column');
// 	$source_column_seq = $spec->get_first_resource($statement_spec, NS_CONV.'source_columns');
// 	$object_from = $spec->get_first_resource($statement_spec, NS_CONV.'object_from');
// 	$language = $spec->get_first_literal($statement_spec, NS_CONV.'language');
// 	$datatype = $spec->get_first_resource($statement_spec, NS_CONV.'datatype');
// 	if ($spec->has_resource_triple($statement_spec, NS_RDF.'type', NS_CONV.'StatementLookupSpec')) {
// 		$source_column--; //make the source column zero-indexed
// 		$lookup = $spec->get_first_resource($statement_spec, NS_CONV.'lookup');
// 		if (!isset($lookups[$lookup][$record[$source_column]])) { abort("Lookup ${lookup} did not contain a lookup for ${record[$source_column]}"); }
// 		$lookup_value = $lookups[$lookup][$record[$source_column]];
// 		if ($lookup_value['type'] == 'uri') {
// 			$output_graph->add_resource_triple($subject, $property, $lookup_value['value']);
// 		} else {
// 			$output_graph->add_literal_triple($subject, $property, $lookup_value['value'], @$lookup_value['lang'], @$lookup_value['datatype']);
// 		}
// 	} else if ($source_column) {
// 		$source_column--; //make the source column zero-indexed
// 		$value = $record[$source_column];
// 		$output_graph->add_literal_triple($subject, $property, $value, $language, $datatype);
// 	} else if ($source_column_seq) {
// 		$source_columns = $spec->get_sequence_values($source_column_seq);
// 		$values = array();
// 		foreach($source_columns as $source_column) {
// 			$values[] = $record[$source_column - 1];
// 		}
// 		$glue = $spec->get_first_literal($statement_spec, NS_CONV.'source_column_glue');
// 		$value = implode($glue, $values);
// 		$output_graph->add_literal_triple($subject, $property, $value, $language, $datatype);
// 	} else if ($object_from) {
// 		if (!isset($uris[$object_from])) { continue; } //If no object then can't make statement
// 		$object = $uris[$object_from];
// 		$output_graph->add_resource_triple($subject, $property, $object);
// 	} else {
// 		abort("$statement_spec does not specify source column(s) or object uri");
// 	}
