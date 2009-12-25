package RuntUp::AllUploaders;
use strict;
use warnings;
our $VERSION = 0.01;


package RuntUp::Uploader::SCP;
use Any::Moose;

has [qw/user host/] => ( is => 'ro', isa => 'Str', required => 1 );

__PACKAGE__->meta->make_immutable;
no  Any::Moose;

sub upload{
	my $self = shift;
	my ( $local, $remote ) = @_;
	system(
		'scp', '-p',
		$local,
		sprintf( 
			'%s@%s:%s', 
			$self->user, $self->host, $remote
		),
	);
}



1;
