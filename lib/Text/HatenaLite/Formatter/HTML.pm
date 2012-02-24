package Text::HatenaLite::Formatter::HTML;
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

sub htescape ($) {
    my $v = $_[0];
    $v =~ s{&}{&amp;}g;
    $v =~ s{<}{&lt;}g;
    $v =~ s{>}{&gt;}g;
    $v =~ s{\x22}{&#34;}g;
    return $v;
}

sub as_text {
    my $self = shift;
    my $data = $self->parsed_data or die "|parsed_data| is not set";

    my @l;
    for my $node (@$data) {
        my $def = $Notations->{$node->{type}}
            or die "Definition for |$node->{type}| not found";
        my $code = $def->{to_html} || sub { htescape $_[1]->[0] };
        push @l, $code->($def, $node->{values});
    }

    return join '', @l;
}

1;
