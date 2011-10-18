package RuntUp::AllUploaders;
use strict;
use warnings;
our $VERSION = 0.01;


package RuntUp::Uploader::SCP;
use Net::OpenSSH;
use Any::Moose;

has [qw/user host/] => ( is => 'ro', isa => 'Str', required => 1 );
has ssh => ( is => 'ro', isa => 'Net::OpenSSH', lazy_build => 1);

__PACKAGE__->meta->make_immutable;
no  Any::Moose;

sub _build_ssh {
	my $self = shift;

	my $ssh = Net::OpenSSH->new( $self->host, user => $self->user );
	$ssh->error and die $ssh->error;

	return $ssh;
}

sub upload{
	my $self = shift;
	my ( $local, $remote ) = @_;
	my $ssh = $self->ssh;

	$ssh->scp_put( {copy_attrs => 1}, $local, $remote ) or die $ssh->error;
}

sub download {
	my ($self, $local, $remote) = @_;

	$self->ssh->scp_get(
		{copy_attrs => 1}, $remote => $local
	) or die $self->ssh->error;
}


package RuntUp::Uploader::FTP;
use Any::Moose;
use Net::FTP;

has [qw/user host pass/] => ( is => 'ro', isa => 'Str', required => 1 );
has ftp => (is => 'rw', isa => 'Net::FTP', lazy_build => 1);

__PACKAGE__->meta->make_immutable;
no  Any::Moose;

sub _build_ftp {
	my $self = shift;

	my $ftp = Net::FTP->new( $self->host ) or die;
	$ftp->login( $self->user, $self->pass ) or die $ftp->message;
	$ftp->binary;

	return $ftp;
}

sub upload{
	my $self = shift;
	my ( $local, $remote ) = @_;

	! -f $local and do { warn "Support only file: ", $local; return; };
	my $executable = -x $local;

	# TODO: The server may not be same OS with the client.
	my ( $vol, $dir, $file ) = File::Spec->splitpath( $remote );
	$self->ftp->mkdir( $dir, 1 );
	$self->ftp->cwd( $dir );
	my $result = $self->ftp->put( $local );
	$self->ftp->site( qw(CHMOD 755), $result ) if $executable;

	print "put: ", $result, "\n";
}

sub download {
	my ($self, $local, $remote) = @_;

	my ($remote_info) = $self->ftp->dir($remote);
	my ($is_executable) = $remote_info =~ /^.{9}(x)/i;

	my $result = $self->ftp->get($remote, $local);
	chmod 0755, $result if $is_executable;

	print "get: ", $result, "\n";
}


1;
