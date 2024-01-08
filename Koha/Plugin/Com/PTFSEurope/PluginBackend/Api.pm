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

    my $metadata = decode_json( decode_base64( uri_unescape( $controller->validation->param('metadata') || '' ) ) );

    # Example of missing required metadata for availability check
    unless ( $metadata->{doi} || $metadata->{pubmedid} ) {
        return $controller->render(
            status  => 400,
            openapi => {
                error => 'Missing required ISBN input data',
            }
        );
    }

    # 50% of the time will return success
    if ( rand(100) >= 50){
        return $controller->render(
            status  => 200,
            openapi => {
                success => '',
            }
        );
    # 50% of the time will return unavailable
    }else{
        return $controller->render(
            status  => 404,
            openapi => {
                error => 'Provided ISBN is not available in PluginBackend',
            }
        );
    }
}

1;