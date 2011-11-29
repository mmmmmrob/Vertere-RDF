<?php

class Vertere {
	public static function urlify($part) {
		return rawurlencode(str_replace(' ', '_', strtolower(trim($part))));
	}
}