#!/usr/bin/perl -w

use strict;
use Test;

BEGIN 
  {
  $| = 1;
  # chdir 't' if -d 't';
  unshift @INC, '../lib'; # for running manually
  plan tests => 56;
  }

# testing of Math::BigInt::Pari, primarily for interface/api and not for the
# math functionality

use Math::BigInt::Pari;

my $C = 'Math::BigInt::Pari';	# pass classname to sub's

# _new and _str
my $x = _new($C,\"123"); my $y = _new($C,\"321");
ok (ref($x),'Math::Pari'); ok (${_str($C,$x)},123); ok (${_str($C,$y)},321);

# _add, _sub, _mul, _div

ok (${_str($C,_add($C,$x,$y))},444);
ok (${_str($C,_sub($C,$x,$y))},123);
ok (${_str($C,_mul($C,$x,$y))},39483);
ok (${_str($C,_div($C,$x,$y))},123);

ok (${_str($C,_mul($C,$x,$y))},39483);
ok (${_str($C,$x)},39483);
ok (${_str($C,$y)},321);
my $z = _new($C,\"2");
ok (${_str($C,_add($C,$x,$z))},39485);
my ($re,$rr) = _div($C,$x,$y);

ok (${_str($C,$re)},123); ok (${_str($C,$rr)},2);

# is_zero, _is_one, _one, _zero
ok (_is_zero($C,$x),0);
ok (_is_one($C,$x),0);

ok (_is_one($C,_one()),1); ok (_is_one($C,_zero()),0);
ok (_is_zero($C,_zero()),1); ok (_is_zero($C,_one()),0);

# is_odd, is_even
ok (_is_odd($C,_one()),1); ok (_is_odd($C,_zero()),0);
ok (_is_even($C,_one()),0); ok (_is_even($C,_zero()),1);

# _digit
$x = _new($C,\"123456789");
ok (_digit($C,$x,0),9);
ok (_digit($C,$x,1),8);
ok (_digit($C,$x,2),7);
ok (_digit($C,$x,-1),1);
ok (_digit($C,$x,-2),2);
ok (_digit($C,$x,-3),3);

# _acmp
$x = _new($C,\"123456789");
$y = _new($C,\"987654321");
ok (_acmp($C,$x,$y),-1);
ok (_acmp($C,$y,$x),1);
ok (_acmp($C,$x,$x),0);
ok (_acmp($C,$y,$y),0);

# _div
$x = _new($C,\"3333"); $y = _new($C,\"1111");
ok (${_str($C, scalar _div($C,$x,$y))},3);
$x = _new($C,\"33333"); $y = _new($C,\"1111"); ($x,$y) = _div($C,$x,$y);
ok (${_str($C,$x)},30); ok (${_str($C,$y)},3);
$x = _new($C,\"123"); $y = _new($C,\"1111"); 
($x,$y) = _div($C,$x,$y); ok (${_str($C,$x)},0); ok (${_str($C,$y)},123);

# _and, _xor, _or
$x = _new($C,\"7"); $y = _new($C,\"5"); ok (${_str($C,_and($C,$x,$y))},5);
$x = _new($C,\"6"); $y = _new($C,\"1"); ok (${_str($C,_or($C,$x,$y))},7);
$x = _new($C,\"9"); $y = _new($C,\"6"); ok (${_str($C,_xor($C,$x,$y))},15);

my $r;
# to check bit-counts
foreach (qw/
  7:7:823543 
  31:7:27512614111 
  2:10:1024
  32:4:1048576
  64:8:281474976710656
  128:16:5192296858534827628530496329220096
  255:32:102161150204658159326162171757797299165741800222807601117528975009918212890625
  1024:64:4562440617622195218641171605700291324893228507248559930579192517899275167208677386505912811317371399778642309573594407310688704721375437998252661319722214188251994674360264950082874192246603776 /)
  {
  my ($x,$y,$r) = split /:/;
  $x = _new($C,\$x); $y = _new($C,\$y);
  ok (${_str($C,_pow($C,$x,$y))},$r);
  }

# _num
$x = _new($C,\"12345"); $x = _num($C,$x); ok (ref($x)||'',''); ok ($x,12345);

# _copy
$x = _new($C,\"123"); $y = _copy($C,$x); $z = _new($C,\"321");
_add($C,$x,$z);
ok (${_str($C,$x)},'444');
ok (${_str($C,$y)},'123');

# _gcd
$x = _new($C,\"128"); $y = _new($C,\'96'); $x = _gcd($C,$x,$y);
ok (${_str($C,$x)},'32');

# should not happen:
# $x = _new($C,\"-2"); $y = _new($C,\"4"); ok (_acmp($C,$x,$y),-1);

# _check
$x = _new($C,\"123456789");
ok (_check($C,$x),0);
ok (_check($C,123),'123 is not a reference to Math::Pari');

# done

1;

