package RuntUp;
use Any::Moose;
use File::Spec;
use YAML::Syck;
use File::HomeDir qw/my_home/;
use File::Spec::Functions;
use RuntUp::AllUploaders;
our $VERSION = '0.01';

with any_moose('X::Getopt');

has reverse => (
	is  => 'ro',
	isa => 'Bool',
);

has server => (
	is  => 'ro',
	isa => 'Str',
	required => 1,
	metaclass => "NoGetopt",
);

has paths => (
	is  => 'ro',
	isa => 'ArrayRef[Str]',
	required => 1,
	metaclass => "NoGetopt",
);

has config => (
	is  => 'rw',
	isa => 'Ref',
	default => sub { {} },
	metaclass => "NoGetopt",
);


around BUILDARGS => sub {
	my $meth  = shift;
	my $class = shift;

	my $params = $class->$meth(@_);

	my @argv = @{$params->{extra_argv}};
	$params->{server} = shift @argv;
	$params->{paths} = \@argv;

	return $params;
};


__PACKAGE__->meta->make_immutable;
no  Any::Moose;


sub dialog($) {
	my ($message) = @_;

	print $message;
	my $ans = do { local $| = 1; <STDIN> };
	unless (defined $ans) {
		print "\n";
		$ans = "";
	}

	chomp $ans;
	$ans;
}

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
	my $meth = $self->reverse ? 'download' : 'upload';

	# XXX Should I make a separate parser?
	my @prefixes;
	if( exists $setting->{prefixes} ){
		@prefixes = @{ $setting->{prefixes} };
	} else {
		my %prefix = map {
			exists $setting->{$_} ? ( $_ => $setting->{$_} ) : ()
		} qw/local_prefix server_prefix/;
		push @prefixes, \%prefix;
	}

	foreach ( @{ $self->paths } ) {
		my $abs = File::Spec->rel2abs($_);

		my @from_to;
		for my $s ( @prefixes ) {
			exists $s->{local_prefix} or die;
			my $local_regexp = qr(^$s->{local_prefix});

			exists $s->{server_prefix} or die;
			my $server_path = $s->{server_prefix};

			(my $path = $abs) =~ s/$local_regexp// or next;

			# TODO: Don't use catfile 
			#       (The host OS may not be the client OS.)
			@from_to = ( $abs, catfile( $server_path, $path ) );
			last;
		}

		if( @from_to ){
			if ($self->reverse and -e $from_to[0]) {
				next if dialog "Override $from_to[0]? [Yn]: " ne 'Y';
			}
			$up->$meth( @from_to );
		} else {
			warn "Ignored $abs\n";
		}
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
