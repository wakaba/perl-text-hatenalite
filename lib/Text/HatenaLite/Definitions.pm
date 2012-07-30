package Text::HatenaLite::Definitions;
use strict;
use warnings;
our $VERSION = '1.0';

my $http_pattern = q<[Hh][Tt][Tt][Pp][Ss]?:\/\/[0-9A-Za-z_~/.?&=\-%#+:;,@'!\$\(\)\*]+>;

our $Notations = [
    {
        type => 'id',
        pattern => q<[Ii][Dd]:([0-9a-zA-Z_\@-]+)(?::[Dd][Ee][Tt][Aa][Ii][Ll])?>,
    },
    {
        type => 'http',
        pattern => q<((?:[Hh][Tt]|[Ff])[Tt][Pp][Ss]?:\/\/[0-9A-Za-z_~/.?&=\-%#+:;,@'!\$]+)>,
        postprocess => sub {
            if ($_[0]->[1] =~ s/:([Mm][Oo][Vv][Ii][Ee])\z//) {
                $_[0]->[2] = $1;
            }
        },
        to_url => sub { $_[0]->[1] },
        is_skipped_object => 1,
        allow_refs => [undef, 'attr', 0],
    },
    {
        type => 'httptitle',
        pattern => q<\[(> . $http_pattern . q<):[Tt][Ii][Tt][Ll][Ee]=([^\]]+)\]>,
        to_url => sub { $_[0]->[1] },
        is_skipped_object => 1,
        allow_refs => [undef, 'attr', 1],
    },
    {
        type => 'httpimage',
        pattern => q<\[(> . $http_pattern . q<(?:[Jj][Pp][Ee]?[Gg]|[Gg][Ii][Ff]|[Pp][Nn][Gg]|[Bb][Mm][Pp])):[Ii][Mm][Aa][Gg][Ee](?::([HhWw][0-9]+))?\]>,
        to_url => sub { $_[0]->[1] },
        has_image => 1,
        is_skipped_object => 1,
        allow_refs => [undef, 'attr', 0],
    },
    {
        type => 'httpsound',
        pattern => q<\[(> . $http_pattern . q<[Mm][Pp]3):[Ss][Oo][Uu][Nn][Dd](?::(?:([0-9]+)[Hh]|())(?:([0-9]+)[Mm]|())(?:([0-9]+)[Ss]|()))?\]>,
        to_url => sub { $_[0]->[1] },
        is_skipped_object => 1,
        allow_refs => [undef, 'attr', 0, 0],
    },
    {
        type => 'httpbarcode',
        pattern => q<\[(> . $http_pattern . q<):[Bb][Aa][Rr][Cc][Oo][Dd][Ee]\]>,
        to_url => sub { $_[0]->[1] },
        is_skipped_object => 1,
        allow_refs => [undef, 'attr'],
    },
    {
        type => 'idea',
        pattern => q<[Ii][Dd][Ee][Aa]:([0-9]+)(?::[Tt][Ii][Tt][Ll][Ee])?>,
        to_url => sub {
            return q<http://i.hatena.ne.jp/idea/> . $_[0]->[1];
        },
    },
    {
        type => 'isbn',
        pattern => q<[Ii][Ss][Bb][Nn]:([a-zA-Z0-9\-]+)>,
    },
    {
        type => 'asin',
        pattern => q<[Aa][Ss][Ii][Nn]:([a-zA-Z0-9\-]+)>,
    },
    {
        type => 'fotolife',
        pattern => q<[Ff]:[Ii][Dd]:([-_a-zA-Z0-9]+):([0-9]+)([PpJjGgFf])(?::([Ii][Mm][Aa][Gg][Ee]|[Mm][Oo][Vv][Ii][Ee]))?>,
        to_object_url => sub {
            my $v = $_[0];
            my $ext = 'jpg';
            if (my $e = $v->[3]) {
                if ($e eq 'p' or $e eq 'P') {
                    $ext = 'png';
                } elsif ($e eq 'g' or $e eq 'G') {
                    $ext = 'gif';
                } elsif ($e eq 'f' or $e eq 'F') {
                    $ext = 'flv';
                }
            }
            return sprintf q<http://cdn-ak.f.st-hatena.com/images/fotolife/%s/%s/%s/%s.%s>,
                substr($v->[1], 0, 1),
                $v->[1],
                substr($v->[2], 0, 8),
                $v->[2],
                $ext;
        },
        has_image => 1,
        is_skipped_object => 1,
    },
    {
        type => 'land',
        pattern => q<[Ll][Aa][Nn][Dd]:[Ii][Mm][Aa][Gg][Ee]:([a-fA-F0-9]{40}):([0-9A-Za-z_-]+)>,
        to_object_url => sub {
            my $v = $_[0];
            return sprintf q<http://l.hatena.ne.jp/images/%s.%s>,
                $v->[1], $v->[2];
        },
        has_image => 1,
        is_skipped_object => 1,
    },
    {
        type => 'map',
        pattern => q<[Mm][Aa][Pp]:([0-9+.-]+):([0-9+.-]+)>,
        is_skipped_object => 1,
    },
    {
        type => 'ugomemo',
        pattern => q<([Uu][Gg][Oo][Mm][Ee][Mm][Oo]|[Ff][Ll][Ii][Pp][Nn][Oo][Tt][Ee]):([0-9A-F]{16}):([0-9A-Za-z-_]+)>,
        to_url => sub {
            my $v = $_[0];
            return sprintf q<http://%s/%s@DSi/movie/%s>,
                ($v->[1] =~ /[Uu]/
                    ? 'ugomemo.hatena.ne.jp' : 'flipnote.hatena.com'),
                $v->[2],
                $v->[3];
        },
        has_image => 1,
        is_skipped_object => 1,
    },
    {
        type => 'keyword',
        pattern => q<\[[Kk][Ee][Yy][Ww][Oo][Rr][Dd]:([^\]]+)\]>,
        allow_refs => [undef, 1],
    },
    {
        type => 'keyword',
        pattern => q<\[\[([^\]]+)\]\]>,
        allow_refs => [undef, 1],
    },
    {
        type => 'dkeyword',
        pattern => q<\[[Dd]:[Kk][Ee][Yy][Ww][Oo][Rr][Dd]:([^\]]+)\]>,
        allow_refs => [undef, 1],
    },
    {
        type => 'hkeyword',
        pattern => q<\[[Hh]:[Kk][Ee][Yy][Ww][Oo][Rr][Dd]:([^\]]+)\]>,
        allow_refs => [undef, 1],
    },
    {
        type => 'mailto',
        pattern => q<[Mm][Aa][Ii][Ll][Tt][Oo]:([0-9A-Za-z_\.-]+\@[0-9A-Za-z_][0-9A-Za-z_\.\-]*[0-9A-Za-z_])>,
    },
];

our $TextNotation = {};

## Following syntaxes are considered obsoleted and are not supported
## by this implementation:
##
## http:title without []: http://example.com/:title=PageTitle (in
## favor of [http://example.com/:title=PageTitle])
##
## Sime: {SIME}keyword-name ({SIME} is U+3006; in favor of
## [[keyword-name]])

1;
