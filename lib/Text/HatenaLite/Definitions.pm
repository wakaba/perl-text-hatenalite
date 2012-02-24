package Text::HatenaLite::Definitions;
use strict;
use warnings;
our $VERSION = '1.0';

our $Notations = [
    {
        type => 'id',
        pattern => q<id:([0-9a-zA-Z_\@-]+)>,
    },
    {
        type => 'fotolife',
        pattern => q<f:id:([a-zA-Z][-_a-zA-Z0-9]*):([0-9]+)([pjg]):image>,
        to_object_url => sub {
            my $v = $_[0];
            my $ext = 'jpg';
            if (my $e = $v->[3]) {
                if ($e eq 'p') {
                    $ext = 'png';
                } elsif ($e eq 'g') {
                    $ext = 'gif';
                }
            }
            return sprintf q<http://cdn-ak.f.st-hatena.com/images/fotolife/%s/%s/%s/%s.%s>,
                substr($v->[1], 0, 1),
                $v->[1],
                substr($v->[2], 0, 8),
                $v->[2],
                $ext;
        },
        to_text => sub { $_[0]->{to_object_url}->($_[1]) },
    },
    {
        type => 'http',
        pattern => q<https?:\/\/[0-9A-Za-z_~/.?&=\-%#+:;,@'!\$]+>,
    },
    {
        type => 'land',
        pattern => q<land:image:([a-fA-F0-9]{40}):([0-9A-Za-z_-]+)>,
    },
    {
        type => 'map',
        pattern => q<map:([0-9+.-]+):([0-9+.-]+)>,
    },
    {
        type => 'ugomemo',
        pattern => q<(ugomemo|flipnote):([0-9A-F]{16}):([0-9A-F_]+)>,
        to_url => sub {
            my $v = $_[0];
            return sprintf q<http://%s/%s@DSi/movie/%s>,
                $v->[1] eq 'ugomemo'
                    ? 'ugomemo.hatena.ne.jp' : 'flipnote.hatena.com',
                $v->[2],
                $v->[3];
        },
        to_text => sub { $_[0]->{to_url}->($_[1]) },
    },
];

our $TextNotation = {
    to_text => sub { $_[1]->[0] },
};

1;
