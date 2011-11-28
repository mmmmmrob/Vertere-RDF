<?php

class CsvReader {
	var $_csv_file;
	
	public function __construct($file) {
		$this->_csv_file = $file;
	}
	
	public function next_record() {
		return fgetcsv($this->_csv_file);
	}
}