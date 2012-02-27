package test::Text::HatenaLite::Parser;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->subdir('modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Text::HatenaLite::Parser;
use Test::Differences;
use Test::HTCT::Parser;

sub _tests : Tests {
    for_each_test file(__FILE__)->dir->subdir('data', 'texts-1.dat')->stringify, {
        data => {is_prefixed => 1},
        parsed => {is_prefixed => 1},
    }, sub {
        my $test = shift;
        my $result = Text::HatenaLite::Parser->parse_string($test->{data}->[0]);
        $result = join "\n", map {
            $_->{type} . join "\n", map { ' ' . $_ } @{$_->{values}}
        } @$result;
        eq_or_diff $result, $test->{parsed}->[0];
    };
}

__PACKAGE__->runtests;

1;
