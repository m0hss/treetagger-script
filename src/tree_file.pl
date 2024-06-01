#!/usr/bin/env perl

use strict;
use warnings;
use Lingua::TreeTagger;

sub clearText {
    my $text = $_[0];
    $text = lc($text);         # Convert to lowercase
    $text =~ s/[^-a-z]/ /g;    # Remove non-alphabetic characters

    return ($text);
}

# Create a Tagger object.
my $tagger = Lingua::TreeTagger->new(
    'language' => 'french-spoken',
    'options'  => [qw( -token -lemma -no-unknown)],
    'use_utf8' => 0,
);

print "\n================\n";
my $filename = "files/file3.txt";

# Open the file for reading
open( FILE, '<:encoding(utf-8)', $filename )
  or die "Could not open file '$filename' $!";

# Read the file line by line
while (<FILE>) {
    chomp;
    $_ = lc($_);
    s/--/ /g;    # Remove dashes
    s/[.,:;?"!()]//g;
    s/\s+/ /g;    # Replace multiple spaces with one space
    my @words = split(/ /);

    foreach my $word (@words) {
        print "$word\n";
    }
}
