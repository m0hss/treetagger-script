use strict;
use warnings;
use XML::Simple;
use utf8;

binmode STDIN,  ':encoding(utf-8)';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

# Function to fetch definition of a word from XML dictionary
sub get_definition {
    my ( $word, $file_path ) = @_;

    # Parse the XML file
    my $xml  = XMLin($file_path);
    my $body = $xml->{text}->{body};

    # Check if the word exists in the dictionary
    if ( exists $body->{entry} ) {

        my @entries = @{ $body->{entry} };

        foreach my $entry (@entries) {
            my $orth = $entry->{form}->{orth};

            # Check if the current entry matches the word
            if ( $orth eq $word ) {

                # Print the definition
                print "Definition of '$word':\n";
                my $def = $entry->{sense}->{def};
                $def =~ s/^\s+|\s+$//g;
                print "$def\n";
                return;
            }
        }
        print "Word $word not found in dictionary.\n";
    }
    else {
        print "No entries found in dictionary.\n";
    }
}

# Example usage
# perl definition.pl "abandonner la partie"
# perl definition.pl "à bout de souffle" # error encodage
# perl definition.pl "l’avoir dans l’os"

my $word = $ARGV[0];
my $file_path =
  "files/fp.xml";    # Replace with the path to your XML dictionary file
get_definition( $word, $file_path );
