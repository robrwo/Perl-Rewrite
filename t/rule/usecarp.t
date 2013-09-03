#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp qw/ read_file /;
use File::Temp qw/ tempfile /;
use PPI;
use Readonly;
use Test::More;

Readonly::Scalar my $shebang => '/usr/local/bin/perl';

use_ok('Perl::Rewrite::Rule::UseCarp');

ok(my $rule = Perl::Rewrite::Rule::UseCarp->new( ),
   "new");

is($rule->api_version(), 1, "api_version");

{
    my $ppi = PPI::Document->new( \ "warn \"Hello World\";\n" );

    $rule->apply($ppi);

    my ($fh, $tmpfile) = tempfile();

    $ppi->save( $tmpfile );

    my @content = read_file( $tmpfile );

    note(join("", @content));

}


done_testing;
