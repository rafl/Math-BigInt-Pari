package Math::BigInt::Pari;
use strict;

use vars qw( @ISA @EXPORT $VERSION );
$VERSION = '1.07';

use Math::Pari qw(PARI pari2pv gdivent bittest gcmp0 gcmp1 gcd ifact);

# MBI will call this, so catch it and throw it away
sub import { }

sub _new { PARI(${ $_[1] }) }

sub _from_hex {
    my $h = $_[1];
    $$h =~ s/^[+-]//;				# remove sign
    $$h = "0x$$h" unless $$h =~ /^0x/;		# make sure it starts with 0x
    Math::Pari::_hex_cvt($$h);
}

sub _from_bin
  {
  my $b = $_[1];
  $$b =~ s/^[+-]?0b//;					# remove sign and 0b
  my $l = length($$b);					# bits
  $$b = '0' x (8-($l % 8)) . $$b if ($l % 8) != 0;	# padd left side w/ 0
  my $h = unpack('H*', pack ('B*', $$b));		# repack as hex
  Math::Pari::_hex_cvt('0x' . $h);			# can handle it now
  }

sub _as_hex {
    my $v = unpack('H*', _mp2os($_[1]));
    $v =~ s!^0*!!;
    \('0x' . $v);
}
sub _as_bin {
    my $v = unpack('B*', _mp2os($_[1]));
    $v =~ s!^0*!!;
    \('0b' . $v);
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

sub _copy { $_[1] + 0 }

sub _str { my $x = pari2pv($_[1]); \$x }

sub _num { pari2pv($_[1]) }

sub _add { $_[1] += $_[2] }

sub _sub {
    if ($_[3]) {
        $_[2] = $_[1] - $_[2]; return $_[2];
    } else {
        $_[1] -= $_[2]; return $_[1];
    }
}

sub _mul { $_[1] *= $_[2] }

sub _div {
    if (wantarray)
      {
      my $r = $_[1] % $_[2];
      $_[1] = gdivent($_[1], $_[2]);
      return ($_[1], $r);
      }
    else
      {
      $_[1] = gdivent($_[1], $_[2]);
      }
  $_[1];
}

sub _mod { $_[1] %= $_[2]; }

#sub _inc { ++$_[1]; }	# ++ and -- flotify (bug in Pari)
#sub _dec { --$_[1]; }
sub _inc { $_[1] += PARI(1); }
sub _dec { $_[1] -= PARI(1); }

sub _and { $_[1] &= $_[2] }

sub _xor { $_[1] ^= $_[2] }

sub _or { $_[1] |= $_[2] }

sub _pow { $_[1] **= $_[2] }

sub _gcd { gcd($_[1], $_[2]) }

sub _len { length(pari2pv($_[1])) }

sub _digit { substr(pari2pv($_[1]), -($_[2]+1), 1) }

sub _is_zero { gcmp0($_[1]) }

sub _is_one { gcmp1($_[1]) }

sub _is_even { bittest($_[1],0) ? 0 : 1 }

sub _is_odd { bittest($_[1],0) ? 1 : 0 }

sub _acmp { $_[1] <=> $_[2] }

sub _check {
    my($class,$x) = @_;
    return "$x is not a reference to Math::Pari" if ref($x) ne 'Math::Pari';
    0;
}

sub _rsft
  {
  # (X,Y,N) = @_; means X >> Y in base N
  #return undef if $_[3] != 2;
  if ($_[3] != 2)
    {
    return $_[1] = gdivent($_[1], PARI($_[3]) ** $_[2]);
    }
  $_[1] >>= $_[2];
  }

sub _lsft
  {
  # (X,Y,N) = @_; means X >> Y in base N
  #return undef if $_[3] != 2;
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

Math::BigInt::Pari was written by Benjamin Trott, ben@rhumba.pair.com.

Math::Pari was written by Ilya Zakharevich.

=head1 SEE ALSO

L<Math::BigInt>, L<Math::BigInt::Calc>, L<Math::Pari>.

=cut
