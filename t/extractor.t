package test::Text::HatenaLite::Formatter::Extractor;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->subdir('modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Text::HatenaLite::Parser;
use Text::HatenaLite::Extractor;
use Test::Differences;
use Test::HTCT::Parser;

sub _tests : Tests {
    for_each_test file(__FILE__)->dir->subdir('data', 'texts-1.dat')->stringify, {
        data => {is_prefixed => 1},
        urls => {is_prefixed => 1},
        trackbackurls => {is_prefixed => 1},
        idcalls => {is_prefixed => 1},
        imageurls => {is_prefixed => 1},
        geocoords => {is_prefixed => 1},
    }, sub {
        my $test = shift;
        my $parsed = Text::HatenaLite::Parser->parse_string($test->{data}->[0]);
        my $parser = Text::HatenaLite::Extractor->new;
        $parser->parsed_data($parsed);

        eq_or_diff [sort { $a cmp $b } keys %{$parser->extract_urls}],
            [sort { $a cmp $b } split /\n/, ($test->{urls} || [])->[0] || ''];

        eq_or_diff [sort { $a cmp $b } keys %{$parser->extract_urls_for_trackback}],
            [sort { $a cmp $b } split /\n/, ($test->{trackbackurls} || [])->[0] || ''];

        eq_or_diff [sort { $a cmp $b } keys %{$parser->extract_url_names_for_id_call}],
            [sort { $a cmp $b } split /\n/, ($test->{idcalls} || [])->[0] || ''];

        eq_or_diff [sort { $a cmp $b } keys %{$parser->extract_image_urls}],
            [sort { $a cmp $b } split /\n/, ($test->{imageurls} || [])->[0] || ''];

        my $coords = $parser->extract_geo_coords;
        eq_or_diff [map { $coords->{$_}->[0] . ',' . $coords->{$_}->[1] }
                    sort { $a cmp $b } keys %$coords],
            [sort { $a cmp $b } split /\n/, ($test->{geocoords} || [])->[0] || ''];
    };
}

__PACKAGE__->runtests;

1;
