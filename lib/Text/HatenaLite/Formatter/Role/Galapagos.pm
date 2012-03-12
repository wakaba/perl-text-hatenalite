package Text::HatenaLite::Formatter::Role::Galapagos;
use strict;
use warnings;
our $VERSION = '1.0';
use Text::HatenaLite::Formatter::HTML;
use Encode;

BEGIN {
    *htescape = \&Text::HatenaLite::Formatter::HTML::htescape;
    *percent_encode_c = \&Text::HatenaLite::Formatter::HTML::percent_encode_c;
    *percent_encode_b = \&Text::HatenaLite::Formatter::HTML::percent_encode_b;
}

sub id_notation_to_html {
    my $values = $_[2];
    my $link_url = $_[0]->hatena_id_to_url($values->[1]);
    my $image_url = $_[0]->hatena_id_to_icon_url($values->[1]);
    return sprintf q{<a href="%s" class="user">id:%s</a>},
        htescape $link_url,
        htescape $values->[1];
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

sub ugomemo_movie_to_thumbnail_url {
    my ($self, $dsi_id, $file_name) = @_;
    return sprintf q<http://image.ugomemo.hatena.ne.jp/thumbnail/%s/%s_m.gif>,
        $dsi_id, $file_name;
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
