package Perl::Rewrite::Util::Include;

use strict;
use warnings;

use Exporter qw/ import /;

use PPI;

use Perl::Rewrite::Util::Whitespace;

our @EXPORT    = qw/ include_line /;
our @EXPORT_OK = @EXPORT;

sub include_line {
    my ($module, $type) = @_;
    $type //= 'use'; # use, require

    # TODO: support for extends/with

    my $stmt = PPI::Statement::Include->new;

    $stmt->add_element( PPI::Token::Word->new($type) );
    $stmt->add_element( space );

    $stmt->add_element( PPI::Token::Word->new( $module ) );
    $stmt->add_element( PPI::Token::Structure->new(';') );

    return $stmt;
};

1;
