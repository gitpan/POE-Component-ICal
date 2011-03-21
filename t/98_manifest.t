
### 98_manifest.t ########################################################################################### LOSYME ###

use strict;
use warnings;
use Test::More;

plan( skip_all => 'Author test' ) unless $ENV{LOSYME};

eval 'use Test::CheckManifest 0.9';
plan( skip_all => 'Test::CheckManifest 0.9 required' ) if $@;

ok_manifest({filter => [qr/MYMETA/]});

__END__

######################################################### END ##########################################################
