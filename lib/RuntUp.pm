package RuntUp;
use Any::Moose;
use File::Spec;
our $VERSION = '0.01';


has server => (
	is  => 'ro',
	isa => 'Str',
	required => 1,
);

has paths => (
	is  => 'ro',
	isa => 'ArrayRef[Str]',
	required => 1,
);


around BUILDARGS => sub {
	my $meth  = shift;
	my $class = shift;

	my $server = shift @_;

	return $class->$meth(
		server  => $server,
		paths   => [ @_ ],
	);
};


__PACKAGE__->meta->make_immutable;
no  Any::Moose;


sub run {
	my $self = shift;
	foreach ( @{ $self->paths } ) {
		my $abs = File::Spec->rel2abs($_);
		my ($path) = ( $abs =~ m{/(?:SV[KN]|GIT)_work/some_project/[^/]+(/path/to/.+)$} ) 
			or next;
		system(
			'scp', '-p',
			$abs,
			'user@host:' . $path,
		);
	}
}


1;
__END__

=head1 NAME

RuntUp -

=head1 SYNOPSIS

  use RuntUp;

=head1 DESCRIPTION

RuntUp is

=head1 AUTHOR

hiratara E<lt>hiratara@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
