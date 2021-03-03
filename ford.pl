#!/usr/bin/perl

use strict;
use warnings;
use POSIX qw(setsid setuid strftime :signal_h);

use Parallel::ForkManager;
 

our @w1=('d','o','n','a','l','d');
our @w2=('g','e','r','a','l','d');
our @w3=('r','o','b','e','r','t');

our $logfile="/tmp/ford_res.log";

# limit iterations
our $start_int = 100000;
our $end_int = 999999;

my $fork_num=30; # Numbers of parallels processes

sub check_d1 () {
	my $check=1;
	my $len = $#_;
	
	if ($len == $#w1) {
		for (my $i=0; $i<=$len; ++$i) {
			for (my $k=$i+1; $k<=$len; ++$k) {
				if ($w1[$i] eq $w1[$k] and $i != $k) { 
					unless ($_[$i] == $_[$k]) { 
 						$check=0; 
						last;
					}
				} 	
				else {
					unless ($_[$i] != $_[$k] and $i != $k) { 
						$check=0; 
						last;
					}
				}
			}
		}
	}
	else { $check = 0; }

	return $check;
}

sub check_d2 () {
	my $check=1;
	my $len = $#_;
	
	if ($len == $#w2) {
		for (my $i=0; $i<=$len; ++$i) {
			for (my $k=$i+1; $k<=$len; ++$k) {
				if ($w2[$i] eq $w2[$k] and $i != $k) { 
					unless ($_[$i] == $_[$k]) { 
 						$check=0; 
						return 0;
					}
				} 	
				else {
					unless ($_[$i] != $_[$k] and $i != $k) { 
						$check=0; 
						return 0;
					}
				}
			}
		}
	}

	else { $check = 0; }

	return $check;
}

sub check_sum () {
	my $check=1;
	my @sum = split // , $_[0];
	my $len = $#sum;

	if ($len == $#w3) {
		for (my $i=0; $i<=$len; ++$i) {
			for (my $k=$i+1; $k<=$len; ++$k) {
				if ($w3[$i] eq $w3[$k] and $i != $k) { 
					unless ($sum[$i] == $sum[$k]) { 
 						$check=0;
						return 0;
					}
				} 	
				else {
					unless ($sum[$i] != $sum[$k] and $i != $k) { 
						$check=0; 
						return 0;
					}
				}
			}
		}
	}

	else { $check = 0; }

	return $check;
}


sub compare_d1d2 () {
	my $check=1;
	
	my $num1 = $_[0];
	my $num2 = $_[1];
	
	my @d1 = split // , $num1;
	my @d2 = split // , $num2;
	
	my $len = $#d1;
	
	if ($len == $#w2) {
		for (my $i=0; $i<=$len; ++$i) {
			for (my $k=0; $k<=$len; ++$k) {
				if ($w1[$i] eq $w2[$k]) { 
					unless ($d1[$i] == $d2[$k]) { 
 						$check=0; 
						return 0;
					}
				} 	
				else {
					unless ($d1[$i] != $d2[$k]) { 
						$check=0; 
						return 0;
					}
				}
			}
		}
	}

	return $check;
}

sub compare_d1sum () {
	my $check=1;
	
	my $num1 = $_[0];
	my $num2 = $_[1];
	
	my @d1 = split // , $num1;
	my @d2 = split // , $num2;
	
	my $len = $#d2;
	
	if ($len == $#w3) {
		for (my $i=0; $i<=$len; ++$i) {
			for (my $k=0; $k<=$len; ++$k) {
				if ($w1[$i] eq $w3[$k]) { 
					unless ($d1[$i] == $d2[$k]) { 
 						$check=0; 
						return 0;
					}
				} 	
				else {
					unless ($d1[$i] != $d2[$k]) { 
						$check=0; 
						return 0;
					}
				}
			}
		}
	}

	return $check;
}


sub compare_d2sum () {
	my $check=1;
	
	my $num1 = $_[0];
	my $num2 = $_[1];
	
	my @d1 = split // , $num1;
	my @d2 = split // , $num2;
	
	my $len = $#d2;

	if ($len == $#w3) {
		for (my $i=0; $i<=$len; ++$i) {
			for (my $k=0; $k<=$len; ++$k) {
				if ($w2[$i] eq $w3[$k]) { 
					unless ($d1[$i] == $d2[$k]) { 
 						$check=0; 
						return 0;
					}
				} 	
				else {
					unless ($d1[$i] != $d2[$k]) { 
						$check=0; 
						return 0;
					}
				}
			}
		}
	}

	return $check;
}

sub logger {

	open(LOGFILE, ">>$logfile") or return;
	print LOGFILE strftime "[%d/%m/%Y %H:%M:%S] ", localtime;
	print LOGFILE $_[0]."\n";
	print STDOUT strftime "[%d/%m/%Y %H:%M:%S] ", localtime;
	print STDOUT "\n";
	print STDOUT $_[0]."\n";
	close(LOGFILE);
}

sub progress {
	my $i = shift;
	my $perc = $i * 100 /($end_int-$start_int);
	print sprintf("%.2f", $perc)."% (".$i.")\n";
}


logger("start");


#check vars

if ($start_int < $end_int) { 
	logger ("bad limit iterations!");
	exit 0;
}


my $num = 0;	

my $pm = Parallel::ForkManager->new($fork_num, '/tmp/');

for (my $i=$start_int; $i<$end_int; ++$i) {
	++$num;
	if ($num > 1000) {
		$num = 0;
		&progress($i);
	}

	my @d1 = split // , $i;
	
	$pm->start and next;
	if (&check_d1(@d1) == 1) {
		for (my $k=$start_int; $k<$end_int; ++$k) {
			my @d2 = split // , $k;

			if (&check_d2(@d2) == 1) {
				my $sum = $i + $k;
				if (&check_sum($sum) == 1) { 
					if (&compare_d1d2($i,$k) == 1) {
						if (&compare_d1sum($i,$sum) == 1) {
							if (&compare_d2sum($k,$sum) == 1) {
								logger ($i."\n".$k."\n".$sum."\n===\n\n");
							}
						}
					}
				}
			}
		}
	}
	$pm->finish;
}