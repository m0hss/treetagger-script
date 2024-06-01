#!/usr/bin/env perl

#======================================================================
#    NAME: server.pl
#======================================================================
#  AUTHOR: Hubert Naets <hubert.naets@uclouvain.be>
#    DATE: 2015-05-13
# VERSION: 0.1
#======================================================================
# Application web  affichant 'Bonjour le monde !'
# si l'utilisateur demande la page '/'.
#
# Peut se lancer en tapant dans un terminal :
# mojo serveur.pl
# et en fournissant l'URL suivante à un navigateur web :
# http://localhost:3000
#
# À noter que beaucoup d'autres modes d'exécution de l'application
# sont possibles. Consulter la documentation de Mojolicious
# (http://mojolicio.us/).
#======================================================================
# USAGE:
# morbo server.pl
#======================================================================

use strict;
use warnings;
use Mojolicious::Lite;
use Mojo::DOM;
use Mojo::UserAgent;
use CGI;
use utf8;
use File::Slurp qw(write_file read_file);
use File::Temp  qw(tempfile);
use JSON;
use Data::Dumper;
use Mojo::File 'path';
use Encode qw(decode encode);

# Serve static files from the 'templates' and 'public' directories
app->static->paths->[0] = app->home->rel_file('../public');
push @{ app->static->paths }, app->home->rel_file('templates');

my $dict = 'files/dict/fp.xml';
my $language = 'french';

# GET /
get '/' => sub {
    my $c = shift;
    $c->reply->static('index.html');
};

# POST /process_text
post '/process_text' => sub {
    my $c            = shift;
    my $request_text = $c->param('request');
    my $tempfile;

    # Remove file parameter to avoid interference
    $c->req->params->remove('file');

    if ( defined $request_text && $request_text ne '' ) {

        # Save the request text to a temporary file
        my ( $fh, $filename ) = tempfile();
        print $fh encode( 'UTF-8', $request_text );
        close $fh;
        $tempfile = $filename;
        app->log->debug("(server.pl) Text input saved to: $filename");
    }
    else {
        $c->render( text => "No text or file provided.", status => 400 );
        return;
    }

    # Run treetagger.pl with the temporary file
    my $output = `perl treetagger.pl $tempfile $dict $language`;

    # Ensure the output is properly decoded as UTF-8
    my $decoded_output = decode( 'UTF-8', $output );

    # Attempt to decode JSON output
    my $data;
    eval { $data = decode_json($decoded_output); };
    if ($@) {
        app->log->error("Failed to parse JSON: $@");
        $c->render( text =>
"Error processing request. Please check the logs for more details."
        );
        return;
    }

    # Pass the raw hash references to the template
    $c->stash(%$data);

    # Render result.html
    $c->render( template => 'result', format => 'html', handler => 'ep' );
};

# POST /process_file
post '/process_file' => sub {
    my $c = shift;

    my $upload = $c->req->upload('file');    # Use req->upload for file

    app->log->debug( "File param: " . ( $upload ? "exists" : "not provided" ) );

    # Remove request parameter to avoid interference
    $c->req->params->remove('request');
    if ( !$upload ) {
        $c->render( text => "No file provided.", status => 400 );
        return;
    }

    # Save the uploaded file to a temporary location
    my ( $fh, $filename ) = tempfile();
    path($filename)->spurt( $upload->asset->slurp );
    my $tempfile = $filename;
    app->log->debug("(server.pl) Uploaded file saved to: $filename");

    # Run treetagger.pl with the temporary file
    my $output = `perl treetagger.pl $tempfile $dict $language`;

    # Ensure the output is properly decoded as UTF-8
    my $decoded_output = decode( 'UTF-8', $output );

    # app->log->debug("(server.pl) Output ====: $decoded_output");

    # Attempt to decode JSON output
    my $data;
    eval { $data = decode_json($decoded_output); };
    if ($@) {
        app->log->error("Failed to parse JSON: $@");
        $c->render( text =>
"Error processing request. Please check the logs for more details."
        );
        return;
    }

    # Pass the raw hash references to the template
    $c->stash(%$data);

    # Render result.html
    $c->render( template => 'result', format => 'html', handler => 'ep' );
};

# GET /hello
get(
    '/hello',
    sub {
        my $c = shift;
        $c->render( 'text' => 'Hello!' );
    }
);

get(
    '/text',
    sub {
        my $c        = shift;
        my $filename = "files/pg13952.txt";

        # Open the file for reading
        open( my $fh, '<:encoding(utf-8)', $filename )
          or die "Could not open file '$filename' $!";
        my $txt = do { local $/; <$fh> };

        # Close the file
        close($fh);
        $c->render( 'text' => $txt );

    }
);

get(
    '/dict',
    sub {
        my $c        = shift;
        my $filename = "files/dict/fp.xml";

        # Open the file for reading
        open( my $fh, '<:encoding(utf-8)', $filename )
          or die "Could not open file '$filename' $!";
        my $xml = do { local $/; <$fh> };

        # Close the file
        close($fh);

        my $dom =
          Mojo::DOM->new($xml)->find('orth')->map('all_text')->join("\n");
        print $dom;
        $c->render( 'text' => $dom );

    }
);

# Graceful shutdown on SIGTERM
$SIG{TERM} = sub {
    app->log->info('Shutting down gracefully...');
    Mojo::IOLoop->singleton->stop_gracefully;
};

app->start;
