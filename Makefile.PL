# $Id: Makefile.PL,v 1.5 2001/08/06 06:33:01 btrott Exp $

use ExtUtils::MakeMaker qw( WriteMakefile );

WriteMakefile(
    NAME => 'Math::BigInt::Pari',
    DISTNAME => 'Math-BigInt-Pari',
    VERSION_FROM => 'lib/Math/BigInt/Pari.pm',
    AUTHOR => 'Benjamin Trott <ben@rhumba.pair.com>',
    ABSTRACT => 'Use Math::Pari for Math::BigInt routines',
    PREREQ_PM => {
        'Math::BigInt' => '1.40',
        'Math::BigFloat' => '1.20',
        'Math::Pari' => '2.001804',
    },
);
