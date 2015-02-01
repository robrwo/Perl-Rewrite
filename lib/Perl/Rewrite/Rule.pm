package Perl::Rewrite::Rule;

use Moo;

use PPI;

# It's tempting to make PPI::Document an attribute of a rule, but we
# want to instantiate the rules and run them through multiple
# documents.

1;
