use Test::Most;
use Test::DZil;

#use Carp::Always;

use Dist::Zilla::PluginBundle::MyCompany::ATS;

lives_ok { test_build(); } "Built a test distro";

done_testing;

sub test_build {

    # configure a test distro
    my $tzil = Builder->from_config(
        { dist_root => 'corpus/DZT' },

        {   add_files => {
                'source/dist.ini' => simple_ini(
                    { version => undef, },

                    [ 'GatherDir' => { prune_directory => 'cpanm' } ], # exclude this on Jenkins!

                    # include our plugin bundle, but exclude
                    # Git::GatherDir because not yet a repo
                    [ '@MyCompany::ATS' => { '-remove' => 'Git::GatherDir' } ],
                ),
            },
        },
    );

    # the git plugins require a git repo
    init_git( $tzil->tempdir->subdir('source') );

    # and build it
    $tzil->build();

    my $contents = $tzil->slurp_file('build/lib/DZT/Sample.pm');

    like( $contents, qr{package DZT::Sample}, "found module", );

}

sub init_git {
    my $dir = shift;
    system( "git", "init", "-q", $dir );
}

