use v6;

use Test;
BEGIN { 
	@*INC.push('lib');
}

plan 10;

use XML::SAX;
ok 1, 'ok';

my @parsed;
class XML::SAX::Test is XML::SAX {
	method start_elem($elem) {
		@parsed.push($elem);
	}
}

{
	my $xml = XML::SAX.new;
	is $xml.WHAT, 'XML::SAX()', 'XML::SAX constructor';
}

my $xml = XML::SAX::Test.new;
is $xml.WHAT, 'XML::SAX::Test()', 'XML::SAX::Test constructor';

$xml.parse('<chapter>');
is @parsed.elems, 1, 'one element';
is @parsed[0], 'chapter', 'chapter';
{
	$xml.done;
	CATCH {
		is $_, 'Still in stack: chapter', 'exception still in stack';
	}
}

is $xml.string, '', 'string is empty';
is $xml.stack[0], 'chapter', 'stack is chapter';

$xml.reset;
is $xml.string, '', 'string is empty';
is $xml.stack.elems, 0, 'stack is empty';


#ok @parsed ~~ ['chapter'], 'parsed chapter';
#note @parsed.perl;
#note ;


