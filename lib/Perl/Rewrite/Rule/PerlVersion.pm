package Perl::Rewrite::Rule::PerlVersion;

use Moo;

extends 'Perl::Rewrite::Rule';

use version 0.77;

use Carp;
use Type::Tiny;
use Types::Standard qw/ Bool /;

my $VERSION_TYPE = Type::Tiny->new(
    name => "Version",
    constraint => sub { (defined $_) && $_->isa("version") },
);

has 'version' => (
  is  => 'ro',
  isa => $VERSION_TYPE,
);

has 'type' => (
  is  => 'ro',
  default => sub { return 'use'; }, # use or require
);

has 'extra_newline' => (
  is  => 'ro',
    isa => Types::Standard::Bool,
    default => sub { return 0; },
);

sub api_version {
    return 1;
}

sub apply {
    my ($self, $ppi) = @_;

    my $includes = $ppi->find("PPI::Statement::Include");
    my $version;
    my $top;

    if ($includes) {

        $top = $includes->[0];

        foreach my $include ( @{$includes} ) {

            next unless ( $include->type =~ /^(require|use)$/ );

            next unless ( $include->version );

            $version = $include;

	    # Note - if there are multiple versions, they will be
	    # ignored.

        }

    } else {

        # If we cannot find any includes, then we look for the first statement

        $top = $ppi->find_first("PPI::Statement");

    }

    if ( $version
        && version->declare( $version->version ) < $self->version )
    {

        # Change require to use

        if ( $version->type ne $self->type ) {

            my $type = $version->find_first("PPI::Token::Word");

            unless ( $type->content eq $version->type ) {

                croak "Unexpected content at line " . $version->line_number;

            }

            $type->set_content( $self->type );

        }

        my $number = $version->find_first("PPI::Token::Number");

        # Note that the PPI replace method is not yet implemented

        $number->insert_before(
	    PPI::Token::Number::Version->new( $self->version->stringify ) );
        $number->delete;

	# TODO log

	return $version;

    } elsif ( !$version ) {

        my $stmt = PPI::Statement::Include->new;

	# TODO Perl::Rewrite::Util::Version to create a use version line

        $stmt->add_element( PPI::Token::Word->new( $self->type ) );
        $stmt->add_element( PPI::Token::Whitespace->new(' ') );
        $stmt->add_element(PPI::Token::Number::Version->new( $self->version->stringify ) );
        $stmt->add_element( PPI::Token::Structure->new(';') );
        $stmt->add_element( PPI::Token::Whitespace->new("\n") )
            if ($self->extra_newline);

        if ( $top->isa("PPI::Statement::Package") ) {

            $top->insert_after($stmt);
            $top->insert_after( PPI::Token::Whitespace->new("\n") );

        } else {

            $stmt->add_element( PPI::Token::Whitespace->new("\n") );
            $top->insert_before($stmt);

        }

	return $stmt;

	# TODO log

    }

}

1;
