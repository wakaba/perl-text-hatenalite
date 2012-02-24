package test::Text::HatenaLite::Formatter::HTML;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use lib file(__FILE__)->dir->parent->subdir('modules', 'testdataparser', 'lib')->stringify;
use base qw(Test::Class);
use Text::HatenaLite::Parser;
use Text::HatenaLite::Formatter::HTML;
use Test::Differences;
use Test::HTCT::Parser;

sub _tests : Tests {
    for_each_test file(__FILE__)->dir->subdir('data', 'texts-1.dat')->stringify, {
        data => {is_prefixed => 1},
        html => {is_prefixed => 1},
    }, sub {
        my $test = shift;
        my $parsed = Text::HatenaLite::Parser->parse_string($test->{data}->[0]);
        my $parser = Text::HatenaLite::Formatter::HTML->new;
        $parser->parsed_data($parsed);
        eq_or_diff $parser->as_text, ($test->{html} || $test->{data})->[0];
    };
}

__PACKAGE__->runtests;

1;
