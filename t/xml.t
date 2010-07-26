use v6;

use Test;
BEGIN { 
	@*INC.push('lib');
}

plan 3;

use XML::SAX;
ok 1, 'ok';

#my $callback;
#sub callback($ {
#	$callbck
#}

my @parsed;
class XML::SAX::Test is XML::SAX {
	method start_elem($elem) {
		@parsed.push($elem);
	}
}

{
	my $xml = XML::SAX.new;
	is $xml.WHAT, 'XML::SAX()';
}

my $xml = XML::SAX::Test.new;
is $xml.WHAT, 'XML::SAX::Test()';

#$xml.parse('<chapter>');



