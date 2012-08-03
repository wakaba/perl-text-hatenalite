package Text::HatenaLite::Formatter::JSON;
use strict;
use warnings;
our $VERSION = '1.0';
use Text::HatenaLite::Formatter::Base;
use Text::HatenaLite::Formatter::Role::URLs
push our @ISA, qw(
  Text::HatenaLite::Formatter::Base
  Text::HatenaLite::Formatter::Role::URLs
);
use Text::HatenaLite::Definitions;

my $Notations = {};
for my $def (@$Text::HatenaLite::Definitions::Notations) {
    $Notations->{$def->{type}} = $def;
}

$Notations->{text} = $Text::HatenaLite::Definitions::TextNotation;

sub as_jsonable {
    my $self = shift;
    my $parsed = $self->parsed_data;
    my $result = [];
    for (@$parsed) {
        my $node = {%$_};
        my $def = $Notations->{$node->{type}}
            or die "Definition for |$node->{type}| not found";

        my $values = {_ => $node->{values}->[0]};
        for (1..$#{$node->{values}}) {
            if (defined $def->{args}->[$_-1]) {
                $values->{$def->{args}->[$_-1]} = $node->{values}->[$_];
            }
        }
        if ($node->{type} eq 'http') {
            my $parsed = $self->parse_http_url($values->{url});
            for (keys %$parsed) {
                $values->{$_} = $parsed->{$_};
            }
        }
        $node->{values} = $values;

        push @$result, $node;
    }
    return $result;
}

1;
