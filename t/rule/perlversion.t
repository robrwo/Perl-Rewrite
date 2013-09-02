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

# TODO actual tests

done_testing;
