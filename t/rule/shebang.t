#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp qw/ read_file /;
use File::Temp qw/ tempfile /;
use PPI;
use Readonly;
use Test::More;

Readonly::Scalar my $shebang => '/usr/local/bin/perl';

use_ok('Perl::Rewrite::Rule::Shebang');

ok(my $rule = Perl::Rewrite::Rule::Shebang->new( shebang => $shebang ),
   "new");

is($rule->api_version(), 1, "api_version");

{
    my $ppi = PPI::Document->new( \ "#!perl\nprint \"Hello World\\n\";\n" );

    $rule->apply($ppi);

    my ($fh, $tmpfile) = tempfile();

    $ppi->save( $tmpfile );

    my @content = read_file( $tmpfile );

    is($content[0], "#!${shebang}\n", "shebang");

}

{
    my $ppi = PPI::Document->new( \ "print \"Hello World\\n\";\n" );

    $rule->apply($ppi);

    my ($fh, $tmpfile) = tempfile();

    $ppi->save( $tmpfile );

    my @content = read_file( $tmpfile );

    is($content[0], "#!${shebang}\n", "shebang");

}

done_testing;
