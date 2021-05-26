#!/usr/bin/perl
#
#  Author: Preslav Nakov
#  
#  Description: Scores SemEval-2017 task 4, subtask A
#               Calculates macro-average R, macro-average F1, and Accuracy
#
#  Last modified: February 11, 2017
#
#

use warnings;
use strict;
use utf8;
binmode (STDIN,  ":utf8");
binmode (STDOUT, ":utf8");

my $GOLD_FILE          =  $ARGV[0];
my $INPUT_FILE         =  $ARGV[1];
my $OUTPUT_FILE        =  $INPUT_FILE . '.scored';


########################
###   MAIN PROGRAM   ###
########################

my %stats = ();


### 1. Read the files and get the statsitics
open INPUT, $INPUT_FILE or die;
open GOLD,  $GOLD_FILE or die;
#open INPUT, '<:encoding(UTF-8)', $INPUT_FILE or die;
#open GOLD,  '<:encoding(UTF-8)', $GOLD_FILE or die;

while (<INPUT>) {

	s/^[ \t]+//;
	s/[ \t\n\r]+$//;

	### 1.1. Check the input file format
	#1	positive	i'm done writing code for the week! Looks like we've developed a good a** game for the show Revenge on ABC Sunday, Premeres 09/30/12 9pm
	die "Wrong file format for $INPUT_FILE: $_" if (!/^\d+\t(positive|negative|neutral)/);
	my $proposedLabel = $1;

	### 1.2	. Check the gold file format
	#NA	T14114531	positive
	$_ = <GOLD>;
	die "Wrong file format!" if (!/^\d+\t(positive|negative|neutral)/);
	my $trueLabel = $1;

	### 1.3. Update the statistics
	$stats{$proposedLabel}{$trueLabel}++;
}

close(INPUT) or die;
close(GOLD) or die;

### 2. Initialize zero counts
foreach my $class1 ('positive', 'negative', 'neutral') {
	foreach my $class2 ('positive', 'negative', 'neutral') {
		$stats{$class1}{$class2} = 0 if (!defined($stats{$class1}{$class2}))
	}
}

### 3. Calculate the F1
print "$INPUT_FILE\t";
open OUTPUT, '>:encoding(UTF-8)', $OUTPUT_FILE or die;

my $avgR  = 0.0;
my $avgF1 = 0.0;
foreach my $class ('positive', 'negative', 'neutral') {

	my $denomP = (($stats{$class}{'positive'} + $stats{$class}{'negative'} + $stats{$class}{'neutral'}) > 0) ? ($stats{$class}{'positive'} + $stats{$class}{'negative'} + $stats{$class}{'neutral'}) : 1;
	my $P = $stats{$class}{$class} / $denomP;

	my $denomR = ($stats{'positive'}{$class} + $stats{'negative'}{$class} + $stats{'neutral'}{$class}) > 0 ? ($stats{'positive'}{$class} + $stats{'negative'}{$class} + $stats{'neutral'}{$class}) : 1;
	my $R = $stats{$class}{$class} / $denomR;
			
	my $denom = ($P+$R > 0) ? ($P+$R) : 1;
	my $F1 = 2*$P*$R / $denom;

    $avgR  += $R;
	$avgF1 += $F1 if ($class ne 'neutral');
	printf OUTPUT "\t%8s: P=%0.4f, R=%0.4f, F1=%0.4f\n", $class, $P, $R, $F1;
}

$avgR  /= 3.0;
$avgF1 /= 2.0;
my $acc = ($stats{'positive'}{'positive'} + $stats{'negative'}{'negative'} + $stats{'neutral'}{'neutral'}) 
        / ($stats{'positive'}{'positive'} + $stats{'negative'}{'negative'} + $stats{'neutral'}{'neutral'} +
           $stats{'positive'}{'negative'} + $stats{'negative'}{'positive'} +
           $stats{'positive'}{'neutral'} + $stats{'neutral'}{'positive'} +
           $stats{'negative'}{'neutral'} + $stats{'neutral'}{'negative'});
printf OUTPUT "\t\tAvgR_3=%0.3f, AvgF1_2=%0.3f, Acc=%0.3f\n", $avgR, $avgF1, $acc;
printf OUTPUT "\tOVERALL SCORE : %0.3f\n", $avgR;
printf "%0.3f\t%0.3f\t%0.3f\t", $avgR, $avgF1, $acc;

print "\n";
close(OUTPUT) or die;
