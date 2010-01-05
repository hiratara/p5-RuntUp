package RuntUp;
use Any::Moose;
use File::Spec;
use YAML::Syck;
use File::HomeDir qw/my_home/;
use File::Spec::Functions;
use RuntUp::AllUploaders;
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

has config => (
	is  => 'rw',
	isa => 'Ref',
	default => sub { {} },
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


sub load_config{
	my $self = shift;

	my $path = catfile my_home, '.runtup';

	$self->config( LoadFile( $path ) );
}


sub upload{
	my $self = shift;

	my $setting = $self->config->{servers}{ $self->server };

	# load Uploader
	my $up = ('RuntUp::Uploader::' . $setting->{uploader})->new( $setting );

	exists $setting->{local_prefix} or die;
	my $local_regexp = qr(^$setting->{local_prefix});

	exists $setting->{server_prefix} or die;
	my $server_path = $setting->{server_prefix};

	foreach ( @{ $self->paths } ) {
		my $abs = File::Spec->rel2abs($_);
		(my $path = $abs) =~ s/$local_regexp// or do {
			warn "Ignored $abs\n";
			next;
		};
		# TODO: Don't use catfile 
		#       (The host OS may not be the client OS.)
		$up->upload( $abs, catfile( $server_path, $path ) );
	}

}


sub run {
	my $self = shift;

	$self->load_config;
	$self->upload;
}


1;
__END__

=head1 NAME

RuntUp - Just a file uploader.

=head1 SYNOPSIS

  $ runtup 'SERVERSETTING' /path/to/file

=head1 DESCRIPTION

RuntUp is a file uploader for private use.

It uploads files from the client to the remote, 
where the client and the remote should have same structure of directories.

You can select one of the upload methods, SCP, FTP, and so on.

Show sample.runtup and copy it to ~/.runtup .

=head1 AUTHOR

hiratara E<lt>hiratara@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
