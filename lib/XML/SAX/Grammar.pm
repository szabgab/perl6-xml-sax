grammar XML::SAX::Grammar;

token TOP {
    ^   [
        || \s* <opening>
        || \s* <closing>
        || \s* <single>
        || <text>
        || \s* <comment>
        ]
}

token element { \w+ }
token name    { \w+ }
token value   { <-[\"]>* }
token attr    { <.ws> <name> '="' <value> '"' <.ws> }
token text    { <-[\<]>+ <?[\<]> }
token opening { '<' <.ws> <element> <attr>* '>' }
token closing { '<' <.ws> '/' <.ws> <element> <.ws> '>' }
token single  { '<' <.ws> <element> <attr>* '/' <.ws> '>' }
token comment { '<!--' .*? '-->' }
