
use strict;

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# The name of your distribution
name		'Math-BigInt-Pari';

# Get most of the details from the primary module
all_from	'lib/Math/BigInt/Pari.pm';

requires	'perl'		=> "5.006002";
requires	'Math::BigInt'	=> '1.87';
requires	'Math::Pari'	=> '2.010709';

build_requires	'Test::More'	=> 0.62;

license		'perl';
      
author		'Benjamin Trott <ben@rhumba.pair.com>, ' .
		'Tels <nospam-abuse@bloodgate.com>';

# Generate the Makefile
WriteAll;
