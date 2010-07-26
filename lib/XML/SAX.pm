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

method done() {
	return 1 if $string eq '' and not @stack;
	die "Left overs string: '$string'" if $string;
	die "Still in stack: { @stack }" if @stack;
}


method start_elem($elem) {
	...
}
