package test::Text::HatenaLite::Formatter::HTML;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->subdir('t_deps', 'modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Text::HatenaLite::Parser;
use Text::HatenaLite::Formatter::HTML;
use Test::Differences;
use Test::HTCT::Parser;

my $TestDataFormat = do(file(__FILE__)->dir->file('data-format.pl')->stringify);

sub _tests : Tests {
    for_each_test file(__FILE__)->dir->subdir('data', 'texts-1.dat')->stringify, $TestDataFormat, sub {
        my $test = shift;
        my $expected = ($test->{html} || $test->{data})->[0];
        my $parsed = Text::HatenaLite::Parser->parse_string($test->{data}->[0]);
        my $parser = Text::HatenaLite::Formatter::HTML->new;
        $parser->parsed_data($parsed);
        my $text = $parser->as_text;
        $text =~ s/nicovideo[0-9]+/nicovideo99999/g;
        eq_or_diff $text, $expected;
    };
}

__PACKAGE__->runtests;

1;
