#!/usr/bin/env perl

use strict;
use warnings;
use Lingua::TreeTagger;

# Create a Tagger object.
my $tagger = Lingua::TreeTagger->new(
    'language' => 'french',
    'options'  => [qw( -token -lemma -no-unknown)],
    'use_utf8' => 1,
);

my $file_path   = '../files/file3.txt';
my $tagged_text = $tagger->tag_file($file_path);

# Both methods return a Lingua::TreeTagger::TaggedText object, i.e. a
# sequence of Lingua::TreeTagger::Token objects, which can be stringified
# as raw text...
print $tagged_text->as_text(
    {
        #'fields'          => [qw( lemma original )],
        'field_delimiter' => q{:},
        'token_delimiter' => q{ },
    }
);

# ... or in XML format.
#print $tagged_text->as_XML();

# Token objects may be accessed directly for more specific purposes.
foreach my $token ( @{ $tagged_text->sequence() } ) {

    # A token may contain a single SGML tag...
    if ( $token->is_SGML_tag() ) {
        print 'An SGML tag: ', $token->tag(), "\n";
    }

    # ... or a part-of-speech tag.
    else {
        print 'A part-of-speech tag: ', $token->tag(), "\n";

        # In the latter case, the token may also have attributes specifying
        # the original string...
        if ( defined $token->original() ) {
            print '  token: ', $token->original(), "\n";
        }

        # ... or the corresponding lemma.
        if ( defined $token->lemma() ) {
            print '  lemma: ', $token->lemma(), "\n";
        }
    }
}
