#!/usr/bin/perl -w

use Test::More;
use strict;

my $tests;

BEGIN
   {
   $tests = 1;
   plan tests => $tests;
   chdir 't' if -d 't';
   use lib '../lib';
   };

SKIP:
  {
  skip("Test::Pod::Coverage 1.08 required for testing POD coverage", $tests)
    unless do {
    eval "use Test::Pod::Coverage 1.08";
    $@ ? 0 : 1;
    };

  my $trustme = { 
    trustme => [ 'isa', 'api_version' ], 
    coverage_class => 'Pod::Coverage::CountParents',
    };
  pod_coverage_ok( 'Math::BigInt::Pari', $trustme, "All our Math::BigInt::Pari are covered" );

  }

