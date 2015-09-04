use Test::Most;
use Test::DZil;
use Path::Class;

use Test::File::ShareDir -share =>
    { -dist => { 'Dist-Zilla-PluginBundle-MyCompany-ATS' => 'share' }, };

my $tzil = Minter->_new_from_profile(
    [ 'MyCompany::ATS'   => 'default' ],
    { name               => 'DZT-Minty', },
    { global_config_root => dir('corpus/global')->absolute },
);

$tzil->mint_dist;

my $mint_root = $tzil->tempdir->subdir('mint');
foreach my $file (qw(.gitignore dist.ini)) {
    ok( -e $mint_root->file($file)->absolute, "Created file $file" )
        or diag( $mint_root->file($file) . " does not exist" );
}

foreach my $dir (qw(t bin xt lib)) {
    ok( -d $mint_root->subdir($dir)->absolute, "Created dir $dir" )
        or diag( $mint_root->subdir($dir) . " does not exist" );
}

my $distini = $tzil->slurp_file('mint/dist.ini');
like( $distini, qr/\@MyCompany::ATS/, "Using the MyCompany::ATS plugin bundle" );

done_testing;
