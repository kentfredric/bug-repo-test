package Dist::Zilla::PluginBundle::MyCompany::ATS;

our $VERSION = '0.002';

# ABSTRACT: Build dists like MyCompany ATS team

use Moose;

use Dist::Zilla 4.3; # first version with authordeps

with 'Dist::Zilla::Role::PluginBundle::Easy';

# you can specify config for any of the bundled plugins.
# the option should be the plugin name and the attribute
# separated by a dot
# eg. PruneFiles.filename = dist.ini
with 'Dist::Zilla::Role::PluginBundle::Config::Slicer';

# Remove plugins with '-remove' when using this bundle
with 'Dist::Zilla::Role::PluginBundle::PluginRemover';

use namespace::autoclean;

has installer => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { $_[0]->payload->{installer} || 'ModuleBuildTiny' },
);

sub build_file {
    my $self = shift;
    $self->installer =~ /MakeMaker/ ? 'Makefile.PL' : 'Build.PL';
}

sub configure {
    my $self = shift;

    my @accepts
        = qw( MakeMaker MakeMaker::IncShareDir ModuleBuild ModuleBuildTiny );
    my %accepts = map { $_ => 1 } @accepts;

    unless ( $accepts{ $self->installer } ) {
        die sprintf(
            "Unknown installer: '%s'. "
                . "Acceptable values are MakeMaker, ModuleBuild and ModuleBuildTiny\n",
            $self->installer
        );
    }

    my @dirty_files = ( 'dist.ini', 'Changes', 'META.json', 'README.md',
        $self->build_file );
    my @exclude_release = ('README.md');

    $self->add_plugins(

        ['NameFromDirectory'],

        # Only include files present in Git Repo
        [   'Git::GatherDir',

            # Make the git repo installable
            {   exclude_filename => [
                    $self->build_file, 'META.json',
                    'LICENSE',         @exclude_release
                ]
            }
        ],
        [   'CopyFilesFromBuild',
            { copy => [ 'META.json', 'LICENSE', $self->build_file ] }
        ],

        ['VersionFromModule'],

        [ 'Git::Check', { allow_dirty => \@dirty_files } ],

        # Set no_index to sensible directories
        [ 'MetaNoIndex', { directory => [qw( t xt inc share eg examples )] } ],

        # cpanfile -> META.json
        ['Prereqs::FromCPANfile'],
        [ $self->installer ],
        ['MetaJSON'],

        [   'Prereqs',
            {   -phase => 'develop',
                'Dist::Zilla::PluginBundle::MyCompany::ATS' =>
                    Dist::Zilla::PluginBundle::MyCompany::ATS->VERSION
            }
        ],

        # standard stuff
        ['PodSyntaxTests'],
        ['MetaYAML'],
        ['License'],
        ['RunExtraTests'],
        [ 'ExecDir',  { dir => 'script' } ],
        [ 'ShareDir', { dir => 'share' } ],
        ['Manifest'],
        ['ManifestSkip'],

        # Exclude these files from the build
        [ PruneFiles => { filename => 'dist.ini' } ],

        # Do not release our private distros to CPAN
        ['FakeRelease'],

        ['OurPkgVersion'],
        ['Test::ChangesHasContent'],

    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Dist::Zilla::PluginBundle::MyCompany::ATS - mints and builds a Dist::Zilla based project with ATS team defaults

=head1 USAGE

    # Install
    cpanm Dist::Zilla::PluginBundle::MyCompany::ATS

    # first time only, setup dzil
    dzil setup

    # Start a new DZ based project
    dzil new -P MyCompany::ATS Foo::Bar

    # Install the dependencies
    dzil authordeps --missing | cpanm
    dzil listdeps --missing | cpanm

    dzil test

    # To release a new version:

    # manually update version number in Foo::Bar
    # (other # VERSION tags automatically updated)

    # then:
    dzil build
    dzil test
    dzil clean

    git add META.json lib/Foo/Bar.pm
    git commit -m 'new version number'
    git push

=head1 SYNOPSIS

    # in dist.ini:
    name = Bean-ATS
    author = MyCompany Technology <apisupport@broadbean.com>
    license = None
    copyright_holder = MyCompany Technology
    [@MyCompany::ATS]

=head1 DESCRIPTION

L<Dist::Zilla> bundle for ATS Integration projects. Based on L<Dist::Milla> but
with various Github/CPAN aspects removed (and hopefully without Milla's
dependency on perl 5.12)

This also makes your distribution installable from the git repo, which is handy
for deploying patched versions of modules, e.g. via

    cpanm git://github.com/me/my-lovely-distribution@my-patched-branch

=head2 MINTING FEATURES

The Minting Profile needs work, but currently does the following:

=over

=item Creates dist.ini

=item Adds C<.gitignore>

=item Creates initial empty module

=item Creates C<lib>, C<t>, C<xt>, C<bin>, directories

=back

=head2 BUILDING FEATURES

=over

=item Takes pre-requisites from C<cpanfile>

=item Deployable from repo (makefile and META copied to repo root after build)

=item Automatically updated C<# VERSION> tags

=item Allows C<share> directories

=back

=head1 BEHAVIOUR

In your C<dist.ini>

    [@MyCompany::ATS]

Is the equivalent to:

    ['NameFromDirectory'],
    [ 'Git::GatherDir',
         { exclude_filename => [ 'Build.PL', 'META.json', 'README.md', 'LICENSE' ] }
    ],
    [ 'CopyFilesFromBuild',
         { copy => [ 'META.json', 'LICENSE', 'Build.PL' ] }
    ],
    ['VersionFromModule'],
    [ 'Git::Check', { allow_dirty => [ 'dist.ini', 'Changes', 'META.json', 'README.md' ] } ],
    [ 'MetaNoIndex', { directory => [qw( t xt inc share eg examples )] } ],
    ['Prereqs::FromCPANfile'],
    ['ModuleBuildTiny'],
    ['MetaJSON'],
    [ 'Prereqs',
         {   -phase => 'develop',
             'Dist::Zilla::PluginBundle::MyCompany::ATS' =>
              Dist::Zilla::PluginBundle::MyCompany::ATS->VERSION
         }
    ],
    ['PodSyntaxTests'],
    ['MetaYAML'],
    ['License'],
    ['RunExtraTests'],
    [ 'ExecDir',  { dir => 'script' } ],
    [ 'ShareDir', { dir => 'share' } ],
    ['Manifest'],
    ['ManifestSkip'],
    [ PruneFiles => { filename => 'dist.ini' } ],
    ['FakeRelease'],
    ['OurPkgVersion'],
    ['Test::ChangesHasContent'],

=head1 ARGUMENTS

=head2 installer

Default is C<ModuleBuildTiny>, also supports the dzil plugins for C<MakeMaker>,
C<MakeMaker::IncShareDir>, C<ModuleBuild>.

=head1 CUSTOMISING

Note that L<Dist::Zilla::PluginBundle::MyCompany::ATS> uses both the
L<Dist::Zilla::Role::PluginBundle::Config::Slicer> and
L<Dist::Zilla::Role::PluginBundle::PluginRemover> roles, so can be easily
customised.

=head1 BUILDING THIS PACKAGE

    # Install the dependencies
    dzil authordeps --missing | cpanm
    dzil listdeps --missing | cpanm

    # Build and run the test suite
    dzil test

    # Manually update the version number in main module (and commit)
    # then:
    dzil release

=cut


  # Not using, but might be useful - would need to tag existing repos and ensure
  # increment works as expected

        #       [ 'CopyFilesFromRelease', { match => '\.pm$' } ],
        #       [   'Git::Commit',
        #           {   commit_msg  => '%v',
        #               allow_dirty => \@dirty_files,
        #               allow_dirty_match =>
        #                   '\.pm$',    # .pm files copied back from Release
        #           }
        #       ],
        #        [ 'Git::Tag', { tag_format => '%v', tag_message => '' } ],
        #        [ 'Git::Push', { remotes_must_exist => 0 } ],


    #     # Autoversion this distro using git tags
    #     # The version number is incremented during the release stage.
    #     # You can specify your own version number (eg. for a major release)
    #     # using the V environment variable
    #     qw/
    #         Git::NextVersion
    #     /,


        #         [ 'ReversionOnRelease', { prompt => 1 } ],

# # after ReversionOnRelease for munge_files, before Git::Commit for after_release
#         [ 'NextRelease', { format => '%v  %{yyyy-MM-dd HH:mm:ss VVV}d' } ],


