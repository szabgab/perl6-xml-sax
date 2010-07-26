class XML::SAX;

has $string = '';
has @stack;

method parse($str) {
	$string ~= $str;
	
	if $string ~~ m/^ \< (\w+) \> / {
		$string .= substr($/.to);
		@stack.push($/[0]);
		self.start_elem($/[0]);
	}
}

method start_elem($elem) {
	...
}
