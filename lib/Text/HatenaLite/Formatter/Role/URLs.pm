package Text::HatenaLite::Formatter::Role::URLs;
use strict;
use warnings;
our $VERSION = '1.0';
use Encode;
use WebService::ImageURLs;

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

sub percent_decode_b ($) {
    my $s = ''.$_[0];
    utf8::encode ($s) if utf8::is_utf8 ($s);
    $s =~ s/%([0-9A-Fa-f]{2})/pack 'C', hex $1/ge;
    return $s;
}

sub hatena_id_to_url {
    return q<http://www.hatena.ne.jp/> . $_[1] . q</>;
}

sub hatena_id_to_icon_url {
    return q<http://n.hatena.com/> . $_[1] . q</profile/image.gif?type=icon&size=16>;
}

sub id_notation_to_url_name_for_id_call {
    return $_[2]->[1];
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

sub latlon_to_geo_coords {
    my (undef, $lat, $lon) = @_;
    return undef if not defined $lat or not defined $lon;
    $lat =~ s/^\+//;
    $lon =~ s/^\+//;
    $lat = $lat > 90 ? 90 : $lat < -90 ? -90 : $lat;
    $lon = $lon > 180 ? 180 : $lon < -180 ? -180 : $lon;
    return [$lat, $lon];
}

sub map_notation_to_geo_coord {
    my $values = $_[2];
    return $_[0]->latlon_to_geo_coords(
        $values->[1], $values->[2],
    );
}

sub http_notation_to_geo_coord {
    my $self = $_[0];
    my $url = $_[2]->[0];
    my $parsed = $self->parse_http_url($url);
    
    if ($parsed->{map_lat} or $parsed->{map_lon}) {
        return $self->latlon_to_geo_coords(
            $parsed->{map_lat}, $parsed->{map_lon},
        );
    } else {
        return undef;
    }
}

sub http_notation_to_image_url {
    my $self = $_[0];
    my $url = $_[2]->[0];
    my $parsed = $self->parse_http_url($url);
    
    if ($parsed->{image_url}) {
        return $parsed->{image_url};
    } elsif ($parsed->{youtube_id}) {
        return $self->youtube_id_to_thumbnail_url($parsed->{youtube_id});
    } elsif ($parsed->{nicovideo_id}) {
        return $self->nicovideo_id_to_thumbnail_url($parsed->{nicovideo_id});
    } elsif ($parsed->{ugomemo_file_name}) {
        return $self->ugomemo_movie_to_thumbnail_url(
            $parsed->{ugomemo_dsi_id},
            $parsed->{ugomemo_file_name},
        );
    } else {
        return undef;
    }
}

sub http_notation_to_url_name_for_id_call {
    my $self = $_[0];
    my $url = $_[2]->[0];
    if ($url =~ m{
        [Hh][Tt][Tt][Pp][Ss]?://
        (?:[Hh]2?|[Nn]|[Cc]|[Oo][Nn][Ee])
        \.[Hh][Aa][Tt][Ee][Nn][Aa]\.(?:[Nn][Ee]\.[Jj][Pp]|[Cc][Oo][Mm])/
        (?:touch/|mobile/|)
        ([0-9A-Za-z_@%-]+)/
    }x) {
        my $url_name = $1;
        $url_name =~ s/%40/\@/g;
        return $url_name;
    } else {
        return undef;
    }
}

sub asin_to_icon_url {
    # http://h.hatena.ne.jp/asin/{asin}/icon
    # http://h.hatena.ne.jp/asin/{asin}/thumbnail
    return sprintf q<http://h.hatena.ne.jp/asin/%s/icon>, $_[1];
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

sub fotolife_notation_to_url {
    my $self = $_[0];
    my $values = $_[2];
    return $self->fotolife_id_to_url($values->[1], $values->[2]);
}

sub fotolife_notation_to_image_url {
    my $img_url = $_[1]->{to_object_url}->($_[2]);
    $img_url =~ s/\.flv$/.jpg/;
    return $img_url;
}

sub fotolife_id_to_url {
    return sprintf q<http://f.hatena.ne.jp/%s/%s>, $_[1], $_[2];
}

sub land_notation_to_url {
    return $_[1]->{to_object_url}->($_[2]);
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

sub ugomemo_notation_to_image_url {
    my $values = $_[2];
    return $_[0]->ugomemo_movie_to_thumbnail_url(
        $values->[2], $values->[3],
    );
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

sub parse_http_url {
    my $url = $_[1];
    my $parsed = {};

    if ($url =~ /(?:[Jj][Pp][Ee]?[Gg]|[Gg][Ii][Ff]|[Pp][Nn][Gg]|[Bb][Mm][Pp])(?:\?[^\?]*)?$/) {
        $parsed->{image_url} = $url;
    } elsif ($url =~ m{^[Hh][Tt][Tt][Pp][Ss]?://[0-9A-Za-z-]+\.[Yy][Oo][Uu][Tt][Uu][Bb][Ee]\.[Cc][Oo][Mm]/watch\?v=([0-9A-Za-z_-]+)}) {
        $parsed->{youtube_id} = $1;
    } elsif ($url =~ m{^[Hh][Tt][Tt][Pp]://[Yy][Oo][Uu][Tt][Uu]\.[Bb][Ee]/([A-Za-z0-9_-]+)}) {
        $parsed->{youtube_id} = $1;
    } elsif ($url =~ m{^[Hh][Tt][Tt][Pp]://[Mm]\.[Yy][Oo][Uu][Tt][Uu][Bb][Ee]\.[Cc][Oo][Mm]/watch\?(?:.*?&)?v=([0-9A-Za-z_-]+)}) {
        # http://m.youtube.com/watch?gl=JP&hl=ja&client=mv-google&v=wTQpaFfxjs8
        $parsed->{youtube_id} = $1;
    } elsif ($url =~ m{^[Hh][Tt][Tt][Pp]://(?:[Ww][Ww][Ww]|[Ss][Pp])\.[Nn][Ii][Cc][Oo][Vv][Ii][Dd][Ee][Oo]\.[Jj][Pp]/watch/([0-9A-Za-z_]+)}) {
        # http://www.nicovideo.jp/watch/sm12345
        # http://sp.nicovideo.jp/watch/sm12345
        $parsed->{nicovideo_id} = $1;
    } elsif ($url =~ m{^[Hh][Tt][Tt][Pp]://[Nn][Ii][Cc][Oo]\.[Mm][Ss]/([0-9A-Za-z_]+)}) {
        $parsed->{nicovideo_id} = $1;
    } elsif ($url =~ /[Mm][Pp]3(?:\?.*)?$/) {
        $parsed->{mp3_url} = $url;
    } elsif ($url =~ m{^[Hh][Tt][Tt][Pp]?://(?:[0-9A-Za-z-]\.)?(?:[Uu][Gg][Oo][Mm][Ee][Mm][Oo]|[Ff][Ll][Ii][Pp][Nn][Oo][Tt][Ee])\.[Hh][Aa][Tt][Ee][Nn][Aa]\.(?:[Nn][Ee]\.[Jj][Pp]|[Cc][Oo][Mm])/([0-9A-Fa-f]+)(?:\@|%40)DSi/movie/([0-9A-Za-z_-]+)(?:$|\?)}) {
        $parsed->{ugomemo_dsi_id} = $1;
        $parsed->{ugomemo_file_name} = $2;
    } elsif ($url =~ m{^http://docomo\.ne\.jp/cp/map\.cgi\?lat=([^&]+)&lon=([^&]+)&geo=[Ww][Gg][Ss]84$}) {
        ## See
        ## <http://www.nttdocomo.co.jp/service/imode/make/content/browser/html/tag/location_info.html>.
        my $lat = percent_decode_b $1;
        my $lon = percent_decode_b $2;
        if ($lat =~ /^([+-][0-9]+)\.([0-9]+)\.([0-9]+\.[0-9]+)$/) {
            $lat = $1 + ($2 / 60) + ($3 / 60 / 60);
        }
        if ($lon =~ /^([+-][0-9]+)\.([0-9]+)\.([0-9]+\.[0-9]+)$/) {
            $lon = $1 + ($2 / 60) + ($3 / 60 / 60);
        }
        $parsed->{map_lat} = $lat;
        $parsed->{map_lon} = $lon;
    } else {
        my $img_url = expand_image_permalink_url $url;
        if ($img_url) {
            $parsed->{image_url} = $img_url;
        }
    }
    
    return $parsed;
}

1;
