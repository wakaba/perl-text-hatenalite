package Text::HatenaLite::Formatter::HTML;
use strict;
use warnings;
our $VERSION = '1.0';
use Encode;
use Text::HatenaLite::Definitions;
use Text::HatenaLite::Formatter::Base;
push our @ISA, qw(Text::HatenaLite::Formatter::Base);

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

sub percent_encode_c ($) {
    my $s = encode ('utf-8', ''.$_[0]);
    $s =~ s/([^0-9A-Za-z._~-])/sprintf '%%%02X', ord $1/ge;
    return $s;
}

# ------ Links ------

sub hatena_id_to_url {
    return q<http://www.hatena.ne.jp/> . $_[1]->[1] . q</>;
}

sub hatena_id_to_icon_url {
    return q<http://n.hatena.com/> . $_[1]->[1] . q</profile/image.gif?type=icon&size=16>;
}

sub id_notation_to_html {
    my $values = $_[2];
    my $link_url = $_[0]->hatena_id_to_url($values);
    my $image_url = $_[0]->hatena_id_to_icon_url($values);
    return sprintf q{<a href="%s" class="user"><img src="%s" class=profile-image width=16 height=16 alt=""></a><a href="%s" class="user">id:%s</a>},
        htescape $link_url,
        htescape $image_url,
        htescape $link_url,
        htescape $values->[1];
}

sub keyword_to_link_url {
    return q<http://d.hatena.ne.jp/keyword/> . percent_encode_c $_[1];
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

sub url_to_page_title {
    return undef;
}

sub url_to_page_favicon_url {
    return q<http://cdn-ak.favicon.st-hatena.com/?url=> . percent_encode_c $_[1];
}

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

sub httptitle_notation_to_html {
    my $values = $_[2];
    return sprintf q{<a href="%s">%s</a>},
        htescape $values->[1],
        htescape $values->[2];
}

sub sound_button_label {
    return 'Download';
}

sub httpsound_notation_to_html {
    my $values = $_[2];
    my $url = $values->[1];
    my $eurl = $url;
    $eurl =~ s/([&;='\x22<>\\%])/sprintf '%%%02X', ord $1/ge;
    my $flashvars = "mp3Url=$eurl";
    if ($values->[2] or $values->[3] or $values->[4]) {
        $flashvars .= sprintf "&timeOffset=%dh%dm%ds",
            $values->[2] || 0,
            $values->[3] || 0,
            $values->[4] || 0;
    }
    my $label = $_[0]->sound_button_label;

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

# ------ Media ------

sub image_url_to_html {
    my (undef, $orig => $url) = @_;
    return sprintf q{<a href="%s"><img src="%s" alt="%s"></a>},
        htescape $url,
        htescape $url,
        htescape $orig;
}

sub land_notation_to_html {
    my $values = $_[2];
    return $_[0]->image_url_to_html($values->[0] => $_[1]->{to_object_url}->($values));
}

sub ugomemo_swf_url {
    return $_[1]->[1] =~ /[Uu]/
        ? q<http://ugomemo.hatena.ne.jp/js/ugoplayer_s.swf>
        : q<http://flipnote.hatena.com/js/flipplayer_s.swf>;
}

sub ugomemo_notation_to_html {
    my $values = $_[2];
    my $swf_url = $_[0]->ugomemo_swf_url($values);
    return sprintf q{<object data="%s" type="application/x-shockwave-flash" width="279" height="240"><param name="movie" value="%s"><param name="FlashVars" value="did=%s&amp;file=%s"></object>},
        htescape $swf_url,
        htescape $swf_url,
        htescape $values->[2],
        htescape $values->[3];
}

sub latlon_to_image_url {
    # <http://code.google.com/intl/ja/apis/maps/documentation/staticmaps/>.
    return sprintf q<http://maps.google.com/maps/api/staticmap?markers=%s,%s&sensor=false&size=140x140&maptype=mobile&zoom=13&format=png>,
        $_[1], $_[2]; # lat, lon
}

sub latlon_to_link_url {
    #sprintf q<http://map.mobile.yahoo.co.jp/mpl?lat=%s&lon=%s&datum=wgs>,
    #    $lat, $lon;
    return sprintf q<http://maps.google.com/?ll=%s,%s>,
        $_[1], $_[2]; # lat, lon
}

sub map_notation_to_html {
    my ($self, undef, $values) = @_;
    my $lat = $values->[1];
    my $lon = $values->[2];
    $lat = $lat > 90 ? 90 : $lat < -90 ? -90 : $lat;
    $lon = $lon > 180 ? 180 : $lon < -180 ? -180 : $lon;

    my $image_url = $self->latlon_to_image_url($lat, $lon);
    my $link_url = $self->latlon_to_link_url($lat, $lon);
    return sprintf q{<div class=user-map><a href="%s"><img src="%s" width=140 height=140 alt="%s"></a></div>},
        htescape $link_url,
        htescape $image_url,
        htescape $values->[0];
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
            return htescape $_[2]->[0];
        };
        push @l, $self->$code($def, $node->{values});
    }

    return join '', @l;
}

1;
