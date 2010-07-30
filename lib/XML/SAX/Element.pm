class XML::SAX::Element;

has $.name;
has @.content is rw;
has @.attributes;

method Str() {
	$.name;
}


