class XML::SAX::Element;

has $.name;
has @.attributes;

method Str() {
	$.name;
}


