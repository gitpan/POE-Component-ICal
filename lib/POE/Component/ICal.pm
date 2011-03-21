########################################################################################################################
##                                                                                                                    ##
##                                                POE::Component::ICal                                                ##
##                                   Schedule POE events using rfc2445 recurrences                                    ##
##                                                                                                                    ##
############################################################################################################# LOSYME ###
##
##  Revision history
##--------------------------
##
##  0.01    06.03.2011 02:26
##          First version, released by LOSYME
##
package POE::Component::ICal; #=========================================================================================
########################################################################################################################

use strict;
use warnings FATAL => 'all';

=head1 NAME

POE::Component::ICal - Schedule POE events using rfc2445 recurrences.

=head1 VERSION

Version 0.01

=cut

BEGIN
{
    $POE::Component::ICal::VERSION = '0.01';
}

use Carp qw( croak );
use DateTime;
use DateTime::Event::ICal;
use POE::Kernel;
use base qw( POE::Component::Schedule );

use constant SCHEDULE_PREFIX => '__ICal__'; #...........................................................................

=head1 SYNOPSIS

    use strict;
    use warnings;
    use POE;
    use POE::Component::ICal;
    
    my $count = 5;
    
    POE::Session->create
    (
        inline_states =>
        {
            _start => sub
            {
                print "_start\n";
                $_[HEAP]{count} = $count;
                POE::Component::ICal->add( tick => { freq => 'secondly', interval => 1 });
            },
            tick => sub
            {
                print "tick: ' . --$_[HEAP]{count}\n";
                POE::Component::ICal->remove( 'tick' ) if $_[HEAP]{count} == 0;
            },
            _stop => sub
            {
                print "_stop\n";
            }
        }
    );
    
    POE::Kernel->run;

=head1 DESCRIPTION

This component extends L<POE::Component::Schedule> by adding an easy way to specify event schedules
using rfc2445 recurrence.

See L<DateTime::Event::ICal> for the syntax, the list of the authorized parameters and their use.

=head1 METHODS

=head2 verify( $ical )

This method allows to verify the validity of a rfc2445 recurrence.

=over

=item Parameters

C<$ical> - HASHREF - The rfc2445 recurrence.

=item Return value

Three cases:

    my $ical = { freq => 'secondly', interval => 2 };
    POE::Component::ICal->verify( $ical );

In case of not validity, an exception is raised.

    my $is_valid = POE::Component::ICal->verify( $ical );

A true or false value is returned.

    my ($is_valid, $value) = POE::Component::ICal->verify( $ical );

In case of not validity, $value contains the error message otherwise a L<DateTime::Set> instance. 

=back

=cut

sub verify
###=====================================================================================================================
{
    my ($class, $ical) = @_;
    
    if ( defined wantarray )
    {
        my $set;
        eval { $set = DateTime::Event::ICal->recur( %$ical ); };
        my $is_valid = not $@;
        return wantarray ? ($is_valid, $is_valid ? $set : $@) : $is_valid;
    }
    
    DateTime::Event::ICal->recur( %$ical );
    return 1;
}

=head2 add_schedule($schedule, $event, $ical, @args)

This method add a schedule.

=over

=item Parameters

C<$schedule> - SCALAR - The schedule name.

C<$event> - SCALAR - The event name.

C<$ical> - HASHREF - The rfc2445 recurrence.

C<@args> - optional - The optional list of the arguments.

=item Return value

A schedule handle. See L<POE::Component::Schedule>.

=item Remarks

The schedule name must be unique by session.

When the rfc2445 parameter C<dtstart> is not specify, this method add it with the C<DateTime-E<gt>now()> value.

=item Example

    POE::Component::ICal->add_schedule
    (
          'tick'                                         # schedule name
        , clock => { freq => 'secondly', interval => 1 } # event name => ical
        , 'tick'                                         # ARG0 (Optional)
        , \$tick_count                                   # ARG1 (Optional)
    );
    POE::Component::ICal->add_schedule
    (
          'tock'                                         # schedule name
        , clock => { freq => 'secondly', interval => 2 } # event name => ical
        , 'tock'                                         # ARG0 (Optional)
        , \$tock_count                                   # ARG1 (Optional)
    );

=back

=cut

sub add_schedule
###=====================================================================================================================
{
    my ($class, $shedule, $event, $ical, @args) = @_;
    
    $ical->{dtstart} = DateTime->now() unless exists $ical->{dtstart};
    
    my ($is_valid, $value) = $class->verify( $ical );
    croak $value unless $is_valid;
    
    my $session = POE::Kernel->get_active_session();
    return $session->get_heap->{SCHEDULE_PREFIX . $shedule} = $class->SUPER::add($session, $event => $value, @args);
}

=head2 add($event, $ical, @args)

This method calls C<add_schedule()> with schedule name equal to event name.

=over

=item Parameters

C<$event> - SCALAR - The event name.

C<$ical> - HASHREF - The rfc2445 recurrence.

C<@args> - optional - The optional list of the arguments.

=item Return value

See C<add_schedule()>.

=item Remarks

See C<add_schedule()>.

=item Example

    POE::Component::ICal->add_schedule('tick', tick => { freq => 'secondly', interval => 5 });
    POE::Component::ICal->add(                 tick => { freq => 'secondly', interval => 5 });

=back

=cut

sub add
###=====================================================================================================================
{
    my ($class, $event, $ical, @args) = @_;
    return $class->add_schedule($event, $event, $ical, @args);
}

=head2 remove( $schedule )

This method remove a schedule.

=over

=item Parameters

C<$schedule> - SCALAR - The schedule name.

=item Example

    POE::Component::ICal->add_schedule('tock', clock => { freq => 'secondly', interval => 1 });
    POE::Component::ICal->remove( 'tock' );

    POE::Component::ICal->add(tick => { freq => 'secondly', interval => 1 });
    POE::Component::ICal->remove( 'tick' );

=back

=cut

sub remove
###=====================================================================================================================
{
    my ($class, $schedule) = @_;
    delete POE::Kernel->get_active_session()->get_heap()->{SCHEDULE_PREFIX . $schedule};
}

=head1 SEE ALSO

The section 4.3.10 of rfc2445: L<http://www.apps.ietf.org/rfc/rfc2445.html>.

=head1 AUTHOR

LoE<iuml>c TROCHET E<lt>losyme@gmail.comE<gt>

=head1 COPYRIGHT & LICENSE 

Copyright (C) 2011 by LoE<iuml>c TROCHET.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1;

__END__

######################################################### END ##########################################################
