# $Id: Makefile.PL,v 1.4 2001/07/13 20:37:38 btrott Exp $

use ExtUtils::MakeMaker qw( WriteMakefile );

WriteMakefile(
    NAME => 'Math::BigInt::Pari',
    DISTNAME => 'Math-BigInt-Pari',
    VERSION_FROM => 'lib/Math/BigInt/Pari.pm',
    AUTHOR => 'Benjamin Trott <ben@rhumba.pair.com>',
    ABSTRACT => 'Use Math::Pari for Math::BigInt routines',
    PREREQ_PM => {
        'Math::BigInt' => '1.37',
        'Math::BigFloat' => '1.17',
        'Math::Pari' => '2.001804',
    },
);
