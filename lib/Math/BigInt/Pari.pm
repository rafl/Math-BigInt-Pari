package Math::BigInt::Pari;

$VERSION = '1.11';

use strict;

use Math::Pari 
 qw(PARI pari2pv gdivent bittest gcmp gcmp0 gcmp1 gcd ifact gpui gmul);

# MBI will call this, so catch it and throw it away
sub import { }
sub api_version() { 1; }        # we are compatible with MBI v1.70 and up

my $zero = PARI(0);	# for _copy
my $one = PARI(1);	# for _inc and _dec
my $two = PARI(2);	# for _is_two
my $ten = PARI(10);	# for _digit

BEGIN
  {
  # str is an alias for _num
  *_str = \&_num;
  }

sub _new {
 # the . '' is because new($2) will give a magical scalar to us, and PARI
 # does not like this at all
 # use Devel::Peek; print Dump($_[1]); 
 PARI($_[1] . '')
 }

sub _from_hex {
    my $h = $_[1];
    $h =~ s/^[+-]//;				# remove sign
    $h = "0x$h" unless $h =~ /^0x/;		# make sure it starts with 0x
    Math::Pari::_hex_cvt($h);
}

sub _from_bin
  {
  my $b = $_[1];
  $b =~ s/^[+-]?0b//;					# remove sign and 0b
  my $l = length($b);					# bits
  $b = '0' x (8-($l % 8)) . $b if ($l % 8) != 0;	# padd left side w/ 0
  my $h = unpack('H*', pack ('B*', $b));		# repack as hex
  Math::Pari::_hex_cvt('0x' . $h);			# can handle it now
  }

sub _as_hex {
    my $v = unpack('H*', _mp2os($_[1]));
    return "0x0" if $v eq '';
    $v =~ s/^0*/0x/;
    $v;
}
sub _as_bin {
    my $v = unpack('B*', _mp2os($_[1]));
    return "0b0" if $v eq '';
    $v =~ s/^0*/0b/;
    $v;
}

sub _mp2os {
    my($p) = @_;
    $p = PARI($p);
    my $base = PARI(1) << PARI(4*8);
    my $res = '';
    while ($p != 0) {
        my $r = $p % $base;
        $p = ($p-$r) / $base;
        my $buf = pack 'V', $r;
        if ($p == 0) {
            $buf = $r >= 16777216 ? $buf :
                   $r >= 65536 ? substr($buf, 0, 3) :
                   $r >= 256   ? substr($buf, 0, 2) :
                                 substr($buf, 0, 1);
        } 
        $res .= $buf;
    }
    scalar reverse $res;
}

sub _zero { PARI(0) }
sub _one  { PARI(1) }
sub _two  { PARI(2) }
sub _ten  { PARI(10) }

sub _copy { $_[1] + $zero; }

sub _num { pari2pv($_[1]) }

sub _add { $_[1] += $_[2] }

sub _sub 
  {
  if ($_[3])
    {
    $_[2] = $_[1] - $_[2]; return $_[2];
    }
  $_[1] -= $_[2];
  }

sub _mul { $_[1] = gmul($_[1],$_[2]) }

sub _div
  {
  if (wantarray)
    {
    my $r = $_[1] % $_[2];
    $_[1] = gdivent($_[1], $_[2]);
    return ($_[1], $r);
    }
  $_[1] = gdivent($_[1], $_[2]);
  }

sub _mod { $_[1] %= $_[2]; }

#sub _inc { ++$_[1]; }	# ++ and -- flotify (bug in Pari?)
#sub _dec { --$_[1]; }
sub _inc { $_[1] += $one; }
sub _dec { $_[1] -= $one; }

sub _and { $_[1] &= $_[2] }

sub _xor { $_[1] ^= $_[2] }

sub _or { $_[1] |= $_[2] }

sub _pow { gpui($_[1], $_[2]) }

sub _gcd { gcd($_[1], $_[2]) }

sub _len { length(pari2pv($_[1])) }	# costly!

