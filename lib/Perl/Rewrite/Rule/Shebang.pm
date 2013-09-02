package Perl::Rewrite::Rule::Shebang;

use Moose;

has 'shebang' => (
    is      => 'ro',
    isa     => 'Str',
    default => sub { return '/usr/bin/env perl'; },
);

sub api_version {
    return 1;
}

sub rewrite {
    my ($self, $ppi) = @_;

    my $shebang;

    if (my $comment = $ppi->find_first("PPI::Token::Comment")) {

	$shebang = $comment 
	    if (($comment->line_number == 1) &&
		(substr($comment->content, 0, 2) eq '#!'));

    }

    if ($shebang) {

	$shebang->set_content( '#!' . $self->shebang . "\n" );

    } else {

	$shebang = PPI::Token::Comment->new( '#!' . $self->shebang . "\n" );

	$ppi->top->first_token()->insert_before($shebang);

    }

}

1;
