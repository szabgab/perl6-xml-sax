grammar XML::SAX::Grammar;

regex TOP { ^ [ \s* <opening> || \s* <closing> || \s* <single> || <text>
	|| \s* <comment> ] }

token element { \w+ }
token name    { \w+ }
token value   { <-[\"]>* }
rule  attr    { [<name>\=\"<value>\"] }
rule  text    { <-[\<]>+ <?before \< > }
regex opening { \< <element> <attr>* \> }
regex closing { \<\/ <element> \> }
regex single  { \< <element> <attr>* \/\> }

regex comment { \<\!\-\- .*? \-\-\> }
