# $Id: Makefile.PL,v 1.6 2001/09/03 22:41:55 btrott Exp $

use ExtUtils::MakeMaker qw( WriteMakefile );

WriteMakefile(
    NAME => 'Math::BigInt::Pari',
    DISTNAME => 'Math-BigInt-Pari',
    VERSION_FROM => 'lib/Math/BigInt/Pari.pm',
    AUTHOR => 'Benjamin Trott <ben@rhumba.pair.com>',
    ABSTRACT => 'Use Math::Pari for Math::BigInt routines',
    PREREQ_PM => {
        'Math::BigInt' => '1.44',
        'Math::BigFloat' => '1.23',
        'Math::Pari' => '2.001804',
    },
);
