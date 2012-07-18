class XML::SAX;

use XML::SAX::Element;
use XML::SAX::Grammar;

has $.string = '';
has @.stack;

has $.file is rw;


method parse_file($filename) {
	$.file = $filename;
	# TODO Rakudofix
	# read the file with newlines so we can deal with cases when the newlines are need to be kept
	# eg. "literallayout" in docbook
	# open should have a flag for no-chomp
	for $filename.IO.lines -> $line {
		self.parse_str("$line\n");
	}
	self.done;
}

method parse($str) {
	$.file = '';
	self.parse_str($str);
}


method parse_str($str) {
	# insert a space if not tag boundary
	if $!string.chars and $str.chars and substr($!string, *-1) ne '>' and substr($str, 0, 1) ne '<' {
		$!string ~= ' ';
	}
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
			die $/<text> if @!stack[*-1] eq '';
			@!stack[*-1].content.push($/<text>);
			self.content(@!stack[*-1]);
		} elsif $/<comment> {
			# do nothing;
		} else {
			die "Invalid code. Something is not implemented in XML::SAX"
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
	if @!stack {
		die @!stack[*-1].perl if @!stack[*-1] eq '';
		@!stack[*-1].content.push($last);
	}
}

method done() {
	return 1 if $!string eq '' and not @!stack;
	die "Left over string: '$!string'" if $!string and $!string ~~ /\S/;
	die "Still in stack: { @!stack.map({$_.Str}).join(' ') }" if @!stack;
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

# vim: ft=perl6

