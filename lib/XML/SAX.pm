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

method parse_file($filename) {
	for lines $filename -> $line {
		self.parse($line);
	}
	self.done;
}

# TODO Rakudofix: replace <opening=&opening> by <opening>
method parse($str) {
	$!string ~= $str;

	while $!string ~~ m/^ [ <opening=&opening> || <closing=&closing> || <text=&text> ] / {
		#note $!string;
		#note $/;
		$!string .= substr($/.to);
		
		if $/<opening> {
			#my @attributes;
			#note $/<opening><attr>;
			my @attributes = map( {
				XML::SAX::Attribute.new(
					name => $_<name>,
					value => $_<value>,
				) }, $/<opening><attr>);
			my $element = XML::SAX::Element.new(
					name => $/<opening><element>,
					attributes => @attributes,
				);
			@!stack.push($element);
			self.start_elem($element);
		} elsif $/<closing> {
			if not @!stack {
				die "End element '$/<closing><element>' reached while stack was empty";
			}
			my $last = @!stack.pop;
			if $last ne $/<closing><element> {
				die "End element '$/<closing><element>' reached while in '$last' element";
			}
			self.end_elem($last);
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
