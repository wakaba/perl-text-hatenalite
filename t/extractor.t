package test::Text::HatenaLite::Formatter::Extractor;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->subdir('t_deps', 'modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Text::HatenaLite::Parser;
use Text::HatenaLite::Extractor;
use Text::HatenaLite::Formatter::PlainText;
use Test::Differences;
use Test::HTCT::Parser;

my $TestDataFormat = do(file(__FILE__)->dir->file('data-format.pl')->stringify);

sub _tests : Tests {
    for_each_test file(__FILE__)->dir->subdir('data', 'texts-1.dat')->stringify, $TestDataFormat, sub {
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

        for my $t (@{$test->{head} or []}) {
            my $data = $parser->head_by_length($t->[1]->[0]);
            my $f = Text::HatenaLite::Formatter::PlainText->new;
            $f->parsed_data($data);
            eq_or_diff $f->as_text, $t->[0];
        }

        for my $t (@{$test->{headskipobject} or []}) {
            my $data = $parser->head_by_length($t->[1]->[0], skip_object => 1);
            my $f = Text::HatenaLite::Formatter::PlainText->new;
            $f->parsed_data($data);
            eq_or_diff $f->as_text, $t->[0];
        }
    };
}

__PACKAGE__->runtests;

1;
