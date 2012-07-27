package Text::HatenaLite::Formatter::HTML::Smartphones;
use strict;
use warnings;
our $VERSION = '1.0';
use Text::HatenaLite::Formatter::HTML;
use Text::HatenaLite::Formatter::Role::NoFlash;
use Text::HatenaLite::Formatter::Role::HatenaTouch;
push our @ISA, qw(
    Text::HatenaLite::Formatter::Role::NoFlash
    Text::HatenaLite::Formatter::Role::HatenaTouch
    Text::HatenaLite::Formatter::HTML
);

# width=320 iPhone/3DS
# width=240 DSi
sub default_youtube_widget_width { 200 }
sub default_youtube_widget_height { 160 }

1;
