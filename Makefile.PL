use ExtUtils::MakeMaker qw( WriteMakefile );

sub MY::metafile {
  package MY;
  my $self = shift;
  if (!eval { require YAML; 1 })
  {
    warn ("YAML not installed, cannot override metafile"); return $self->SUPER::metafile_target(@_);
  };

  my $node = new YAML::Node {};

  $node->{name}                 = $self->{DISTNAME};
  $node->{version}              = $self->{VERSION};
  $node->{version_from}         = $self->{VERSION_FROM};
  $node->{license}              = 'perl';
  $node->{distribution_type}    = 'module';
  $node->{generated_by}         = "$self->{DISTNAME} version $self->{VERSION}";
  $node->{installdirs}          = 'site';
  $node->{requires}             = $self->{PREREQ_PM};

  my $dump = YAML::Dump( $node );

  $dump =~ s/^(.*)$/\t\$(NOECHO) \$(ECHO) "$1" >>META.yml/gm;
  $dump =~ s/>>META\.yml/>META.yml/;

  return "metafile:\n$dump";
}

WriteMakefile(
    NAME		=> 'Math::BigInt::Pari',
    DISTNAME		=> 'Math-BigInt-Pari',
    VERSION_FROM	=> 'lib/Math/BigInt/Pari.pm',
    AUTHOR		=> 
      'Benjamin Trott <ben@rhumba.pair.com>, Tels <http://bloodgate.com>',
    ABSTRACT		=> 'Use Math::Pari for Math::BigInt routines',
    PREREQ_PM		=> {
        'Math::BigInt' => '1.74',
        'Math::BigFloat' => '1.48',
        'Math::Pari' => '2.010602',
    },
);
