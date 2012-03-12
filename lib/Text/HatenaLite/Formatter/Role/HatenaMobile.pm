package Text::HatenaLite::Formatter::Role::HatenaMobile;
use strict;
use warnings;
our $VERSION = '1.0';
use Text::HatenaLite::Formatter::HTML;
use Encode;

BEGIN {
    *percent_encode_b = \&Text::HatenaLite::Formatter::HTML::percent_encode_b;
}

sub hatena_id_to_url {
    return q<http://www.hatena.ne.jp/mobile/> . $_[1] . q</>;
}

sub keyword_to_link_url {
    return q<http://d.hatena.ne.jp/keywordmobile/> .
        percent_encode_b encode 'cp932', $_[1];
}

sub asin_to_url {
    return sprintf q<http://h.hatena.ne.jp/mobile/asin/%s>, $_[1];
}

sub fotolife_id_to_url {
    return sprintf q<http://f.hatena.ne.jp/mobile/%s/%s>, $_[1], $_[2];
}

sub ugomemo_movie_to_url {
    my ($self, $dsi_id, $file_name) = @_;
    return sprintf q<http://ugomemo.hatena.ne.jp/mobile/%s@DSi/movie/%s>,
        $dsi_id, $file_name;
}

1;
