package test::Text::HatenaLite::Formatter::JSON;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->subdir('modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Text::HatenaLite::Parser;
use Text::HatenaLite::Formatter::JSON;
use Test::Differences;

sub _a : Test(8) {
    for (
        [
            q{foo[[aa]]bar&amp;http://hoge/},
            [{type => 'text', values => {_ => 'foo', value => 'foo'}},
             {type => 'keyword', values => {_ => '[[aa]]', keyword => 'aa'}},
             {type => 'text', values => {_ => 'bar&amp;', value => 'bar&'}},
             {type => 'http', values => {_ => 'http://hoge/', url => 'http://hoge/'}}],
        ],
        [
            q{id:hoge id:fuga:detail},
            [{type => 'id', values => {_ => 'id:hoge', urlname => 'hoge'}},
             {type => 'text', values => {_ => ' ', value => ' '}},
             {type => 'id', values => {_ => 'id:fuga:detail', urlname => 'fuga'}}],
        ],
        [
            q{http://hoge:movie},
            [{type => 'http', values => {_ => 'http://hoge:movie', url => q<http://hoge>, embedformat => 'movie'}}],
        ],
        [
            q{http://hoge/hoge.png},
            [{type => 'http', values => {_ => 'http://hoge/hoge.png', url => q<http://hoge/hoge.png>, image_url => q<http://hoge/hoge.png>}}],
        ],
        [
            q{http://sp.nicovideo.jp/watch/sm2112444},
            [{type => 'http', values => {_ => 'http://sp.nicovideo.jp/watch/sm2112444', url => q<http://sp.nicovideo.jp/watch/sm2112444>, nicovideo_id => 'sm2112444'}}],
        ],
        [
            q{[http://hoge/hoge.png:title]},
            [{type => 'httptitle', values => {_ => '[http://hoge/hoge.png:title]', url => q<http://hoge/hoge.png>}}],
        ],
        [
            q{[http://hoge/hoge.png:title=hoge&amp;fuga]},
            [{type => 'httptitle', values => {_ => '[http://hoge/hoge.png:title=hoge&amp;fuga]', url => q<http://hoge/hoge.png>, title => 'hoge&fuga'}}],
        ],
        [
            q{mailto:hoge@fug},
            [{type => 'mailto', values => {_ => 'mailto:hoge@fug', addr => q<hoge@fug>}}],
        ],
    ) {
        my $parsed = Text::HatenaLite::Parser->parse_string($_->[0]);
        my $parser = Text::HatenaLite::Formatter::JSON->new;
        $parser->parsed_data($parsed);
        eq_or_diff $parser->as_jsonable, $_->[1];
    }
}

__PACKAGE__->runtests;

1;
