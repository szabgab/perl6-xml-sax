class XML::SAX::Element;

has $.name;
has @.content is rw;
has %.attributes;

method Str() {
	$.name;
}

method get_content {
	return '' if not @.content;
	#die "No content" if not @.content;
	return @.content[0] if  @.content.elems == 1;
	my $str = '';
	for @.content -> $c {
		if $c.can('get_content') {
			$str ~= $c.get_content;
		}
	}
	return $str;
}

# vim: ft=perl6

