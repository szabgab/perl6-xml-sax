use v6;

use Test;
my $test;

plan $test;


use XML::SAX;
BEGIN { $test += 1 }
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
	BEGIN { $test += 1 }
	my $xml = XML::SAX.new;
	isa_ok $xml, 'XML::SAX';
}

my $xml = XML::SAX::Test.new;
BEGIN { $test += 1 }
isa_ok $xml, 'XML::SAX::Test', 'XML::SAX::Test constructor';

#----------------

{
	BEGIN { $test += 7 }
	reset_all();
	my $str = '<chapter>';
	$xml.parse($str);
	is @parsed.elems, 1, 'one element';
	my @expected = (
		['start_elem', 'chapter'],
	);
	cmp_deep(@parsed, @expected, $str);

	{
		$xml.done;
		CATCH {
			default {
				is $_, 'Still in stack: chapter', 'exception still in stack';
			}
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
	BEGIN { $test += 3 }
	#@parsed = ();
	my $str = "<chapter></chapter>";
	reset_all();
	$xml.parse('<chapter>');
	$xml.parse('</chapter>');
	$xml.done;
	is $xml.string, '', 'string is empty';
	is $xml.stack.elems, 0, 'stack is empty';
	my @expected = (
		['start_elem', 'chapter'],
		['end_elem', 'chapter'],
	);
	cmp_deep(@parsed, @expected, $str);
}

#----------------

{
	BEGIN { $test += 1 }
	reset_all();
	my $exception;
	{
		$xml.parse('</chapter>');
		CATCH {
			default {
				$exception = $_;
			}
		}
	}
	is $exception, "End element 'chapter' reached while stack was empty", 'exception on single </chapter>';
}
#----------------

{
	BEGIN { $test += 3 }
	reset_all();
	my $exception;

	my $str = '<chapter><page></page></chapter>';
	$xml.parse($str);
	$xml.done;
	is $xml.string, '', 'string is empty';
	is $xml.stack.elems, 0, 'stack is empty';
	my @expected = (
		['start_elem', 'chapter'],
		['start_elem', 'page'],
		['end_elem', 'page'],
		['end_elem', 'chapter'],
	);
	cmp_deep(@parsed, @expected, $str);
}

#----------------

{
	BEGIN { $test += 1 }
	reset_all();
	my $exception;

	my $str = '<chapter><page></chapter>';
	{
		$xml.parse($str);
		CATCH {
			default {
				$exception = $_;
			}
		}
	}
	is $exception, "End element 'chapter' reached while in 'page' element", $str;
}

#----------------

{
	BEGIN { $test += 1 }
	reset_all();
	my $exception;

	my $str = '<chapter><page></page></page></chapter>';

	{
		$xml.parse($str);
		CATCH {
			default {
				$exception = $_;
			}
		}
	}
	is $exception, "End element 'page' reached while in 'chapter' element", $str;
}


#----------------

{
	BEGIN { $test += 3 }
	reset_all();

	my $str = '<chapter id="12" name="perl"  ></chapter>';
	$xml.parse($str);
	$xml.done;
	is $xml.string, '', 'string is empty';
	is $xml.stack.elems, 0, 'stack is empty';
	my @expected = (
		['start_elem', 'chapter', {id => 12, name => 'perl'}],
		['end_elem', 'chapter'],
	);
	cmp_deep(@parsed, @expected, $str);
}

#----------------

{
	BEGIN { $test += 3 }
	reset_all();

	my $str = '<chapter> before <para>this is the text</para> after </chapter>';
	diag $str;
	$xml.parse($str);
	$xml.done;
	is $xml.string, '', 'string is empty';
	is $xml.stack.elems, 0, 'stack is empty';

	my @expected = (
		['start_elem', 'chapter'],
		['content',    'chapter', ' before '],
		['start_elem', 'para'],
		['content',    'para', 'this is the text'],
		['end_elem',   'para'],
		['content',    'chapter', ' before ', 'para', ' after '],
		['end_elem',   'chapter'],
	);
	cmp_deep(@parsed, @expected, $str);
	#is @parsed[5][1].content[1].get_content, 'this is the text', 'content of para element';
}

# note "Ex: $exception";
# TODO:
#   parse data given in a file

{
	BEGIN { $test += 3 }
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
	BEGIN { $test += 3 }
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
	BEGIN { $test += 3 }
	reset_all();
	my $str = qq{<a><b id="23" /></a>};
	diag $str;

	$xml.parse($str);
	$xml.done;
	is $xml.string, '', 'string is empty';
	is $xml.stack.elems, 0, 'stack is empty';

	my @expected = (
		['start_elem', 'a'],
		['start_elem', 'b', {id => 23}],
		['end_elem',   'b'],
		['end_elem',   'a'],
	);
	cmp_deep(@parsed, @expected, $str);
}

{
	BEGIN { $test += 2 }
	reset_all();
	my $str = qq{<a> apple <!-- <b id="23" /> --> banana </a>};
	diag $str;

	$xml.parse($str);
	$xml.done;
	is $xml.string, '', 'string is empty';

	my @expected = (
		['start_elem', 'a'],
		['content',    'a', ' apple '],
		['content',    'a', ' apple ', ' banana '],
		['end_elem',   'a'],
	);
	cmp_deep(@parsed, @expected, $str);
}

#{
#	BEGIN { $test += 2 }
#	reset_all();
#	my $str = qq{<p>before <ul><li>item1 <a href="htt://url1">link1</a> text <a href="htt://url2">link2</a> end1</li>};
#	$str   ~= qq{<li><a href="http://url3">link3</a> middle <a href="http://url4">link4</a></li>\n  </ul> after</p>};
#	$xml.parse($str);
#	$xml.done;
#	is $xml.string, '', 'string is empty';
#	my @expected = (
#		['start_elem', 'p'],
#		['content',    'p', 'before '],
#		['start_elem', 'ul'],
#
#		['start_elem', 'li'],
#		['content',    'li', 'item1 '],
#		['start_elem', 'a'], # attribute?
#		['content',    'a', 'link1'],
#		['end_elem',   'a'],
#		['content',    'li', ' text '],
#		['start_elem', 'a'], # attribute?
#		['content',    'a', 'link2 '],
#		['end_elem',   'a'],
#		['content',    'li', ' end1'],
#		['end_elem',   'li'],
#
#		['start_elem', 'li'],
#		['content',    'li', ''],
#		['start_elem', 'a'], # attribute?
#		['content',    'a', 'link3'],
#		['end_elem',   'a'],
#		['content',    'li', ' middle '],
#		['start_elem', 'a'], # attribute?
#		['content',    'a', 'link4 '],
#		['end_elem',   'a'],
#		['content',    'li', ''],
#		['end_elem',   'li'],
#
#		['end_elem',   'ul'],
#		['content',    'p', ' after'],
#		['end_elem',   'p'],
#	);
#	cmp_deep(@parsed, @expected, $str);
#}

{
	BEGIN { $test += 1 }
	reset_all();
	diag 't/files/a.xml';

	XML::SAX::Test.new.parse_file('t/files/a.xml');
	my @expected = (
		['start_elem', 'chapter'                     ],
		['content',    'chapter', " before \n"       ],
		['start_elem', 'para'                        ],
		['content',    'para',   "this is the text\n"],
		['end_elem',   'para'                        ],
		['content',    'chapter', " before \n", 'para', "\n  after\n  "],
		['end_elem',   'chapter'                     ],
	);

	cmp_deep(@parsed, @expected);

	#is @parsed[5][1].content[1].get_content, "this is the text\n", 'content of para element';
}

sub cmp_deep(@real, @expected, $name = '') {

	my $err = '';
	for 0 .. @expected.elems-1 -> $i {
		for 0 .. 1 -> $j {
			if @real[$i][$j] ne @expected[$i][$j] {
				ok 0, $name;
				diag "In row $i column $j.\n  Expected: '{@expected[$i][$j]}'\n  Received: '{@real[$i][$j]}'";
				return False;
			}
		}
	#is $attr<id>, 12, 'id=12';
	#is $attr<name>, 'perl', 'name=perl';
		if @real[$i][0] eq 'start_elem' {
			my $attr = @real[$i][1].attributes;
			my $expected_attr = @expected[$i][2] // {};
			for $expected_attr.keys -> $k {
				#if not exists $attr{$k} {
				#	ok 0, $name;
				#	diag "In row $i Expected attribute '$k' does not exist\n ";
				#	return False;
				#}
				if $expected_attr{$k} ne $attr{$k} {
					ok 0, $name;
					diag "In row $i Expected attribute '$expected_attr{$k}' is not the same as the Received $attr{$k}\n";
					return False;
				}
			}
			if $attr.elems != $expected_attr.elems {
				ok 0, $name;
				diag "Incorrect number of attributes in row $i.\n";
				return False;
			}
			if @real[$i].elems > 3 {
					ok 0, $name;
					diag "In row $i (start_elem) number of elements is {@real[$i].elems} which is more than 3\n" ~ @real[$i].perl;
					return False;
			}
		} elsif @real[$i][0] eq 'end_elem' {
			if @real[$i].elems > 2 {
					ok 0, $name;
					diag "In row $i (end_elem) number of elements is {@real[$i].elems} which is more than 2\n" ~ @real[$i].perl;
					return False;
			}
		} else {
			for 2 .. @expected[$i].elems-1 -> $j {
				if @real[$i][1].content[$j-2] ne @expected[$i][$j] {
					ok 0, $name;
					diag "In row $i content $j.\n  Expected: '{@expected[$i][$j]}'\n  Received: '{@real[$i][1].content[$j-2]}'";
					return False;
				}
			}
		}
	}

	if @real.elems != @expected.elems {
		ok 0, $name;
		diag "Number of elements don't match. expected {@expected.elems} received {@real.elems}";
		return False;
	}

	ok 1, $name;
	return True;
}



sub reset_all() {
	@parsed = ();
	$xml.reset;
}
# <a href="http://url">link</a> after-link

# vim: ft=perl6

