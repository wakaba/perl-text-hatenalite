package Text::HatenaLite::Formatter::Role::URLs;
use strict;
use warnings;
our $VERSION = '1.0';
use Encode;

sub percent_encode_c ($) {
    my $s = encode ('utf-8', ''.$_[0]);
    $s =~ s/([^0-9A-Za-z._~-])/sprintf '%%%02X', ord $1/ge;
    return $s;
}

sub percent_encode_b ($) {
    my $s = ''.$_[0];
    $s =~ s/([^0-9A-Za-z._~-])/sprintf '%%%02X', ord $1/ge;
    return $s;
}

sub hatena_id_to_url {
    return q<http://www.hatena.ne.jp/> . $_[1] . q</>;
}

sub hatena_id_to_icon_url {
    return q<http://n.hatena.com/> . $_[1] . q</profile/image.gif?type=icon&size=16>;
}

sub keyword_to_link_url {
    return q<http://d.hatena.ne.jp/keyword/> .
        percent_encode_b encode 'euc-jp', $_[1];
}

sub url_to_page_title {
    return undef;
}

sub url_to_page_favicon_url {
    return q<http://cdn-ak.favicon.st-hatena.com/?url=> . percent_encode_c $_[1];
}

sub url_to_qrcode_url {
    return q<https://www.hatena.ne.jp/api/barcode?str=> .
        percent_encode_c $_[1];
}

sub asin_to_icon_url {
    return sprintf q<http://h.hatena.ne.jp/asin/%s/image.icon>, $_[1];
}

sub asin_to_url {
    return sprintf q<http://h.hatena.ne.jp/asin/%s>, $_[1];
}

sub asin_to_title {
    return undef;
}

sub nicovideo_id_to_url {
    my ($self, $vid) = @_;
    return sprintf q<http://www.nicovideo.jp/watch/%s>, $vid;
}

sub nicovideo_id_to_thumbnail_url {
    my ($self, $vid) = @_;
    if ($vid =~ s/^[Ss][Mm]//) {
        return sprintf q<http://tn-skr4.smilevideo.jp/smile?i=%s>, $vid;
    } else {
        return undef;
    }
}

sub youtube_id_to_url {
    my ($self, $vid) = @_;
    return sprintf q<http://www.youtube.com/watch?v=%s>, $vid;
}

sub youtube_id_to_thumbnail_url {
    my ($self, $vid) = @_;
    return sprintf q<http://i4.ytimg.com/vi/%s/default.jpg>, $vid;
}

sub image_url_filter { $_[1] }

sub fotolife_id_to_url {
    return sprintf q<http://f.hatena.ne.jp/%s/%s>, $_[1], $_[2];
}

sub ugomemo_swf_url {
    return q<http://ugomemo.hatena.ne.jp/js/ugoplayer_s.swf>;
    #q<http://flipnote.hatena.com/js/flipplayer_s.swf>;
}

sub ugomemo_movie_to_url {
    my ($self, $dsi_id, $file_name) = @_;
    return sprintf q<http://ugomemo.hatena.ne.jp/%s@DSi/movie/%s>,
        $dsi_id, $file_name;
}

sub ugomemo_movie_to_thumbnail_url {
    my ($self, $dsi_id, $file_name) = @_;
    return sprintf q<http://image.ugomemo.hatena.ne.jp/thumbnail/%s/%s_o.gif>,
        $dsi_id, $file_name;
}

sub latlon_to_image_url {
    # <http://code.google.com/intl/ja/apis/maps/documentation/staticmaps/>.
    return sprintf q<http://maps.google.com/maps/api/staticmap?markers=%s,%s&sensor=false&size=140x140&maptype=mobile&zoom=13&format=png>,
        $_[1], $_[2]; # lat, lon
}

sub latlon_to_link_url {
    return sprintf q<http://maps.google.com/?ll=%s,%s>,
        $_[1], $_[2]; # lat, lon
}

1;