sub _zeros 
  {
  return 0 if gcmp0($_[1]);		# 0 has no trailing zeros

  # We seem NOT be able to use a regexp like:
  # my $u = _num(@_); $u =~ /(0+)\z/; return length($1);
  # regexp recursion? stack garbage?

  my $s = pari2pv($_[1]);
  my $i = length($s); my $zeros = 0;
  while (--$i >= 0)
    {
    substr($s,$i,1) eq '0' ? $zeros ++ : last;
    }
  $zeros;
  }  

sub _digit
  {
  # if $n < 0, we need to count from left and thus can't use the other method:
  if ($_[2] < 0)
    {
    return substr(pari2pv($_[1]), -($_[2]+1), 1);
    }
  # else this is faster (except for very short numbers)
  # shift the number right by $n digits, then extract last digit via % 10
  pari2pv ( gdivent($_[1], $ten ** $_[2]) % $ten );

  }

sub _is_zero { gcmp0($_[1]) }

sub _is_one { gcmp1($_[1]) }

sub _is_two { gcmp($_[1], $two) ? 0 : 1 }
sub _is_ten { gcmp($_[1], $ten) ? 0 : 1 }

sub _is_even { bittest($_[1],0) ? 0 : 1 }

sub _is_odd { bittest($_[1],0) ? 1 : 0 }

sub _acmp { gcmp($_[1],$_[2]) }

sub _check {
    my($class,$x) = @_;
    return "$x is not a reference to Math::Pari" if ref($x) ne 'Math::Pari';
    0;
}

sub _sqrt
  {
  # square root (that could be surely faster. Maybe even a native version)
  # "int(sqrt($_[1]))" does unfortunately not work...

  _root($_[0], $_[1], 2);

  }

sub _root
  {
  # n'th root
  # That could be surely faster. Maybe even a native version).
  my ($c,$x,$n) = @_;

  # trial computation by starting with 2,4,8,16 etc until we overstep
  my $step;
  my $trial = _two($c);

  my $two = _two($c);
  my $hundred = _new($c, "128");

  # while still to do more than X steps
  do
    {
    $step = _two();
    while (_acmp($c, _pow($c, _copy($c, $trial), $n), $x) < 0)
      {
      _mul ($c, $step, $two);
      _add ($c, $trial, $step);
      }

    # hit exactly?
    if (_acmp($c, _pow($c, _copy($c, $trial), $n), $x) == 0)
      {
      $x = _copy($c,$trial);		# make copy while preserving ref to $x
      return $x;
      }

    # overstepped, so go back on step
    _sub($c, $trial, $step);
    } while ( _acmp($c, $step, $hundred) > 0);

  # reset step to 2
  $step = _two();

  # add two, because $trial cannot be exactly the result (otherwise we would
  # alrady have found it)
  _add($c, $trial, $step);

  # and now add more and more (2,4,6,8,10 etc)
  while (_acmp($c, _pow($c, _copy($c, $trial), $n), $x) < 0)
    {
    _add ($c, $trial, $step);
    }

  # hit not exactly? (overstepped)
  if (_acmp($c, _pow($c, _copy($c, $trial), $n), $x) > 0)
    {
    _dec($c,$trial);
    }

  # hit not exactly? (overstepped)
  # 80 too small, 81 slightly too big, 82 too big
  if (_acmp($c, _pow($c, _copy($c, $trial), $n), $x) > 0)
    {
    _dec ($c, $trial);
    }

  $x = _copy($c,$trial);		# make copy while preserving ref to $x
  $x;
  }

sub _modpow
  {
  # modulus of power ($x ** $y) % $z
  my ($c,$num,$exp,$mod) = @_;

  # in the trivial case,
  if (gcmp1($mod))
    {
    $num = PARI(0);
    return $num;
    }
  if (gcmp1($num) || gcmp0($num))
    {
    $num = PARI(1);
    return $num;
    }

  my $acc = _copy($c,$num); my $t = _one();

  my $expbin = _as_bin($c,$exp); $expbin =~ s/^0b//;
  my $len = length($expbin);
  while (--$len >= 0)
    {
    if ( substr($expbin,$len,1) eq '1')                 # is_odd
      {
      _mul($c,$t,$acc);
      $t = _mod($c,$t,$mod);
      }
    _mul($c,$acc,$acc);
    $acc = _mod($c,$acc,$mod);
    }
  $num = $t;
  $num;
  }

