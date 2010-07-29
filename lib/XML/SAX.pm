class XML::SAX;

has $.string = '';
has @.stack;

method parse($str) {
	$!string ~= $str;
	
	if $!string ~~ m/^ \< (\w+) \> / {
		$!string .= substr($/.to);
		@!stack.push($/[0]);
		self.start_elem($/[0]);
	}

	if $!string ~~ m/^ \<\/ (\w+) \> / {
		$!string .= substr($/.to);
		if not @!stack {
			die "End element '$/[0]' reached while stack was empty";
		}
		my $last = @!stack.pop;
		if $last ne $/[0] {
			die "End element '$/[0]' reached while in '$last' element";
		}
		self.end_elem($/[0]);
	}
}

method done() {
	return 1 if $!string eq '' and not @!stack;
	die "Left over string: '$!string'" if $!string;
	die "Still in stack: { @!stack }" if @!stack;
}

method reset() {
	$!string = '';
	@!stack = ();
}


method start_elem($elem) {
	...
}

method end_elem($elem) {
	...
}
