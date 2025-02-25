#!/usr/bin/perl

while(<>) {
    chomp;
    @a = split(/\s+/, $_);
    $b = length($a[9]);
    $position = $b + $a[3];
    if ($a[1] eq "16") {
        print "$a[9]:$b:1\tminus\t$position\n";
    }
}

