package Perl::Rewrite::Util::Whitespace;

use strict;
use warnings;

use Exporter qw/ import /;

our @EXPORT    = qw/ newline space /;
our @EXPORT_OK = @EXPORT;

sub newline {
    my $count = shift // 1;
    PPI::Token::Whitespace->new( "\n" x $count );
}

sub space {
    my $count = shift // 1;
    PPI::Token::Whitespace->new( " " x $count );
}

1;
