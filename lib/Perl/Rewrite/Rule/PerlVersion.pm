package Perl::Rewrite::Rule::PerlVersion;

use Moo;

extends 'Perl::Rewrite::Rule';
with 'Perl::Rewrite::Role::API::v1';

use version 0.77;

use Carp;
use Type::Tiny;
use Types::Standard -types;

use Perl::Rewrite::Util::Include;
use Perl::Rewrite::Util::Whitespace;

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
    default => sub { return 'use'; }, # TODO use or require
);

has 'extra_newline' => (
    is  => 'ro',
    isa => Bool,
    default => 0,
);

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

        my $stmt = include_line(
            PPI::Token::Number::Version->new( $self->version->stringify ),
            $self->type,
        );

        $stmt->add_element( newline ) if ($self->extra_newline);

        if ( $top->isa("PPI::Statement::Package") ) {

            $top->insert_after($stmt);
            $top->insert_after( newline );

        } else {

            $stmt->add_element( newline );
            $top->insert_before($stmt);

        }

	return $stmt;

	# TODO log

    }

}

1;
