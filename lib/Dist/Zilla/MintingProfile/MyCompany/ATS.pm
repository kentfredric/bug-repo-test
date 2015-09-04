package Dist::Zilla::MintingProfile::MyCompany::ATS;

our $VERSION = '0.002'; # VERSION

# ABSTRACT: the MyCompany default DZ profile
use Moose;
with 'Dist::Zilla::Role::MintingProfile';

use namespace::autoclean;

# need to use ::Tarball because zipped up during Jenkins build
use File::ShareDir qw( dist_dir );

use Path::Class;

# File::ShareDir::Tarball only supports dist level shared dirs
our $DIST = 'Dist-Zilla-PluginBundle-MyCompany-ATS';

sub profile_dir {
    my ($self, $profile_name) = @_;

    my $profile_dir = dir( dist_dir($DIST) )->subdir( 'profiles', $profile_name );

    return $profile_dir if -d $profile_dir;

    confess "Can't find profile $profile_name via $self (checked '$profile_dir')";
}

__PACKAGE__->meta->make_immutable;

__END__

=pod

=head1 NAME

Dist::Zilla::MintingProfile::MyCompany::ATS - MyCompany ATS team's default Dzil mint

=head1 SYNOPSIS

    dzil new -P MyCompany::ATS Foo::Bar

=head1 DESCRIPTION

Mints a new DZ profile that includes:

=over

=item * Initial dist.ini that includes our standard plugin bundle

=item * Minimal starter module

=item * C<.gitignore>

=item * Basic directory skeleton

=back

=head1 SEE ALSO

L<Dist::Zilla::PluginBundle::MyCompany::ATS>,

