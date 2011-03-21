
### 98_portability.t ######################################################################################## LOSYME ###

use strict;
use warnings;
use Test::More;

eval 'use Test::Portability::Files';
plan( skip_all => 'Test::Portability::Files required for testing filenames portability' ) if $@;

run_tests();

__END__

######################################################### END ##########################################################
