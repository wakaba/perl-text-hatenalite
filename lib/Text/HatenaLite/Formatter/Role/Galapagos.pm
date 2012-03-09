package Text::HatenaLite::Formatter::Role::Galapagos;
use strict;
use warnings;
use Text::HatenaLite::Formatter::HTML;
use Encode;

BEGIN {
    *htescape = \&Text::HatenaLite::Formatter::HTML::htescape;
    *percent_encode_c = \&Text::HatenaLite::Formatter::HTML::percent_encode_c;
    *percent_encode_b = \&Text::HatenaLite::Formatter::HTML::percent_encode_b;
}

sub hatena_id_to_url {
    return q<http://www.hatena.ne.jp/mobile/> . $_[1]->[1] . q</>;
}

sub id_notation_to_html {
    my $values = $_[2];
    my $link_url = $_[0]->hatena_id_to_url($values);
    my $image_url = $_[0]->hatena_id_to_icon_url($values);
    return sprintf q{<a href="%s" class="user">id:%s</a>},
        htescape $link_url,
        htescape $values->[1];
}

sub keyword_to_link_url {
    return q<http://d.hatena.ne.jp/keywordmobile/> .
        percent_encode_b encode 'cp932', $_[1];
}

sub asin_to_url {
    return sprintf q<http://h.hatena.ne.jp/mobile/asin/%s>, $_[1];
}

sub asin_to_html {
    my ($self, $asin, %args) = @_;
    my $label = defined $args{label} ? $args{label} : 'ASIN:' . $asin;
    my $link_url = $self->asin_to_url($asin);
    return sprintf q{<a href="%s">%s</a>},
        htescape $link_url,
        htescape $label;
}

sub url_to_page_link {
    my $self = $_[0];
    my $url = $_[2];
    my $title = $self->url_to_page_title($url);
    $title = $_[1] if not defined $title or not length $title;
    my $favicon_url = $self->url_to_page_favicon_url($url);
    return sprintf q{<a href="%s">%s</a>},
        htescape $url,
        htescape $title;
}

sub url_to_mp3_player {
    my ($self, $url, %args) = @_;
    return sprintf '<a href="%s">%s</a>',
        htescape $url,
        htescape($args{alt} || $url);
}

sub nicovideo_id_to_html {
    my ($self, $vid, %args) = @_;
    my $nicovideo_url = $self->nicovideo_id_to_url($vid);
    $self->{object_count}++;
    if ($self->{object_count} > $self->max_object_count) {
        #
    } else {
        my $thumbnail_url = $self->nicovideo_id_to_thumbnail_url($vid);
        if ($thumbnail_url) {
            return sprintf q{<a href="%s"><img src="%s" alt="%s">%s</a>},
                htescape $nicovideo_url,
                htescape $thumbnail_url,
                htescape($args{alt} || $nicovideo_url),
                $self->play_video_button_image_html;
        }
    }
    return sprintf '<a href="%s">%s</a>',
        htescape($nicovideo_url),
        htescape($args{alt} || $nicovideo_url);
}

sub youtube_id_to_html {
    my ($self, $vid, %args) = @_;
    my $youtube_url = $self->youtube_id_to_url($vid);
    $self->{object_count}++;
    if ($self->{object_count} > $self->max_object_count) {
        return sprintf '<a href="%s">%s</a>',
            htescape($youtube_url),
            htescape($args{alt} || $youtube_url);
    } else {
        my $thumbnail_url = $self->youtube_id_to_thumbnail_url($vid);
        return sprintf q{<a href="%s"><img src="%s" alt="%s">%s</a>},
            htescape $youtube_url,
            htescape $thumbnail_url,
            htescape($args{alt} || $youtube_url),
            $self->play_video_button_image_html;
    }
}

sub image_url_filter {
    my $url = $_[1];
    if ($url =~ m{^(http://cdn-ak\.f\.st-hatena\.com/images/fotolife/./[^/]+/[0-9]+/[0-9]+)\.(?:jpg|png|gif)$}) {
        return $1 . '_120.jpg';
    } elsif ($url =~ m{^http://(?:[0-9A-Za-z.-]+\.|)n\.hatena\.com/[^/]+/profile/image}) {
        return $url;
    } elsif ($url =~ m{^http://maps\.google\.com/}) {
        $url =~ s/\bformat=png\b/format=gif/g;
        return $url;
    } else {
        return sprintf q{http://mgw.hatena.ne.jp/?url=%s},
            percent_encode_c $url;
    }
}

sub fotolife_id_to_url {
    return sprintf q<http://f.hatena.ne.jp/mobile/%s/%s>, $_[1], $_[2];
}

sub use_fotolife_movie_player { 0 }

sub ugomemo_movie_to_url {
    my ($self, $dsi_id, $file_name) = @_;
    return sprintf q<http://ugomemo.hatena.ne.jp/mobile/%s@DSi/movie/%s>,
        $dsi_id, $file_name;
}

sub ugomemo_movie_to_thumbnail_url {
    my ($self, $dsi_id, $file_name) = @_;
    return sprintf q<http://image.ugomemo.hatena.ne.jp/thumbnail/%s/%s_m.gif>,
        $dsi_id, $file_name;
}

sub ugomemo_movie_to_html {
    my ($self, $dsi_id, $file_name, %args) = @_;
    $self->{object_count}++;
    my $ugomemo_url = $self->ugomemo_movie_to_url($dsi_id, $file_name);
    if ($self->{object_count} > $self->max_object_count) {
        return sprintf '<a href="%s">%s</a>',
            htescape($ugomemo_url),
            htescape($args{alt} || $ugomemo_url);
    } else {
        my $thumbnail_url = $self->ugomemo_movie_to_thumbnail_url($dsi_id, $file_name);
        return sprintf q{<a href="%s"><img src="%s" alt="%s">%s</a>},
            htescape $ugomemo_url,
            htescape $thumbnail_url,
            htescape($args{alt} || $ugomemo_url),
            $self->play_video_button_image_html;
    }
}

sub latlon_to_image_url {
    # <http://code.google.com/intl/ja/apis/maps/documentation/staticmaps/>.
    return sprintf q<http://maps.google.com/maps/api/staticmap?markers=%s,%s&sensor=false&size=140x140&maptype=mobile&zoom=13&format=gif>,
        $_[1], $_[2]; # lat, lon
}

sub latlon_to_link_url {
    return sprintf q<http://map.mobile.yahoo.co.jp/mpl?lat=%s&lon=%s&datum=wgs>,
        $_[1], $_[2]; # lat, lon
}

1;
