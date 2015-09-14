#!/usr/bin/perl -w
# demo: raw terminal using PTY; by Matija Nalis <mnalis-github@voyager.hr> GPLv3+, started 2015-09-14

use IO::Pty::Easy;
use Term::ReadKey;
use Time::HiRes qw(usleep);

ReadMode 'ultra-raw';

my $pty = IO::Pty::Easy->new ( raw => 0 );
$pty->spawn("sh");

# define filedescriptors on which we will wait
my $r_in='';
vec($r_in, fileno(STDIN), 1) = 1;
vec($r_in, $pty->fileno, 1) = 1; 

while ($pty->is_active) {
    my $output = $pty->read(0);
    if (defined $output) {
         print $output;
         #print "[output ends]";
         last if defined($output) && $output eq '';
    }
    
    my $input = ReadKey(-1);
    if (defined $input) {
        $input = '[E]' if $input eq "\ce";
        $input = '[S]' if $input eq "\c]";
        #print "[got input]";
        #print $input;
        my $chars = $pty->write($input, 0);
        last if defined($chars) && $chars == 0;
   }
   
    select ($r_out=$r_in, undef, undef, undef);	# infinite sleep until something comes on either on pty (output) or stdin (keyboard)
}

$pty->close;
ReadMode 'restore';
print "\n[Terminal exiting]\n";