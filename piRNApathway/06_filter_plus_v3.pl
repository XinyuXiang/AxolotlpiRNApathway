#!/usr/bin/perl

while(<>) {
    chomp;
    @a = split(/\s+/, $_);
    $b = length($a[9]);
    if ($a[1] eq "0") {
        print "$a[9]:$b:1\tplus\t$a[3]\n";
    }
}

