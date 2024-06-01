#!/usr/bin/perl
use strict;
use warnings;
use Lingua::EN::Inflect::Phrase ();

# Check if a file name is provided
if ( @ARGV != 1 ) {
    die "Usage: $0 <filename>\n";
}

my $filename = $ARGV[0];

# Open the file for reading
open( my $fh, '<', $filename ) or die "Could not open file '$filename' $!";

while ( my $line = <$fh> ) {
    chomp $line;

    # Split the line into words
    my @words = split /\s+/, $line;

    foreach my $word (@words) {

        # Remove punctuation and convert to lowercase
        $word =~ s/[[:punct:]]//g;
        my $lower_word = lc($word);

        # Get the singular form (lemma)
        my $lemma = Lingua::FR::Inflect::Phrase::singularize($lower_word);

        print "$lemma\n";
    }
}

close($fh);
