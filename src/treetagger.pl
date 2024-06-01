#!/usr/bin/perl

use strict;
use warnings;
use XML::Simple;
use utf8;
use Text::SimpleTable::AutoWidth;
use Lingua::TreeTagger;
use JSON;
use utf8;
use open ':encoding(UTF-8)', ':std';

binmode STDIN,  ':encoding(utf-8)';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

my %result        = ();
my %tagged_result = ();
my %cnrtl         = ();

my $found                 = 0;
my $not_found             = 0;
my $total                 = 0;
my $duplications          = 0;
my $lines                 = 0;
my $phrases               = 0;
my $words                 = 0;
my $found_with_treetagger = 0;
my $total_with_tretagger  = 0;

my $dict = $ARGV[1];
my $language = $ARGV[2];
my ($dictname) = $dict =~ m|([^/]+)$|;

#Debug output
#print "Using parameter file: $param_file\n";
#print "TREETAGGER_HOME is set to: $ENV{'TREETAGGER_HOME'}\n";

# Create a Tagger object.
my $tagger = Lingua::TreeTagger->new(
    'language' => $language,
    'options'  => [qw( -token -lemma -no-unknown)],
    'use_utf8' => 1,
);

# # Debug: Confirm the tagger object creation
# if ($tagger) {
#     print "Tagger object created successfully.\n";
#     print "Language used in tagger: ", $tagger->get_language(), "\n";
# }
# else {
#     die "Failed to create Tagger object.\n";
# }

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
            $cnrtl{ clear_text($orth) } = clear_text($def);
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
        chomp($line);

        # Decode the line from UTF-8
        # $line = decode( 'UTF-8', $line );

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

                # my $tagged_text = tag_text($phraseologism);
                $result{$phraseologism} = get_definition($phraseologism);

            }
        }
    }

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
        return $found * 100 / $total;
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
    print "Percent: ", sprintf( "%.2f", calculate_percent() ), "%\n";
    print "\n";
}

sub lemmalize {
    my $text        = join( " ", keys %result );
    my $tagged_text = $tagger->tag_text( \$text );
    my $lemma_text  = '';
    foreach my $token ( @{ $tagged_text->sequence() } ) {
        $words++;
        if ( defined $token->lemma() ) {
            $lemma_text .= $token->lemma() . " ";
        }
    }
    open( OUT, ">:encoding(UTF-8)", "main_lemma.txt" ) or die;
    print OUT $lemma_text;
    close(OUT);
    return $lemma_text;
}

sub parse_with_treetagger {
    my $text = lemmalize();
    foreach my $key ( sort keys %cnrtl ) {
        my $count = 0;
        while ( $text =~ /$key/g ) {
            $count++;
        }
        if ( $count > 0 ) {
            $total_with_tretagger += $count;
            $found_with_treetagger++;
            $tagged_result{$key}{"def"}   = get_definition($key);
            $tagged_result{$key}{"count"} = $count;
        }
    }
}

sub display_tagged_result {
    print "====== Display Result With TreeTagger =====\n";
    my $t     = Text::SimpleTable::AutoWidth->new();
    my $count = 1;
    foreach my $key ( sort keys %tagged_result ) {
        my $count_val = defined $tagged_result{$key}->{"count"};
        my $def_val   = defined $tagged_result{$key}->{"def"};

        $t->row( $count, $key, $count_val, $def_val );
        $count++;
    }
    if ( $count == 1 ) {    # No rows were added
        $t->row( '', '', '', '' );
    }
    print $t->draw() . "\n";
}

sub display_stats_with_treetagger {
    print "============ Display Stats With TreeTagger ===========\n";
    print "Words: $words\n";
    print "Defintions unique found: $found_with_treetagger\n";
    print "Total phrases found: $total_with_tretagger\n";
    print "CPT: ", $words / $total_with_tretagger, "\n";
    print "CPT Percent: ",
      sprintf( "%.2f", $total_with_tretagger * 100 / $words ), "%\n";
    print "CPT Unique: ", $words / $found_with_treetagger, "\n";
    print "CPT Percent: ",
      sprintf( "%.6f", $found_with_treetagger * 100 / $words ), "%\n";
    print "\n";
}

setup_cnrtl();

# display_cnrtl();
parse_file( $ARGV[0] );

# display_result();

# display_stats();
parse_with_treetagger();

# display_tagged_result();
# display_stats_with_treetagger();

# Output JSON
my $cpt = ($total_with_tretagger != 0) ? $words / $total_with_tretagger : 0;
my $cpt_percent = ($words != 0) ? $total_with_tretagger * 100 / $words : 0;
my $cpt_unique = ($found_with_treetagger != 0) ? $words / $found_with_treetagger : 0;
my $cpt_percent_unique = ($words != 0) ? $found_with_treetagger * 100 / $words : 0;

my %output_result = (
    result                => \%result,
    dic                   => $dictname,
    lines                 => $lines,
    duplications          => $duplications,
    found                 => $found,
    not_found             => $not_found,
    total                 => $total,
    percent               => calculate_percent(),
    tagged_result         => \%tagged_result,
    word                  => $words,
    found_with_treetagger => $found_with_treetagger,
    total_with_tretagger  => $total_with_tretagger,
    cpt                   => $cpt,
    cpt_percent           => $cpt_percent,
    cpt_unique            => $cpt_unique,
    cpt_percent_unique    => $cpt_percent_unique,
);

print to_json( \%output_result, { utf8 => 1, pretty => 1 } );
