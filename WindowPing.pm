# $Id: WindowPing.pm 134 2008-08-21 11:37:25Z rplessl $

package Win32::Monitoring::WindowPing;

use 5.008008;
use strict;
use warnings;
use Carp;

require Exporter;
require DynaLoader;
use AutoLoader;

our @ISA = qw(Exporter DynaLoader);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Win32::Monitoring::WindowPing ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
   GetActiveWindow
   PingWindow
   PingStatus2Text
   GetWindowCaption
   GetProcessIdForWindow
   GetNameForProcessId
   WAS_ALIVE
   WAS_TIMEOUT
   WAS_NOTAWINDOW
   WAS_OTHERERROR
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

our $VERSION = '0.04';

use constant WAS_ALIVE => 1;
use constant WAS_TIMEOUT => 2;
use constant WAS_NOTAWINDOW => 3;
use constant WAS_OTHERERROR => 4;

bootstrap Win32::Monitoring::WindowPing $VERSION;

# Preloaded methods go here.


1;
__END__

=head1 NAME

Win32::Monitoring::WindowPing - Access to window status information on Win32 systems

=head1 SYNOPSIS

   use Win32::Monitoring::WindowPing qw( 
                                       GetActiveWindow
                                       PingWindow
                                       PingStatus
                                       GetWindowCaption
                                       GetProcessIdForWindow
                                       GetNameForProcessId
                                       WAS_ALIVE
                                       WAS_TIMEOUT
                                       WAS_NOTAWINDOW
                                       WAS_OTHERERROR
                                     );

   my $HWND          = GetActiveWindow();
   my $pingstatus    = PingWindow($HWND, $timeout_in_ms);
   my $caption       = GetWindowCaption($HWND);
   my $processid     = GetProcessIdForWindow($HWND);
   my $nameforprocid = GetNameForProcessId($processid);


=head1 DESCRIPTION

The Win32::Monitoring::WindowPing module provides a function to check if a
windows desktop window was willing to respond to user input along with a set
of companion functions such that you can implement a nive window alive
program without requiering further modules.

=over

=item $HWND=GetActiveWindows()

Returns the window handle of the curently active window on the window desktop

=item $status=PingWindow($HWND,$timeout_in_ms)

Determine is the window with the given HWND would react to user input. Return
after timeout. Status is one of the following

 WAS_ALIVE      - The windows reacts
 WAS_TIMEOUT    - No reaction within the timeout period
 WAS_NOTAWINDOW - The given HWND does not corespond to a window
 WAS_OTHERERROR - Something else went wrong check LastError

=item GetWindowCaption($HWND)

Get the caption of the window. The function will climb the windw hierarchy
until it finds a window with a proper caption.

=item $PID=GetProcessIdForWindow($HWND)

Find the process id connected with this window.

=item GetNameForProcessId($PID)

Get the name of the binary for the process id.

=back

=head2 EXAMPLE

   #! perl
   use strict;
   use warnings;

   use Win32::Monitoring::WindowPing qw(:all);

   use Time::HiRes qw(gettimeofday usleep);

   my %wl; # the watchlist
   my $timeout = 200;
   while(1){   
      for my $hwnd (keys %wl){
         usleep(1000*25);
         my $r = PingWindow($hwnd, $timeout);
         if ($r == WAS_ALIVE){
             my $duration = scalar gettimeofday() - $wl{$hwnd}{hangstart};
             my $caption = GetWindowCaption($hwnd);
             printf "%-10s hung for    %8.3f s - $caption\n",
                    $wl{$hwnd}{process}, $duration;
            delete $wl{$hwnd};
         }
         elsif ($r == WAS_NOTAWINDOW){
             my $duration = scalar gettimeofday() - $wl{$hwnd}{hangstart};
             printf "%-10s crash after %8.3f s\n",$wl{$hwnd}{process}, $duration;
             delete $wl{$hwnd};
         }
      }    
      my $hwnd2 = GetActiveWindow();
      if ($hwnd2 and not $wl{$hwnd2}){
         my $r = PingWindow($hwnd2,$timeout);
         if ($r == WAS_TIMEOUT){
             my $id = GetProcessIdForWindow($hwnd2);
             $wl{$hwnd2} = { hangstart => scalar gettimeofday(),
                             process => GetNameForProcessId($id),
                             id => $id,
                           };
         }
      }
      usleep(1000*250);
   };

=head1 SEE ALSO

Webpage: <http://oss.oetiker.ch/optools/>

=head1 COPYRIGHT

Copyright (c) 2008 by OETIKER+PARTNER AG. All rights reserved.

=head1 LICENSE

Win32::Monitoring::WindowPing is free software: you can redistribute 
it and/or modify it under the terms of the GNU General Public License 
as published by the Free Software Foundation, either version 3 of the 
License, or (at your option) any later version.

Win32::Monitoring::WindowPing is distributed in the hope that it will 
be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Win32::Monitoring::WindowPing. If not, see 
<http://www.gnu.org/licenses/>.

=head1 AUTHORS

Roman Plessl,
Tobias Oetiker

=cut

# Emacs Configuration
#
# Local Variables:
# mode: cperl
# eval: (cperl-set-style "PerlStyle")
# mode: flyspell
# mode: flyspell-prog
# End:
#
# vi: sw=4
