package Text::HatenaLite::Formatter::PlainText;
use strict;
use warnings;
our $VERSION = '1.0';
use Text::HatenaLite::Definitions;

my $Notations = {};
for my $def (@$Text::HatenaLite::Definitions::Notations) {
    $Notations->{$def->{type}} = $def;
}

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub parsed_data {
    if (@_ > 1) {
        $_[0]->{parsed_data} = $_[1];
    }
    return $_[0]->{parsed_data};
}

sub as_text {
    my $self = shift;
    my $data = $self->parsed_data or die "|parsed_data| is not set";

    my @l;
    for my $node (@$data) {
        if ($node->{type} eq 'fotolife') {
            push @l, $Notations->{fotolife}->{to_object_url}->($node->{values});
        } elsif ($node->{type} eq 'ugomemo') {
            push @l, $Notations->{ugomemo}->{to_url}->($node->{values});
        } else {
            push @l, $node->{values}->[0];
        }
    }

    return join '', @l;
}

1;
