package Template::Plugin::Text::HatenaLite::HTML;
use strict;
use warnings;
use base qw(Template::Plugin);
use Text::HatenaLite::Parser;
use Text::HatenaLite::Formatter::HTML;

sub new {
    my($self, $context, @args) = @_;
    my $name = $args[0] || 'hatenalite_to_html';
    $context->define_filter($name, sub {
        my $parsed = Text::HatenaLite::Parser->parse_string($_[0]);
        my $parser = Text::HatenaLite::Formatter::HTML->new;
        $parser->parsed_data($parsed);
        return $parser->as_text;
    }, 0);
    return $self;
}

1;
