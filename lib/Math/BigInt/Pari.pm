package Math::BigInt::Pari;
use strict;

use vars qw( @ISA @EXPORT $VERSION );
$VERSION = '1.02';

require Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(
        _add _mul _div _mod _sub
        _new _from_hex
        _str _num _acmp _len
        _digit
        _is_zero _is_one
        _is_even _is_odd
        _check _zero _one _copy _len
        _pow _dec _inc
        _and _or _xor
        _gcd
);

use Math::Pari qw( PARI pari2pv gdivent bittest gcmp0 gcmp1 gcd );

sub _new { PARI(${ $_[1] }) }

sub _from_hex {
    my $h = $_[1];
    $$h =~ s/^[+-]//;
    $$h = "0x$$h" unless $$h =~ /^0x/;
    Math::Pari::_hex_cvt("$$h");
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

sub _inc { $_[1]++ }

sub _dec { $_[1]-- }

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
