package Text::HatenaLite::Formatter::HTML;
use strict;
use warnings;
our $VERSION = '1.0';
use Encode;
use Mono::ID;
use WebService::ImageURLs;
use Text::HatenaLite::Definitions;
use Text::HatenaLite::Formatter::Role::URLs;
use Text::HatenaLite::Formatter::Base;
push our @ISA, qw(
  Text::HatenaLite::Formatter::Role::URLs
  Text::HatenaLite::Formatter::Base
);

my $Notations = {};
for my $def (@$Text::HatenaLite::Definitions::Notations) {
    $Notations->{$def->{type}} = $def;
}

$Notations->{text} = $Text::HatenaLite::Definitions::TextNotation;

sub htescape ($) {
    my $v = $_[0];
    $v =~ s{&}{&amp;}g;
    $v =~ s{<}{&lt;}g;
    $v =~ s{>}{&gt;}g;
    $v =~ s{\x22}{&#34;}g;
    return $v;
}

sub percent_decode_b ($) {
  my $s = ''.$_[0];
  utf8::encode ($s) if utf8::is_utf8 ($s);
  $s =~ s/%([0-9A-Fa-f]{2})/pack 'C', hex $1/ge;
  return $s;
}

# ------ Links ------

sub id_notation_to_html {
    my $values = $_[2];
    my $link_url = $_[0]->hatena_id_to_url($values->[1]);
    my $image_url = $_[0]->hatena_id_to_icon_url($values->[1]);
    return sprintf q{<a href="%s" class="user"><img src="%s" class=profile-image width=16 height=16 alt=""></a><a href="%s" class="user">id:%s</a>},
        htescape $link_url,
        htescape $image_url,
        htescape $link_url,
        htescape $values->[1];
}

sub keyword_notation_to_html {
    my $values = $_[2];
    my $link_url = $_[0]->keyword_to_link_url($values->[1]);
    return sprintf q{<a href="%s" class="keyword">%s</a>},
        htescape $link_url,
        htescape $values->[1];
}

sub mailto_notation_to_html {
    return sprintf q{<a href="mailto:%s">%s</a>},
        htescape $_[2]->[1],
        htescape $_[2]->[1];
}

# ------ Web pages ------

sub max_object_count { 4 }

sub url_to_page_link {
    my $self = $_[0];
    my $url = $_[2];
    my $title = $self->url_to_page_title($url);
    $title = $_[1] if not defined $title or not length $title;
    my $favicon_url = $self->url_to_page_favicon_url($url);
    return sprintf q{<a href="%s"><img src="%s" class=favicon width=16 height=16 alt=""></a><a href="%s">%s</a>},
        htescape $url,
        htescape $favicon_url,
        htescape $url,
        htescape $title;
}

sub http_notation_to_html {
    my $self = $_[0];
    my $url = $_[2]->[0];
    if ($url =~ /(?:[Jj][Pp][Ee]?[Gg]|[Gg][Ii][Ff]|[Pp][Nn][Gg]|[Bb][Mm][Pp])(?:\?[^\?]*)?$/) {
        return $self->image_url_to_html($url, $url, alt => $url);
    } elsif ($url =~ m{^[Hh][Tt][Tt][Pp][Ss]?://[0-9A-Za-z-]+\.[Yy][Oo][Uu][Tt][Uu][Bb][Ee]\.[Cc][Oo][Mm]/watch\?v=([0-9A-Za-z_-]+)}) {
        return $self->youtube_id_to_html($1, alt => $url);
    } elsif ($url =~ m{^[Hh][Tt][Tt][Pp]://[Yy][Oo][Uu][Tt][Uu]\.[Bb][Ee]/([A-Za-z0-9_-]+)}) {
        return $self->youtube_id_to_html($1, alt => $url);
    } elsif ($url =~ m{^[Hh][Tt][Tt][Pp]://[Ww][Ww][Ww]\.[Nn][Ii][Cc][Oo][Vv][Ii][Dd][Ee][Oo]\.[Jj][Pp]/watch/([0-9A-Za-z_]+)}) {
        return $self->nicovideo_id_to_html($1, alt => $url);
    } elsif ($url =~ m{^[Hh][Tt][Tt][Pp]://[Nn][Ii][Cc][Oo]\.[Mm][Ss]/([0-9A-Za-z_]+)}) {
        return $self->nicovideo_id_to_html($1, alt => $url);
    } elsif ($url =~ /[Mm][Pp]3(\?.*)?$/) {
        return $self->url_to_mp3_player($url);
    } elsif ($url =~ m{^[Hh][Tt][Tt][Pp]?://(?:[0-9A-Za-z-]\.)?(?:[Uu][Gg][Oo][Mm][Ee][Mm][Oo]|[Ff][Ll][Ii][Pp][Nn][Oo][Tt][Ee])\.[Hh][Aa][Tt][Ee][Nn][Aa]\.(?:[Nn][Ee]\.[Jj][Pp]|[Cc][Oo][Mm])/([0-9A-Fa-f]+)(?:\@|%40)DSi/movie/([0-9A-Za-z_-]+)(?:$|\?)}) {
        return $self->ugomemo_movie_to_html($1, $2, alt => $url);
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
        return $self->latlon_to_html($lat, $lon, alt => $url);
    } else {
        my $img_url = expand_image_permalink_url $url;
        if ($img_url) {
            return $self->image_url_to_html($img_url, $url, alt => $url);
        } else {
            return sprintf '<a href="%s">%s</a>',
                htescape $url, htescape $url;
        }
    }
}

sub httptitle_notation_to_html {
    my $values = $_[2];
    return sprintf q{<a href="%s">%s</a>},
        htescape $values->[1],
        htescape $values->[2];
}

sub httpbarcode_notation_to_html {
    my $values = $_[2];
    my $link_url = undef;
    my $url = $values->[1];
    my $barcode_url = $_[0]->url_to_qrcode_url ($url);
    return sprintf q{<a href="%s"><img src="%s" alt="%s" title="%s"></a>},
        htescape $url,
        htescape $barcode_url,
        htescape $url,
        htescape $url;
}

sub httpimage_notation_to_html {
    my $values = $_[2];
    my $link_url = undef;
    my $url = $values->[1];
    my $size = '';
    if ($values->[2] and $values->[2] =~ /^([HhWw])([0-9]+)$/) {
        $size = sprintf q< %s="%d">,
            (($1 eq 'h' || $1 eq 'H') ? 'height' : 'width'), $2;
    }
    $_[0]->image_url_to_html(
        $url, $link_url,
        alt => $values->[0],
        additional_attributes => $size,
    );
}

sub sound_button_label {
    return 'Download';
}

sub httpsound_notation_to_html {
    my $values = $_[2];
    return $_[0]->url_to_mp3_player(
        $values->[1],
        offset => [$values->[2], $values->[3], $values->[4]],
    );
}

sub url_to_mp3_player {
    my ($self, $url, %args) = @_;
    $self->{object_count}++;
    if ($self->{object_count} > $self->max_object_count) {
        return sprintf '<a href="%s">%s</a>',
            htescape $url,
            htescape($args{alt} || $url);
    }

    my $eurl = $url;
    $eurl =~ s/([&;='\x22<>\\%])/sprintf '%%%02X', ord $1/ge;
    my $flashvars = "mp3Url=$eurl";
    if ($args{offset}->[0] or $args{offset}->[1] or $args{offset}->[2]) {
        $flashvars .= sprintf "&timeOffset=%dh%dm%ds",
            $args{offset}->[0] || 0,
            $args{offset}->[1] || 0,
            $args{offset}->[2] || 0;
    }
    my $label = $self->sound_button_label;
    return sprintf q{<span style="vertical-align:middle;">
<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0" width="220" height="25" id="mp3_3" align="middle" style="vertical-align:bottom">
<param name="flashVars" value="%s">
<param name="allowScriptAccess" value="sameDomain">
<param name="movie" value="http://g.hatena.ne.jp/tools/mp3_3.swf">
<param name="quality" value="high">
<param name="bgcolor" value="#ffffff">
<param name="wmode" value="transparent">
<embed src="http://g.hatena.ne.jp/tools/mp3_3.swf" flashVars="%s" quality="high" wmode="transparent" bgcolor="#ffffff" width="220" height="25" name="mp3_3" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" style="vertical-align:bottom">
</object>
<a href="%s"><img src="http://g.hatena.ne.jp/images/podcasting.gif" title="%s" alt="%s" border="0" style="border:0px;vertical-align:bottom;"></a>
</span>},
    htescape $flashvars,
    htescape $flashvars,
    htescape $url,
    htescape $label,
    htescape $label;
}

sub idea_notation_to_html {
    return $_[0]->url_to_page_link($_[2]->[0] => $_[1]->{to_url}->($_[2]));
}

sub asin_to_html {
    my ($self, $asin, %args) = @_;
    my $label = defined $args{label}
        ? $args{label}
        : $self->asin_to_title($asin);
    $label = 'ASIN:' . $asin if not defined $label;
    my $link_url = $self->asin_to_url($asin);
    return sprintf q{<a href="%s"><img src="%s" class=favicon width=16 height=16 alt=""></a><a href="%s">%s</a>},
        htescape $link_url,
        htescape $self->asin_to_icon_url($asin),
        htescape $link_url,
        htescape $label;
}

sub play_video_button_image_html {
    return q{<img src="http://ugomemo.hatena.ne.jp/images/icon-views-s.gif" width=16 height=12 alt="">};
}

sub nicovideo_id_to_html {
    my ($self, $vid, %args) = @_;
    $self->{object_count}++;
    if ($self->{object_count} > $self->max_object_count) {
        my $nicovideo_url = $self->nicovideo_id_to_url($vid);
        return sprintf '<a href="%s">%s</a>',
            htescape($nicovideo_url),
            htescape($args{alt} || $nicovideo_url);
    } else {
        my $id = sprintf('nicovideo%d', int(rand(10000)));
        return sprintf q{<div id="%s"></div>
<script type="text/javascript"><!--
    function write%s(player) {
        var container = document.getElementById('%s');
        if (typeof player == 'string') {
            container.innerHTML = player;
        } else {
            container.innerHTML = player.getHTML();
        }
    }
//--></script>
<script src="http://www.nicovideo.jp/thumb_watch/%s?w=300&amp;h=238&amp;cb=write%s&amp;eb=write%s" charset="utf-8"></script>},
            $id, $id, $id, 
            htescape $vid,
            $id, $id;
    }
}

sub youtube_id_to_html {
    my ($self, $vid, %args) = @_;
    $self->{object_count}++;
    if ($self->{object_count} > $self->max_object_count) {
        my $youtube_url = $self->youtube_id_to_url($vid);
        return sprintf '<a href="%s">%s</a>',
            htescape($youtube_url),
            htescape($args{alt} || $youtube_url);
    } else {
        return sprintf q{<div class="video-body">
<object width="300" height="250"><param name="movie" value="http://www.youtube.com/v/%s"><param name="wmode" value="transparent"><embed src="http://www.youtube.com/v/%s" type="application/x-shockwave-flash" wmode="transparent" width="300" height="250"></object>
</div>},
            htescape $vid, htescape $vid;
    }
}

sub isbn_to_html {
    my $isbn = $_[1];
    my $asin = isbn_to_asin $isbn;
    return $_[0]->asin_to_html($asin, label => 'ISBN:' . $isbn) if $asin;
    return htescape('ISBN:' . $isbn);
}

sub asin_notation_to_html {
    my $asin = $_[2]->[1];
    $asin =~ tr/a-z-/A-Z/d;
    return htescape $_[2]->[0] unless is_asin $asin;
    return $_[0]->asin_to_html($asin);
}

sub isbn_notation_to_html {
    my $isbn = $_[2]->[1];
    $isbn =~ tr/a-z-/A-Z/d;
    return htescape $_[2]->[0] unless is_isbn $isbn;
    return $_[0]->isbn_to_html($isbn);
}

# ------ Media ------

sub image_url_to_html {
    my ($self, $url, $link_url, %args) = @_;
    $self->{object_count}++;
    if ($self->{object_count} > $self->max_object_count) {
        return sprintf '<a href="%s">%s</a>',
            htescape($link_url || $url),
            htescape(defined $args{alt} ? $args{alt} : $url);
    } else {
        return sprintf '<a href="%s"><img src="%s" alt="%s"%s></a>',
            htescape($link_url || $url),
            htescape $self->image_url_filter($url),
            htescape(defined $args{alt} ? $args{alt} : $url),
            $args{additional_attributes} || '';
    }
}

sub use_fotolife_movie_player { 1 }

sub fotolife_notation_to_html {
    my $self = $_[0];
    my $values = $_[2];
    
    my $img_url = $_[1]->{to_object_url}->($values);
    $img_url =~ s/\.flv$/,jpg/;

    my $link_url = $self->fotolife_id_to_url($values->[1], $values->[2]);
    
    my $img = $self->image_url_to_html(
        $img_url, $link_url,
        alt => $values->[0],
    );
    
    my $e = $values->[3];
    my $type = $values->[4] || '';
    if (($e eq 'f' or $e eq 'F') and
        $type =~ /^[Mm][Oo][vv][Ii][Ee]$/ and
        $self->use_fotolife_movie_player) {
        return sprintf q{<object data="http://f.hatena.ne.jp/tools/flvplayer_s.swf" type="application/x-shockwave-flash" width="320" height="276">
<param name="movie" value="http://f.hatena.ne.jp/tools/flvplayer_s.swf">
<param name="FlashVars" value="fotoid=%s&amp;user=%s">
<param name="wmode" value="transparent">
%s
</object>},
        htescape $values->[2],
        htescape $values->[1],
        $img;
    } else {
        return $img;
    }
}

sub land_notation_to_html {
    my $values = $_[2];
    my $image_url = $_[1]->{to_object_url}->($values);
    return $_[0]->image_url_to_html(
        $image_url, $image_url,
        alt => $values->[0],
    );
}

sub ugomemo_movie_to_html {
    my ($self, $dsi_id, $file_name, %args) = @_;
    $self->{object_count}++;
    if ($self->{object_count} > $self->max_object_count) {
        my $ugomemo_url = $self->ugomemo_movie_to_url($dsi_id, $file_name);
        return sprintf '<a href="%s">%s</a>',
            htescape($ugomemo_url),
            htescape($args{alt} || $ugomemo_url);
    } else {
        my $swf_url = $self->ugomemo_swf_url;
        return sprintf q{<object data="%s" type="application/x-shockwave-flash" width="279" height="240"><param name="movie" value="%s"><param name="FlashVars" value="did=%s&amp;file=%s"></object>},
            htescape $swf_url,
            htescape $swf_url,
            htescape $dsi_id,
            htescape $file_name;
    }
}

sub ugomemo_notation_to_html {
    my $values = $_[2];
    return $_[0]->ugomemo_movie_to_html(
        $values->[2], $values->[3], alt => $values->[0],
    );
}

sub latlon_to_html {
    my ($self, $lat, $lon, %args) = @_;
    $lat = $lat > 90 ? 90 : $lat < -90 ? -90 : $lat;
    $lon = $lon > 180 ? 180 : $lon < -180 ? -180 : $lon;
    $lat =~ s/\+//;
    $lon =~ s/\+//;
    my $link_url = $self->latlon_to_link_url($lat, $lon);

    $self->{object_count}++;
    if ($self->{object_count} > $self->max_object_count) {
        return sprintf '<div class=user-map><a href="%s">%s</a></div>',
            htescape $link_url,
            htescape($args{alt} || $link_url);
    }

    my $image_url = $self->latlon_to_image_url($lat, $lon);
    return sprintf q{<div class=user-map><a href="%s"><img src="%s" width=140 height=140 alt="%s"></a></div>},
        htescape $link_url,
        htescape $image_url,
        htescape(defined $args{alt} ? $args{alt} : 'map:' . $lat . ':' . $lon);
}

sub map_notation_to_html {
    my $values = $_[2];
    return $_[0]->latlon_to_html(
        $values->[1], $values->[2], alt => $values->[0],
    );
}

# ------ Serialization ------

sub as_text {
    my $self = shift;
    my $data = $self->parsed_data or die "|parsed_data| is not set";

    my @l;
    for my $node (@$data) {
        my $def = $Notations->{$node->{type}}
            or die "Definition for |$node->{type}| not found";
        my $code = $self->can($node->{type} . '_notation_to_html') || sub {
            my $text = htescape $_[2]->[0];
            $text =~ s/\x0D\x0A?/<br>/g;
            $text =~ s/\x0A/<br>/g;
            $text;
        };
        push @l, $self->$code($def, $node->{values});
    }

    return join '', @l;
}

1;
