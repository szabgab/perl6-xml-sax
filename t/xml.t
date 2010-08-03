use v6;

use Test;
BEGIN { 
	@*INC.push('lib');
}

plan 10+8+6+10+23+21+3+3+13;

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
	method content($elem) {
		@parsed.push(['content', $elem]);
	}
}

{
	my $xml = XML::SAX.new;
	is $xml.WHAT, 'XML::SAX()', 'XML::SAX constructor';
}

my $xml = XML::SAX::Test.new;
is $xml.WHAT, 'XML::SAX::Test()', 'XML::SAX::Test constructor';

#----------------

{
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
}

#----------------

{
	#@parsed = ();
	reset_all();
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
}

#----------------

{
	reset_all();
	my $exception;
	{
		$xml.parse('</chapter>');
		CATCH {
			$exception = $_;
		}
	}
	is $exception, "End element 'chapter' reached while stack was empty", 'exception on single </chapter>';
}
#----------------

{
	reset_all();
	my $exception;

	$xml.parse('<chapter><page></page></chapter>');
	$xml.done;
	is $xml.string, '', 'string is empty';
	is $xml.stack.elems, 0, 'stack is empty';
	is @parsed.elems, 4, '4 elems';
	#is @parsed[0][0], 'start_elem', 'start_elem';
	#is @parsed[0][1], 'chapter', 'chapter start';
	#is @parsed[1][0], 'end_elem', 'end_elem';
	#is @parsed[1][1], 'chapter', 'chapter end';
}

#----------------

{
	reset_all();
	my $exception;

	my $str = '<chapter><page></chapter>';
	{
		$xml.parse($str);
		CATCH {
			$exception = $_;
		}
	}
	is $exception, "End element 'chapter' reached while in 'page' element", $str;
}

#----------------

{
	reset_all();
	my $exception;

	my $str = '<chapter><page></page></page></chapter>';

	{
		$xml.parse($str);
		CATCH {
			$exception = $_;
		}
	}
	is $exception, "End element 'page' reached while in 'chapter' element", $str;
}


#----------------

{
	reset_all();

	my $str = '<chapter id="12" name="perl"  ></chapter>';
	$xml.parse($str);
	$xml.done;
	is $xml.string, '', 'string is empty';
	is $xml.stack.elems, 0, 'stack is empty';
	is @parsed.elems, 2, '2 elems';
	is @parsed[0][0], 'start_elem', 'start_elem';
	is @parsed[0][1], 'chapter', 'chapter start';
	is @parsed[1][0], 'end_elem', 'end_elem';
	is @parsed[1][1], 'chapter', 'chapter end';
	my $attr = @parsed[0][1].attributes;
	is $attr.elems, 2, "2 attributes";
	is $attr<id>, 12, 'id=12';
	is $attr<name>, 'perl', 'name=perl';
}

#----------------

{
	reset_all();

	my $str = '<chapter> before <para>this is the text</para> after </chapter>';
	diag $str;
	$xml.parse($str);
	$xml.done;
	is $xml.string, '', 'string is empty';
	is $xml.stack.elems, 0, 'stack is empty';
	is @parsed.elems, 7, '7 elems';
	is @parsed[0][0], 'start_elem', 'start_elem';
	is @parsed[0][1], 'chapter', 'chapter start';

	is @parsed[1][0], 'content', 'content';
	is @parsed[1][1], 'chapter', ' text before';
	is @parsed[1][1].content[0], ' before ', 'text before';

	is @parsed[2][0], 'start_elem', 'start_elem';
	is @parsed[2][1], 'para', 'para start';

	is @parsed[3][0], 'content', 'content';
	is @parsed[3][1], 'para', ' text inside';
	is @parsed[3][1].content[0], 'this is the text', 'this is the text';

	is @parsed[4][0], 'end_elem', 'end_elem';
	is @parsed[4][1], 'para', 'para end';

	is @parsed[5][0], 'content', 'content';
	is @parsed[5][1], 'chapter', 'text after';
	is @parsed[5][1].content[0], ' before ', 'before para element';
	is @parsed[5][1].content[1], 'para', 'para element';
	is @parsed[5][1].content[1].get_content, 'this is the text', 'content of para element';
	is @parsed[5][1].content[2], ' after ', 'text after';
	
	is @parsed[6][0], 'end_elem', 'end_elem';
	is @parsed[6][1], 'chapter', 'chapter end';
}

# note "Ex: $exception";
# TODO: 
#   parse data given in a file

{
	reset_all();
	diag 't/files/a.xml';

	XML::SAX::Test.new.parse_file('t/files/a.xml');
	is @parsed.elems, 7, '7 elems';
	is @parsed[0][0], 'start_elem', 'start_elem';
	is @parsed[0][1], 'chapter', 'chapter start';

	is @parsed[1][0], 'content', 'content';
	is @parsed[1][1], 'chapter', ' text before';
	is @parsed[1][1].content[0], ' before ', 'text before';

	is @parsed[2][0], 'start_elem', 'start_elem';
	is @parsed[2][1], 'para', 'para start';
 
	is @parsed[3][0], 'content', 'content';
	is @parsed[3][1], 'para', ' text inside';
	is @parsed[3][1].content[0], 'this is the text', 'this is the text';

	is @parsed[4][0], 'end_elem', 'end_elem';
	is @parsed[4][1], 'para', 'para end';

	is @parsed[5][0], 'content', 'content';
	is @parsed[5][1], 'chapter', 'text after';
	is @parsed[5][1].content[0], ' before ', 'before para element';
	is @parsed[5][1].content[1], 'para', 'para element';
	is @parsed[5][1].content[1].get_content, 'this is the text', 'content of para element';
	is @parsed[5][1].content[2], ' after ', 'text after';
	
	is @parsed[6][0], 'end_elem', 'end_elem';
	is @parsed[6][1], 'chapter', 'chapter end';
}

{
	reset_all();
	my $str = "<a>\n <b></b></a>";
	diag $str;

	$xml.parse($str);
	$xml.done;
	is $xml.string, '', 'string is empty';
	is $xml.stack.elems, 0, 'stack is empty';
	is @parsed.elems, 4, '4 elems';
}

{
	reset_all();
	my $str = "<c><a><b></b> </a></c>";
	diag $str;

	$xml.parse($str);
	$xml.done;
	is $xml.string, '', 'string is empty';
	is $xml.stack.elems, 0, 'stack is empty';
	is @parsed.elems, 6, '6 elems';
}

{
	reset_all();
	my $str = qq{<a><b id="23" /></a>};
	diag $str;

	$xml.parse($str);
	$xml.done;
	is $xml.string, '', 'string is empty';
	is $xml.stack.elems, 0, 'stack is empty';
	is @parsed.elems, 4, '4 elems';

	is @parsed[0][0], 'start_elem', 'start_elem';
	is @parsed[0][1], 'a', 'a start';

	is @parsed[1][0], 'start_elem', 'start_elem';
	is @parsed[1][1], 'b', 'b start';

	is @parsed[2][0], 'end_elem', 'end_elem';
	is @parsed[2][1], 'b', 'b end';

	is @parsed[3][0], 'end_elem', 'end_elem';
	is @parsed[3][1], 'a', 'a end';

	my $attr = @parsed[1][1].attributes;
	is $attr.elems, 1, "1 attributes";
	is $attr<id>, 23, 'id=23';
}


sub reset_all() {
	@parsed = ();
	$xml.reset;
}
