package Text::HatenaLite::Formatter::Role::NoFlash;
use strict;
use warnings;
our $VERSION = '1.0';
use Text::HatenaLite::Formatter::HTML;
use Encode;

BEGIN {
    *htescape = \&Text::HatenaLite::Formatter::HTML::htescape;
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

sub use_fotolife_movie_player { 0 }

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

1;
