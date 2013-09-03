package Perl::Rewrite::Rule::UseCarp;

use Moose;

extends 'Perl::Rewrite::Rule';

with 'Perl::Rewrite::Role::Iterator::Statement';

use Carp;

sub api_version {
    return 1;
}

sub _warn_to_carp {
    my ($self, $stmt, $token) = @_;

    # TODO - option for checking newline

    if ($token->content eq 'warn') {
	$token->set_content('carp');

	# TODO - log change

	return $token;
    } else {	
	return;
    }
}

sub _die_to_croak {
    my ($self, $stmt, $token) = @_;

    # TODO - option for checking newline

    if ($token->content eq 'die') {
	$token->set_content('croak');

	# TODO - log change

	return $token;
    } else {	
	return;
    }
}

sub apply {
    my ($self, $ppi) = @_;

    my $carps = $self->search_statements_for_symbol(
	$ppi,
	'warn',
	$self->can("_warn_to_carp")
    );

    my $croaks = $self->search_statements_for_symbol(
	$ppi,
	'die',
	$self->can("_die_to_croak")
    );

    if ($carps + $croaks) {

	# TODO - ensure that we use Carp etc.

    }

}
