#!/usr/bin/env perl

use strict;
use warnings;
use Lingua::TreeTagger;

# Create a Tagger object.
my $tagger = Lingua::TreeTagger->new(
    'language' => 'french-spoken',
    'options'  => [qw( -token -lemma -no-unknown)],
    'use_utf8' => 1,
);

my $filename = $ARGV[0];

# Open the file for reading
open( my $fh, '<:encoding(utf-8)', $filename )
  or die "Could not open file '$filename' $!";
my $txt = do { local $/; <$fh> };

my $tagged_text = $tagger->tag_file($filename);

# Token objects may be accessed directly for more specific purposes.
foreach my $token ( @{ $tagged_text->sequence() } ) {

    # A token may contain a single SGML tag...
    if ( $token->is_SGML_tag() ) {
        print 'An SGML tag: ', $token->tag(), "\n";
    }

    # ... or a part-of-speech tag.
    else {
        #print 'tag: ', $token->tag(), "\n";

        # In the latter case, the token may also have attributes specifying
        # the original string...
        if (   defined $token->original()
            && length( $token->original() ) > 1
            && defined $token->lemma()
            && length( $token->lemma() ) > 1 )
        {
            print $token->original(), "  ", $token->tag(), "  ", $token->lemma(), "\n";
            #print '  lemma: ', $token->lemma(),    "\n";
        }

    }
}
