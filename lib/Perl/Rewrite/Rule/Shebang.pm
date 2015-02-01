package Perl::Rewrite::Rule::Shebang;

use Moo;
use Types::Standard -types;

extends 'Perl::Rewrite::Rule';
with 'Perl::Rewrite::Role::API::v1';

has 'shebang' => (
    is      => 'ro',
    isa     => Types::Standard::Str,
    default => sub { return '/usr/bin/env perl'; },
);

sub apply {
    my ( $self, $ppi ) = @_;

    my $shebang;

    if ( my $comment = $ppi->find_first("PPI::Token::Comment") ) {
        $shebang = $comment
          if ( ( $comment->line_number == 1 )
            && ( substr( $comment->content, 0, 2 ) eq '#!' ) );
    }

    if ($shebang) {

        # TODO log update

        $shebang->set_content( '#!' . $self->shebang . "\n" );

    }
    else {

        # TODO log adding

        $shebang = PPI::Token::Comment->new( '#!' . $self->shebang . "\n" );

        $ppi->top->first_token()->insert_before($shebang);

    }

    return $shebang;
}

1;