sub _rsft
  {
  # (X,Y,N) = @_; means X >> Y in base N

  if ($_[3] != 2)
    {
    return $_[1] = gdivent($_[1], PARI($_[3]) ** $_[2]);
    }
  $_[1] >>= $_[2];
  }

sub _lsft
  {
  # (X,Y,N) = @_; means X >> Y in base N
  
  if ($_[3] != 2)
    {
    return $_[1] *= PARI($_[3]) ** $_[2];
    }
  $_[1] <<= $_[2];
  }

sub _fac
  {
  # factorial of argument
  $_[1] = ifact($_[1]);
  }

sub _modinv
  {
  # modular inverse
  my ($c,$x,$y) = @_;

  my $u = PARI(0); my $u1 = PARI(1);
  my $a = _copy($c,$y); my $b = _copy($c,$x);

  # Euclid's Algorithm for bgcd(), only that we calc bgcd() ($a) and the
  # result ($u) at the same time. See comments in BigInt for why this works.
  my $q;
  ($a, $q, $b) = ($b, _div($c,$a,$b));          # step 1
  my $sign = 1;
  while (!_is_zero($c,$b))
    {
    my $t = _add($c,                            # step 2:
       _mul($c,_copy($c,$u1), $q) ,             #  t =  u1 * q
       $u );                                    #     + u
    $u = $u1;                                   #  u = u1, u1 = t
    $u1 = $t;
    $sign = -$sign;
    ($a, $q, $b) = ($b, _div($c,$a,$b));        # step 1
    }

  # if the gcd is not 1, then return NaN
  return (undef,undef) unless _is_one($c,$a);

  $sign = $sign == 1 ? '+' : '-';
  ($u1,$sign);
  }

sub _log_int
  {
  my ($c,$x,$base) = @_;

  # X == 0 => NaN
  return if _is_zero($c,$x);
  # BASE 0 or 1 => NaN
  return if _is_zero($c,$base) || _is_one($c,$base);

  my $cmp = _acmp($c,$x,$base);         # X == BASE => 1
  if ($cmp == 0)
    {
    # return one
    $x = _one($c);
    return ($x, 1);
    }
  # X < BASE
  if ($cmp < 0)
    {
    $x = _zero($c);
    return ($x,undef);
    }

  my $trial = _copy($c,$base);
  my $x_org = _copy($c,$x);
  $x = _one($c);

  my $a;
  my $base_mul = _mul($c, _copy($c,$base), $base);
  my $two = _two($c);

  while (($a = _acmp($c, $trial, $x_org)) < 0)
    {
    _mul($c,$trial,$base_mul); _add($c, $x, $two);
    }

  my $exact = 1;
  if ($a > 0)
    {
    # overstepped the result
    _dec($c, $x);
    _div($c,$trial,$base);
    $a = _acmp($c,$trial,$x_org);
    if ($a > 0)
      {
      _dec($c, $x);
      }
    $exact = 0 if $a != 0;
    }

  ($x,$exact);
  }

1;
__END__

=head1 NAME

Math::BigInt::Pari - Use Math::Pari for Math::BigInt routines 

=head1 SYNOPSIS

    use Math::BigInt lib => 'Pari';

    ## See Math::BigInt docs for usage.

=head1 DESCRIPTION

Provides support for big integer calculations via means of Math::Pari,
an XS layer on top of the very fast PARI library.

=head1 LICENSE
 
This program is free software; you may redistribute it and/or modify it
under the same terms as Perl itself. 

=head1 AUTHOR

Original Math::BigInt::Pari written by Benjamin Trott 2001, ben@rhumba.pair.com.
Extended and maintained by Tels 2001-2004 http://bloodgate.com

Math::Pari was written by Ilya Zakharevich.

=head1 SEE ALSO

L<Math::BigInt>, L<Math::BigInt::Calc>, L<Math::Pari>.

=cut
