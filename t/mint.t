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
my $found_files;
for my $child ( $tzil->tempdir->subdir('mint')->children ) {
    diag $child;
    $found_files++ if !-d $child;
}
ok( $found_files, "Found at least one file in the mint" );
diag "Library paths: ";
for my $libpath (@INC) {
    diag $libpath;
}

my $distdir =  dir(File::ShareDir::dist_dir( $Dist::Zilla::MintingProfile::MyCompany::ATS::DIST)  )->absolute;

diag "Dist-Dir:", $distdir;

system('find', $distdir );
done_testing;
