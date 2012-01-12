#!/usr/bin/env php
<?php

$utf8 = "Mézières";
echo "${utf8}\n";
echo urlencode($utf8)."\n";
echo rawurlencode($utf8)."\n";
echo iconv('UTF-8', 'ascii//TRANSLIT', $utf8)."\n";
echo preg_replace('/[^-\w]+/', '', iconv('UTF-8', 'ascii//TRANSLIT', $utf8))."\n";


