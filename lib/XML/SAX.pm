class XML::SAX;

has $string = '';

method parse($str) {
	$string ~= $str;
	
}