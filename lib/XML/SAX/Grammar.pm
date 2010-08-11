grammar XML::SAX::Grammar;

regex TOP { ^ [ \s* <opening=&opening> || \s* <closing=&closing> || \s* <single=&single> || <text=&text> 
	|| \s* <comment> ] }

my token element { \w+ }
my token name    { \w+ }
my token value   { <-[\"]>* }
my rule attr { [<name=&name>\=\"<value=&value>\"] }
my rule text { <-[\<]>+ <?before \< > }
my regex opening { \< <element=&element> <attr=&attr>* \> }
my regex closing { \<\/ <element=&element> \> }
my regex single { \< <element=&element> <attr=&attr>* \/\> }

regex comment { \<\!\-\- .*? \-\-\> }
