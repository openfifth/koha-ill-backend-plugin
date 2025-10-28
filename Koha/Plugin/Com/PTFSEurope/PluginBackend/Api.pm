package Koha::Plugin::Com::PTFSEurope::PluginBackend::Api;

use strict;
use warnings;

use JSON         qw( decode_json );
use MIME::Base64 qw( decode_base64 );
use URI::Escape  qw ( uri_unescape );

use Mojo::Base 'Mojolicious::Controller';

sub ill_backend_availability {
    my $controller = shift->openapi->valid_input or return;

    # Wait 2 seconds to simulate a real request to a third-party provider
    sleep(2);

    my $metadata = decode_json(
        decode_base64(
            uri_unescape( $controller->validation->param('metadata') || '' )
        )
    );

    my $title = $metadata->{title};

    # If title is defined, handle specific logic
    if (defined $title) {

        if (lc $title eq 'yellow') {
            return $controller->render(
                status  => 200,
                openapi => {
                    warning => 'Can be placed but will go through manual verification',
                }
            );

        } elsif (lc $title eq 'red') {
            return $controller->render(
                status  => 400,
                openapi => {
                    error => 'Missing required ISBN input data',
                }
            );

        } elsif (lc $title eq 'green') {
            return $controller->render(
                status  => 200,
                openapi => {
                    success => '',
                }
            );
        }
    }

    my $rand = rand(100);
    if ( $rand < 33.3 ) {
        return $controller->render(
            status  => 200,
            openapi => { success => '' },
        );
    } elsif ( $rand < 66.6 ) {
        return $controller->render(
            status  => 200,
            openapi => { warning => 'Can be placed but will go through manual verification' },
        );
    } else {
        return $controller->render(
            status  => 404,
            openapi => { error => 'Provided ISBN is not available in PluginBackend' },
        );
    }
}

1;