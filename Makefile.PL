#!/usr/bin/env perl
use strict;
use warnings;
use 5.010001;

use ExtUtils::MakeMaker;
WriteMakefile(
  NAME           => 'Lingua::Foma',
  VERSION_FROM   => 'lib/Lingua/Foma.pm',
  PREREQ_PM      => {
    'Test::More' => 0,
    'File::Temp' => 0
  },
  ABSTRACT       => 'XS Bindings to the Foma Finite State Morphology Toolkit',
  AUTHOR         => 'Nils Diewald',
  LIBS           => ['-lz'],
  DEFINE         => '',
  INC            => '-I.',
  OBJECT         => '$(O_FILES)',
  CCFLAGS        => '-Wno-gnu',
  LICENSE        => 'gpl_2',
  META_MERGE => {
    requires => { perl => '5.010001' },
    resources => {
      license    => 'https://www.gnu.org/licenses/gpl-2.0.txt',
      repository => 'https://github.com/Akron/Lingua-Foma'
    }
  }
);
