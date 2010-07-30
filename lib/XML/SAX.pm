class XML::SAX;

use XML::SAX::Element;
use XML::SAX::Grammar;

has $.string = '';
has @.stack;

method parse_file($filename) {
	for lines $filename -> $line {
		self.parse($line);
	}
	self.done;
}

# TODO Rakudofix: replace <opening=&opening> by <opening>
method parse($str) {
	$!string ~= $str;
	
	while XML::SAX::Grammar.parse($!string) {
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
	#say $match<attr>.perl;
	#say $match<attr>.WHAT;
	#say $match<attr>.elems;
	# TODO Rakudo bug ? ~ needed for stringification on next line
	my %attributes = $match<attr>.map( {; ~$_<name> => ~$_<value> } ); 
	my $element = XML::SAX::Element.new(
			name => $match<element>,
			attributes => %attributes,
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

=begin pod

=head NAME

XML::SAX - a SAX XML parser

=head SYNOPSIS


    use XML::SAX;
    class My::XMLProcess is XML::SAX {
        method start_elem($elem) {
            # called with an XML::SAX::Element object when <elem> is reached
        }
        method end_elem($elem) {
            # called with an XML::SAX::Element object when </elem> is reached
        }
        method content($elem) {
            # called with an XML::SAX::Element object when some textual content is reached within an element
        }
    }

    My::XMLProcess.new.parse_file('path/to/file.xml');


    XML::SAX::Element object have the following members:

    name     - the name of the element
    content  - an array of the various pieces of content
    attributes - is a hash where the keys are the attrbute names and the values the attribute values
	
	$elem.attributes<id>


=head AUTHOR

Gabor Szabo <gabor@szabgab.com>

=end pod


