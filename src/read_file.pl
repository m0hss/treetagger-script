
use strict;
use warnings;

my $filename = $ARGV[0];

# Open the file for reading
open( my $fh, '<', $filename ) or die "Could not open file '$filename' $!";

my %dictionary = ();

# Read the file line by line
while ( my $line = <$fh> ) {

    # Remove leading and trailing whitespaces
    $line =~ s/^\s+|\s+$//g;

    # Split the line into phraseologisms
    my @phraseologisms = split /;/, $line;

    # Output each phraseologism
    foreach my $phraseologism (@phraseologisms) {

        # Remove leading and trailing whitespaces
        $phraseologism =~ s/^\s+|\s+$//g;
        $dictionary{"$phraseologism"} = "";
    }
}
foreach my $key ( sort keys %dictionary ) {

    # print "$key\n";
    print "$key:$dictionary{$key}\n";
}

# Close the file
close($fh);
