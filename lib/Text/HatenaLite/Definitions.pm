package Text::HatenaLite::Definitions;
use strict;
use warnings;
our $VERSION = '1.0';

my $http_pattern = q<[Hh][Tt][Tt][Pp][Ss]?:\/\/[0-9A-Za-z_~/.?&=\-%#+:;,@'!\$]+>;

our $Notations = [
    {
        type => 'id',
        pattern => q<[Ii][Dd]:([0-9a-zA-Z_\@-]+)>,
    },
    {
        type => 'http',
        pattern => $http_pattern,
    },
    {
        type => 'httptitle',
        pattern => q<\[(> . $http_pattern . q<):[Tt][Ii][Tt][Ll][Ee]=([^\]]+)\]>,
        to_url => sub { $_[0]->[1] },
        to_text => sub { $_[1]->[2] . ' ' . $_[0]->{to_url}->($_[1]) },
    },
    {
        type => 'httpimage',
        pattern => q<\[(> . $http_pattern . q<(?:[Jj][Pp][Ee]?[Gg]|[Gg][Ii][Ff]|[Pp][Nn][Gg]|[Bb][Mm][Pp])):[Ii][Mm][Aa][Gg][Ee](?::([HhWw][0-9]+))?\]>,
        to_url => sub { $_[0]->[1] },
        to_text => sub { $_[0]->{to_url}->($_[1]) },
    },
    {
        type => 'httpsound',
        pattern => q<\[(> . $http_pattern . q<[Mm][Pp]3):[Ss][Oo][Uu][Nn][Dd](?::(?:([0-9]+)[Hh]|())(?:([0-9]+)[Mm]|())(?:([0-9]+)[Ss]|()))?\]>,
        to_url => sub { $_[0]->[1] },
        to_text => sub { $_[0]->{to_url}->($_[1]) },
    },
    {
        type => 'idea',
        pattern => q<[Ii][Dd][Ee][Aa]:([0-9]+)(?::[Tt][Ii][Tt][Ll][Ee])?>,
        to_url => sub {
            return q<http://i.hatena.ne.jp/idea/> . $_[0]->[1];
        },
        to_text => sub { $_[0]->{to_url}->($_[1]) },
    },
    {
        type => 'fotolife',
        pattern => q<[Ff]:[Ii][Dd]:([-_a-zA-Z0-9]+):([0-9]+)([PpJjGg]):[Ii][Mm][Aa][Gg][Ee]>,
        to_object_url => sub {
            my $v = $_[0];
            my $ext = 'jpg';
            if (my $e = $v->[3]) {
                if ($e eq 'p' or $e eq 'P') {
                    $ext = 'png';
                } elsif ($e eq 'g' or $e eq 'G') {
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
        type => 'land',
        pattern => q<[Ll][Aa][Nn][Dd]:[Ii][Mm][Aa][Gg][Ee]:([a-fA-F0-9]{40}):([0-9A-Za-z_-]+)>,
        to_object_url => sub {
            my $v = $_[0];
            return sprintf q<http://l.hatena.ne.jp/images/%s.%s>,
                $v->[1], $v->[2];
        },
        to_text => sub { $_[0]->{to_object_url}->($_[1]) },
    },
    {
        type => 'map',
        pattern => q<[Mm][Aa][Pp]:([0-9+.-]+):([0-9+.-]+)>,
    },
    {
        type => 'ugomemo',
        pattern => q<([Uu][Gg][Oo][Mm][Ee][Mm][Oo]|[Ff][Ll][Ii][Pp][Nn][Oo][Tt][Ee]):([0-9A-F]{16}):([0-9A-F_]+)>,
        to_url => sub {
            my $v = $_[0];
            return sprintf q<http://%s/%s@DSi/movie/%s>,
                ($v->[1] =~ /[Uu]/
                    ? 'ugomemo.hatena.ne.jp' : 'flipnote.hatena.com'),
                $v->[2],
                $v->[3];
        },
        to_text => sub { $_[0]->{to_url}->($_[1]) },
    },
    {
        type => 'keyword',
        pattern => q<\[[Kk][Ee][Yy][Ww][Oo][Rr][Dd]:([^\]]+)\]>,
        to_text => sub { $_[1]->[1] },
    },
    {
        type => 'keyword',
        pattern => q<\[\[([^\]]+)\]\]>,
        to_text => sub { $_[1]->[1] },
    },
    {
        type => 'mailto',
        pattern => q<[Mm][Aa][Ii][Ll][Tt][Oo]:([0-9A-Za-z_\.-]+\@[0-9A-Za-z_][0-9A-Za-z_\.\-]*[0-9A-Za-z_])>,
    },
];

our $TextNotation = {
    to_text => sub { $_[1]->[0] },
};

1;
