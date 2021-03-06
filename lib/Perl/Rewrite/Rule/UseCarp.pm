package Perl::Rewrite::Rule::UseCarp;

use Moo;

extends 'Perl::Rewrite::Rule';
with 'Perl::Rewrite::Role::Iterator::Statement';
with 'Perl::Rewrite::Role::API::v1';

use Carp;
use Types::Standard -types;

use Perl::Rewrite::Util::Include;
use Perl::Rewrite::Util::Whitespace;

has 'module' => (
    is      => 'ro',
    isa     => Types::Standard::Str,
    default => sub { return 'Carp'; },
);

has 'use_carp' => (
    is      => 'ro',
    isa     => Types::Standard::Bool,
    default => sub { 1; },
);

has 'carpers' => (
    is      => 'ro',
    isa     => Types::Standard::HashRef [Any],
    default => sub {
        return { map { $_ => undef } qw/ Carp Carp::Clan / };
    },
);

sub _warn_to_carp {
    my ( $self, $stmt, $token ) = @_;

    # TODO - option for checking newline

    if ( $token->content eq 'warn' ) {
        $token->set_content('carp');

        # TODO - log change

        return $token;
    }
    else {
        return;
    }
}

sub _die_to_croak {
    my ( $self, $stmt, $token ) = @_;

    # TODO - option for checking newline

    if ( $token->content eq 'die' ) {
        $token->set_content('croak');

        # TODO - log change

        return $token;
    }
    else {
        return;
    }
}

# TODO - this should be a generic method in a role

# This is messy and needs to be rewritten

sub _change_to_use_carp {
    my ( $self, $ppi ) = @_;

    my $includes = $ppi->find("PPI::Statement::Include") || [];

    my ( $uses_carp, $first );

    foreach my $include ( @{$includes} ) {

        # TODO - handle case of 'require Carp'?

        next unless ( $include->type eq 'use' );

        next if ( $include->version );

        next if ( $include->pragma );

        $uses_carp = $include
          if ( $self->carpers->{ $include->module }
            || $include->module eq $self->module );

        last if ($uses_carp);

    }

    $first //= $includes->[-1] //    # use the last include
      $ppi->find_first("PPI::Statement");

    if ($uses_carp) {

        # If 'use Carp' is present, then we want to see if the
        # functions are explicitly imported.

        if ( my $imports =
            $uses_carp->find_first("PPI::Token::QuoteLike::Words") )
        {

            my %words = map { $_ => 1 } $imports->literal;

            foreach my $word (qw/ carp croak /) {

                unless ( exists $words{$word} ) {

                    $words{$word} = 1;

                    # TODO - log change

                }

            }

            $imports->set_content( join( " ", 'qw/', keys %words, '/' ) );

        }
        else {

            # TODO - handle no other kind of imports,
            # e.g. PPI::Token::Quote::Single or PPI::Structure::List,
            # which can still cause this to fail.

        }

    }
    else {

        if ($first) {

            my $stmt = include_line( $self->module );

            if (   $first->isa("PPI::Statement::Include")
                || $first->isa("PPI::Statement::Package") )
            {
                $first->insert_after($stmt);
                $stmt->insert_before(newline);
            }
            else {
                $first->insert_before($stmt);
                $stmt->insert_after(newline);
            }

            # TODO -log

        }
        else {

            return;

        }

    }

}

sub apply {
    my ( $self, $ppi ) = @_;

    my $carps =
      $self->search_statements_for_symbol( $ppi, 'warn',
        $self->can("_warn_to_carp") );

    my $croaks =
      $self->search_statements_for_symbol( $ppi, 'die',
        $self->can("_die_to_croak") );

    if ( $self->use_carp && ( $carps + $croaks ) ) {

        $self->_change_to_use_carp($ppi);

    }

}

1;
