use strict;
use warnings;
use LWP::Simple;
use XML::Simple;

# Function to fetch definition of a word from XML dictionary
sub get_definition {
    my $word = shift;

    # URL of the XML dictionary
    my $url =
      "https://www.cnrtl.fr/dictionnaires/expressions_idiomatiques/dico/fp.xml";

    # Fetch the XML content
    my $xml_content = get($url);

    # Check if content was fetched successfully
    die "Couldn't get XML content" unless defined $xml_content;

    # Parse the XML
    my $xml = XMLin($xml_content);

    # Check if the word exists in the dictionary
    if ( exists $xml->{entry} ) {
        my @entries = @{ $xml->{entry} };
        foreach my $entry (@entries) {

            # Check if the current entry matches the word
            if ( $entry->{form} eq $word ) {

                # Print the definition
                print "Definition of $word:\n";
                print $entry->{sense}->{def}->{text} . "\n";
                return;
            }
        }
        print "Word not found in dictionary.\n";
    }
    else {
        print "No entries found in dictionary.\n";
    }
}

# Example usage
my $word = "example";    # Replace with the word you want to look up
get_definition($word);
