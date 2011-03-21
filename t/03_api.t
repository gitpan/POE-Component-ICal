
### 03_api.t ################################################################################################ LOSYME ###

use strict;
use warnings;

use Test::More;
my $tests;
plan tests => $tests;

use POE::Component::ICal;

BEGIN { $tests += 2; }

ok( defined $POE::Component::ICal::VERSION );
ok( $POE::Component::ICal::VERSION =~ /^\d{1}.\d{2}$/ );

BEGIN { $tests += 1; }

can_ok('POE::Component::ICal', qw(verify add_schedule add remove));

__END__

######################################################### END ##########################################################
