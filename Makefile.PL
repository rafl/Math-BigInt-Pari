use ExtUtils::MakeMaker qw( WriteMakefile );

WriteMakefile(
    NAME => 'Math::BigInt::Pari',
    DISTNAME => 'Math-BigInt-Pari',
    VERSION_FROM => 'lib/Math/BigInt/Pari.pm',
    AUTHOR => 
      'Benjamin Trott <ben@rhumba.pair.com>, Tels <http://bloodgate.com>',
    ABSTRACT => 'Use Math::Pari for Math::BigInt routines',
    PREREQ_PM => {
        'Math::BigInt' => '1.55',
        'Math::BigFloat' => '1.30',
        'Math::Pari' => '2.001804',
    },
);
