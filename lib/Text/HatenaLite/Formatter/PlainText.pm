package Text::HatenaLite::Formatter::PlainText;
use strict;
use warnings;
our $VERSION = '1.0';
use Text::HatenaLite::Definitions;
use Text::HatenaLite::Formatter::Base;
push our @ISA, qw(Text::HatenaLite::Formatter::Base);

my $Notations = {};
for my $def (@$Text::HatenaLite::Definitions::Notations) {
    $Notations->{$def->{type}} = $def;
}

$Notations->{text} = $Text::HatenaLite::Definitions::TextNotation;

sub as_text {
    my $self = shift;
    my $data = $self->parsed_data or die "|parsed_data| is not set";

    my @l;
    for my $node (@$data) {
        my $def = $Notations->{$node->{type}}
            or die "Definition for |$node->{type}| not found";
        my $code = $def->{to_text} || sub { $_[1]->[0] };
        push @l, $code->($def, $node->{values});
    }

    return join '', @l;
}

1;
