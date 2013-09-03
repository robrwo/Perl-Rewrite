package Perl::Rewrite::Rule;

use Any::Moose;

# It's tempting to make PPI::Document an attribute of a rule, but we
# want to instantiate the rules and run them through multiple
# documents.

1;
