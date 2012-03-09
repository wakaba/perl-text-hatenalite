package test::Template::Plugin::Text::HatenaLite::HTML;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->subdir('modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Test::Differences;
use Template;

sub _hatenalite_to_html : Test(1) {
    my $template = Template->new;
    $template->process(\"[% USE Text.HatenaLite.HTML %][% FILTER hatenalite_to_html %]<p>hoge<script>alert(2)</script>\n</forM>abc\n-xyz\n-aaa\nf:id:cho45:123456f:image\nhttp://hoge/fuga/abc.png[% END %]", undef, \my $result) or do {
        die $template->error;
    };
    eq_or_diff $result, q{&lt;p&gt;hoge&lt;script&gt;alert(2)&lt;/script&gt;<br>&lt;/forM&gt;abc<br>-xyz<br>-aaa<br><a href="http://f.hatena.ne.jp/cho45/123456"><img src="http://cdn-ak.f.st-hatena.com/images/fotolife/c/cho45/123456/123456,jpg" alt="f:id:cho45:123456f:image"></a><br><a href="http://hoge/fuga/abc.png"><img src="http://hoge/fuga/abc.png" alt="http://hoge/fuga/abc.png"></a>};
}

__PACKAGE__->runtests;

1;
