package test::Text::HatenaLite::Formatter::HTML::Galapagos;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->subdir('modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Text::HatenaLite::Parser;
use Text::HatenaLite::Formatter::HTML::Galapagos;
use Test::Differences;
use Test::HTCT::Parser;

sub _tests : Tests {
    for_each_test file(__FILE__)->dir->subdir('data', 'texts-1.dat')->stringify, {
        data => {is_prefixed => 1},
        html => {is_prefixed => 1},
        mobilehtml => {is_prefixed => 1},
    }, sub {
        my $test = shift;
        my $expected = ($test->{mobilehtml} || $test->{html} || $test->{data})->[0];
        my $parsed = Text::HatenaLite::Parser->parse_string($test->{data}->[0]);
        my $parser = Text::HatenaLite::Formatter::HTML::Galapagos->new;
        $parser->parsed_data($parsed);
        my $text = $parser->as_text;
        eq_or_diff $text, $expected;
    };
}

__PACKAGE__->runtests;

1;
