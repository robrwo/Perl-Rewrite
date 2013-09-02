#!/usr/bin/perl

use strict;
use warnings;

use version;

use File::Slurp qw/ read_file /;
use File::Temp qw/ tempfile /;
use PPI;
use Readonly;
use Test::More;

use_ok('Perl::Rewrite::Rule::PerlVersion');

ok(my $rule = Perl::Rewrite::Rule::PerlVersion->new(
       version	=> qv(5.10.1),
       type	=> 'use',
   ), "new");

my $version = $rule->version->stringify;

{
    my $ppi = PPI::Document->new( \ "print \"Hello World\\n\";\n" );

    $rule->apply($ppi);

    my ($fh, $tmpfile) = tempfile();

    $ppi->save( $tmpfile );

    my @content = read_file( $tmpfile );

    # note(join("\n", @content));

    is($content[0], "use ${version};\n", "use version");
}

{
    my $ppi = PPI::Document->new( \ "require 5.004;\nprint \"Hello World\\n\";\n" );

    $rule->apply($ppi);

    my ($fh, $tmpfile) = tempfile();

    $ppi->save( $tmpfile );

    my @content = read_file( $tmpfile );

    # note(join("\n", @content));

    is($content[0], "use ${version};\n", "use version");
}

{
    my $ppi = PPI::Document->new( \ "use v5.14.1;\nprint \"Hello World\\n\";\n" );

    $rule->apply($ppi);

    my ($fh, $tmpfile) = tempfile();

    $ppi->save( $tmpfile );

    my @content = read_file( $tmpfile );

    # note(join("\n", @content));

    is($content[0], "use v5.14.1;\n", "use version (not updated)");
}

# TODO more tests, especially a package without includes

done_testing;
