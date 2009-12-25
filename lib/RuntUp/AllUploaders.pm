package RuntUp::AllUploaders;
use strict;
use warnings;
our $VERSION = 0.01;


package RuntUp::Uploader::SCP;
use Net::OpenSSH;
use Any::Moose;

has [qw/user host/] => ( is => 'ro', isa => 'Str', required => 1 );

__PACKAGE__->meta->make_immutable;
no  Any::Moose;

sub upload{
	my $self = shift;
	my ( $local, $remote ) = @_;

	my $ssh = Net::OpenSSH->new( $self->host, user => $self->user );
	$ssh->error and die $ssh->error;

	$ssh->scp_put( {copy_attrs => 1}, $local, $remote ) or die $ssh->error;
}


package RuntUp::Uploader::FTP;
use Any::Moose;
use Net::FTP;

has [qw/user host pass/] => ( is => 'ro', isa => 'Str', required => 1 );
has ftp => (is => 'rw', isa => 'Net::FTP');

__PACKAGE__->meta->make_immutable;
no  Any::Moose;

sub upload{
	my $self = shift;
	my ( $local, $remote ) = @_;

	! -f $local and do { warn "Support only file: ", $local; return; };
	my $executable = -x $local;

	unless( $self->ftp ){
		my $ftp = Net::FTP->new( $self->host ) or die;
		$ftp->login( $self->user, $self->pass ) or die $ftp->message;
		$ftp->binary;
		$self->ftp( $ftp );
	}

	# TODO: The server may not be same OS with the client.
	my ( $vol, $dir, $file ) = File::Spec->splitpath( $remote );
	$self->ftp->mkdir( $dir, 1 );
	$self->ftp->cwd( $dir );
	my $result = $self->ftp->put( $local );
	$self->ftp->site( qw(CHMOD 755), $result ) if $executable;

	print "put: ", $result, "\n";
}


1;
