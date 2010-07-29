class XML::SAX;

has $.string = '';
has @.stack;

my token element { \w+ }
my token name    { \w+ }
my regex value   { <-[\"]>* }
#my rule opening { \< <element=&element> \> }
my rule attr { [<name=&name>\=\"<value=&value>\"] }

my rule opening { \< <element=&element> <attr=&attr>* \> }
my regex closing { \<\/ <element=&element> \> }

# TODO Rakudofix: replace <opening=&opening> by <opening>
method parse($str) {
	$!string ~= $str;

	while $!string ~~ m/^ [ <opening=&opening> || <closing=&closing> ] / {
		#note $!string;
		#note $/;
		$!string .= substr($/.to);
		
		if $/<opening> {
			@!stack.push($/<opening><element>);
			self.start_elem($/<opening><element>);
		} elsif $/<closing> {
			if not @!stack {
				die "End element '$/<closing><element>' reached while stack was empty";
			}
			my $last = @!stack.pop;
			if $last ne $/<closing><element> {
				die "End element '$/<closing><element>' reached while in '$last' element";
			}
			self.end_elem($/<closing><element>);
		} else {
			die "Invalid"
		}
	}

	# if $!string ~~ m/^ <closing=&closing> / {
		# $!string .= substr($/.to);
		# if not @!stack {
			# die "End element '$/<closing><element>' reached while stack was empty";
		# }
		# my $last = @!stack.pop;
		# if $last ne $/<closing><element> {
			# die "End element '$/<closing><element>' reached while in '$last' element";
		# }
		# self.end_elem($/<closing><element>);
	# }
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
