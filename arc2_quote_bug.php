<?php
require_once "lib/arc2/ARC2.php";

$index = array(
	'http://example.com/a_subject' => array(
		'http://example.com/a_property' => array(
			array(
				'type' => 'literal',
				'value' => 'something with a " in it',
				'lang' => 'en'
			)
		)
	)
);

$serializer = ARC2::getComponent('NTriplesSerializer', array());
echo "\n\n";
echo $serializer->getSerializedIndex($index);
echo "\n\n";