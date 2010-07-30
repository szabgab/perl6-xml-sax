class XML::SAX;

use XML::SAX::Element;
use XML::SAX::Attribute;

has $.string = '';
has @.stack;

my token element { \w+ }
my token name    { \w+ }
my token value   { <-[\"]>* }
my rule attr { [<name=&name>\=\"<value=&value>\"] }
my rule text { <-[\<]>+ <?before \< > }
my regex opening { \< <element=&element> <attr=&attr>* \> }
my regex closing { \<\/ <element=&element> \> }
my regex single { \< <element=&element> <attr=&attr>* \/\> }

method parse_file($filename) {
	for lines $filename -> $line {
		self.parse($line);
	}
	self.done;
}

# TODO Rakudofix: replace <opening=&opening> by <opening>
method parse($str) {
	$!string ~= $str;
	
	while $!string ~~ m/^ [ \s* <opening=&opening> || \s* <closing=&closing> || \s* <single=&single> || <text=&text> ] / {
		#note $!string;
		#note $/;
		$!string .= substr($/.to);
		
		if $/<opening> {
			self.setup_start($/<opening>);
		} elsif $/<closing> {
			self.setup_end($/<closing>);
		} elsif $/<single> {
			self.setup_start($/<single>);
			self.setup_end($/<single>);
		} elsif $/<text> {
			if not @!stack {
				die "Text seen outside of all elements";
			}
			#note $/<text>;
			@!stack[*-1].content.push($/<text>);
			self.content(@!stack[*-1]);
		} else {
			die "Invalid"
		}
	}
}

# TODO should be submethod?
method setup_start($match) {			
	my @attributes = map( {
		XML::SAX::Attribute.new(
			name => $_<name>,
			value => $_<value>,
		) }, $match<attr>);
	my $element = XML::SAX::Element.new(
			name => $match<element>,
			attributes => @attributes,
		);
	@!stack.push($element);
	self.start_elem($element);
}

method setup_end($match) {
	if not @!stack {
		die "End element '$match<element>' reached while stack was empty";
	}
	my $last = @!stack.pop;
	if $last ne $match<element> {
		die "End element '$match<element>' reached while in '$last' element";
	}
	self.end_elem($last);
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

method content($elem) {
	...
}
