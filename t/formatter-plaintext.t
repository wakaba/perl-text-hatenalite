package test::Text::HatenaLite::Formatter::PlainText;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->subdir('t_deps', 'modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Text::HatenaLite::Parser;
use Text::HatenaLite::Formatter::PlainText;
use Test::Differences;
use Test::HTCT::Parser;

my $TestDataFormat = do(file(__FILE__)->dir->file('data-format.pl')->stringify);

sub _tests : Tests {
    for_each_test file(__FILE__)->dir->subdir('data', 'texts-1.dat')->stringify, $TestDataFormat, sub {
        my $test = shift;
        my $parsed = Text::HatenaLite::Parser->parse_string($test->{data}->[0]);
        my $parser = Text::HatenaLite::Formatter::PlainText->new;
        $parser->parsed_data($parsed);
        eq_or_diff $parser->as_text, ($test->{plaintext} || $test->{data})->[0];
    };
}

__PACKAGE__->runtests;

1;
