use strict;
use warnings;
use XML::Simple;
use utf8;
use Text::SimpleTable::AutoWidth;
use integer;

binmode STDIN,  ':encoding(utf-8)';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

my %result       = ();
my %cnrtl        = ();
my $found        = 0;
my $not_found    = 0;
my $total        = 0;
my $duplications = 0;
my $lines        = 0;
my $phrases      = 0;
my $dict         = "files/dict/fp.xml";

sub clear_text {
    my $txt = shift(@_);
    $txt = lc($txt);                   # convert to lowercase
    $txt =~ s/^\s+|\s+$//g;            # Trim
    $txt =~ s/\s+/ /g;                 # replace multiple spaces by space;
    $txt =~ s/\n/ /g;                  # Replace newlines by spaces;
    $txt =~ s/--+/ /g;                 # Replace 2+ hyphens with a space
    $txt =~ s/-//g;                    # Remove hyphens;
    $txt =~ s/[.,:;?"!()_•«»…—“]//g;
    $txt =~ s/[0-9]//g;
    return $txt;
}

sub setup_cnrtl {

    # Parse the XML file
    my $xml  = XMLin($dict);
    my $body = $xml->{text}->{body};
    if ( exists $body->{entry} ) {
        my @entries = @{ $body->{entry} };
        foreach my $entry (@entries) {
            my $orth = $entry->{form}->{orth};
            my $def  = "";

            # Note: sense can many defs n="1" n="2" ARRAY(0x7fec0d381520)
            if ( ref( $entry->{sense} ) eq 'ARRAY' ) {
                $def = $entry->{sense}->[0]->{def};
            }
            else {
                $def = $entry->{sense}->{def};
            }
            $cnrtl{$orth} = clear_text($def);
        }
    }
    else {
        print "No entries found in dictionary.\n";
    }
}

sub display_cnrtl {
    print "====== Display cnrtl =====\n";
    my $t = Text::SimpleTable::AutoWidth->new();
    foreach my $key ( sort keys %cnrtl ) {
        $t->row( $key, $cnrtl{$key} );
    }
    print $t->draw() . "\n";
}

sub get_definition_print {
    my $word = shift(@_);
    if ( exists $cnrtl{$word} ) {
        my $def = $cnrtl{$word};
        print "Defintion of '$word': $def\n\n";
        return $def;
    }
    else {
        print "Word $word not found in dictionary.\n";
    }
}

sub get_definition {
    my $word = shift(@_);
    if ( exists $cnrtl{$word} ) {
        my $def = $cnrtl{$word};
        print $word . "\n";
        $found++;
        return $def;
    }
    else {
        $not_found++;
        return "--";
    }
}

sub parse_file {
    my $filename = shift(@_);

    # Open the file for reading
    open( my $fh, '<:encoding(UTF-8)', $filename )
      or die "Could not open file '$filename' $!";

    # Read the file line by line
    while ( my $line = <$fh> ) {

        # Remove leading and trailing whitespaces
        $line =~ s/^\s+|\s+$//g;
        $lines++;

        # Split the line into phraseologisms
        my @phraseologisms = split /;/, $line;

        # Output each phraseologism
        foreach my $phraseologism (@phraseologisms) {

            # Remove leading and trailing whitespaces
            $phraseologism = clear_text($phraseologism);
            $duplications++;
            if ( !exists $result{$phraseologism} ) {
                $total++;
                $result{$phraseologism} = get_definition($phraseologism);

            }
        }
    }

    # Close the file
    close($fh);
}

sub display_result {
    print "====== Display Result =====\n";
    my $t     = Text::SimpleTable::AutoWidth->new();
    my $count = 1;
    foreach my $key ( sort keys %result ) {
        $t->row( $count, $key, $result{$key} );
        $count++;
    }
    print $t->draw() . "\n";
}

sub calculate_percent {
    if ( $found > 0 ) {
        return int( $total / $found );
    }
    return 0;
}

sub display_stats {
    my $percent = calculate_percent();
    print "============ Display Stats ===========\n";
    print "Dictinary: $dict\n";
    print "File: $ARGV[0]\n";
    print "Lines: $lines\n";
    print "Phrases: $duplications\n";
    print "Defintions found: $found\n";
    print "Defintions not found: $not_found\n";
    print "Total: $total\n";
    print "Percent: $percent%\n";
    print "\n";
}

# Usage
# perl main.pl files/file1.txt > output.txt
# perl main.pl files/file2.txt
# perl main.pl files/pg13951.txt
# perl main.pl files/pg13952.txt
# perl main.pl files/pg70891.txt

my $file = $ARGV[0];
setup_cnrtl();
#display_cnrtl();

# get_definition_print("abandonner la partie");
parse_file($file);
display_result();
display_stats();
