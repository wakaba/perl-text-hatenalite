package Text::HatenaLite::Formatter::HTML;
use strict;
use warnings;
our $VERSION = '1.0';
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

sub ugomemo_swf_url {
    return $_[1]->[1] eq 'ugomemo'
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
