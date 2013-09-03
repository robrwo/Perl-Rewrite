package Perl::Rewrite::Rule::PerlVersion;

use Moose;

extends 'Perl::Rewrite::Rule';

use version 0.77;

use Carp;

has 'version' => (
  is  => 'ro',
  isa => 'version',
);

has 'type' => (
  is  => 'ro',
  isa => 'Str',
  default => sub { return 'use'; }, # use or require
);

has 'extra_newline' => (
  is  => 'ro',
  isa => 'Bool',
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
        $stmt->add_element( PPI::Token::Whitespace->new("\n") );
        $stmt->add_element( PPI::Token::Whitespace->new("\n") ) if ($self->extra_newline);

	# FIXME - this will insert version before "package" when there
	# are no includes!

        if ( $top->isa("PPI::Token::Whitespace") ) {

            $top->insert_before($stmt);

        } else {

            $top->insert_before($stmt);

        }

	return $stmt;

	# TODO log

    }

}

1;
