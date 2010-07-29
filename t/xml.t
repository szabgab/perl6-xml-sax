use v6;

use Test;
BEGIN { 
	@*INC.push('lib');
}

plan 10+8+6+3;

use XML::SAX;
ok 1, 'ok';

my @parsed;
class XML::SAX::Test is XML::SAX {
	method start_elem($elem) {
		@parsed.push(['start_elem', $elem]);
	}
	method end_elem($elem) {
		@parsed.push(['end_elem', $elem]);
	}
}

{
	my $xml = XML::SAX.new;
	is $xml.WHAT, 'XML::SAX()', 'XML::SAX constructor';
}

my $xml = XML::SAX::Test.new;
is $xml.WHAT, 'XML::SAX::Test()', 'XML::SAX::Test constructor';

#----------------

$xml.parse('<chapter>');
is @parsed.elems, 1, 'one element';
is @parsed[0][0], 'start_elem', 'start_elem';
is @parsed[0][1], 'chapter', 'chapter';
#ok @parsed ~~ ['chapter'], 'parsed chapter';
#note @parsed.perl;
#note ;

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

#----------------

@parsed = ();
$xml.parse('<chapter>');
$xml.parse('</chapter>');
$xml.done;
is $xml.string, '', 'string is empty';
is $xml.stack.elems, 0, 'stack is empty';
is @parsed.elems, 2, '2 elems';
is @parsed[0][0], 'start_elem', 'start_elem';
is @parsed[0][1], 'chapter', 'chapter start';
is @parsed[1][0], 'end_elem', 'end_elem';
is @parsed[1][1], 'chapter', 'chapter end';


#----------------

@parsed = ();
my $exception;
$xml.reset;
{
	$xml.parse('</chapter>');
	CATCH {
		$exception = $_;
	}
}
is $exception, "End element 'chapter' reached while stack was empty", 'exception on single </chapter>';

#----------------

@parsed = ();
$xml.reset;
$xml.parse('<chapter><page></page></chapter>');
$xml.done;
is $xml.string, '', 'string is empty';
is $xml.stack.elems, 0, 'stack is empty';
is @parsed.elems, 4, '4 elems';
#is @parsed[0][0], 'start_elem', 'start_elem';
#is @parsed[0][1], 'chapter', 'chapter start';
#is @parsed[1][0], 'end_elem', 'end_elem';
#is @parsed[1][1], 'chapter', 'chapter end';

#----------------

@parsed = ();
$exception = '';
$xml.reset;
my $str = '<chapter><page></chapter>';
{
	$xml.parse($str);
	CATCH {
		$exception = $_;
	}
}
is $exception, "End element 'chapter' reached while in 'page' element", $str;

#----------------

@parsed = ();
$exception = '';
$xml.reset;
$str = '<chapter><page></page></page></chapter>';
{
	$xml.parse($str);
	CATCH {
		$exception = $_;
	}
}
is $exception, "End element 'page' reached while in 'chapter' element", $str;


#----------------

@parsed = ();
$exception = '';
$xml.reset;
$str = '<chapter id="12" name="perl"  ></chapter>';
$xml.parse($str);
$xml.done;
is $xml.string, '', 'string is empty';
is $xml.stack.elems, 0, 'stack is empty';
is @parsed.elems, 2, '2 elems';



# note "Ex: $exception";
# TODO: 
#   call process on data items
#   include attributes in start_elem 
#   parse data given in a file


