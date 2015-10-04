use 5.00503;
use ExtUtils::MakeMaker;

use lib qw( ./lib );


# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Text::CSV::Encoded',
    'VERSION_FROM'	=> 'lib/Text/CSV/Encoded.pm', # finds $VERSION
    'PREREQ_PM' => {
        'IO::Handle'    => 0,
        'Test::More'    => 0,
        'Test::Harness' => 0,
        'Text::CSV'     => 1.31,
    },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/Text/CSV/Encoded.pm', # retrieve abstract from module
       AUTHOR     => 'Makamaka Hannyaharamitu, E<lt>makamaka[at]cpan.orgE<gt>') : ()),

    ( $ExtUtils::MakeMaker::VERSION >= 6.3002 ? ('LICENSE' => 'perl', ) : () ),

    ( $ExtUtils::MakeMaker::VERSION >= 6.46 ? (
        'META_MERGE' => {
            resources => {
                repository => 'http://github.com/makamaka/Text-CSV-Encoded',
            },
        } ) : ()
    ),
);
