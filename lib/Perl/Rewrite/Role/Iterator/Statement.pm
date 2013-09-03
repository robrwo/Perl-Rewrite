package Perl::Rewrite::Role::Iterator::Statement;

use Moose::Role;

sub search_statements_for_symbol {
    my ($self, $ppi, $symbol, $callback) = @_;

    my $statements = $ppi->find("PPI::Statement");
    my @changes;

    foreach my $stmt (@{$statements}) {

	my $token = $stmt->first_token;
	if ($token->isa("PPI::Token::Word") && $token->content eq $symbol) {

	    if (my $change = $self->$callback($stmt, $token)) {
		push @changes, $change;
	    }

	} else {

	   my $last;
	   while ($token = $token->snext_sibling) {

	       if ($last && $last->isa("PPI::Token::Operator") &&
		   $token->isa("PPI::Token::Word") &&
		   $token->content eq $symbol) {

		   if (my $change = $self->$callback($stmt, $token)) {
		       push @changes, $change;
		   }

		   last;

	       }
		   
	      
	       $last = $token;
	   }

	}

    }

    return @changes;
}

1;
