package Text::HatenaLite::Extractor;
use strict;
use warnings;
our $VERSION = '1.0';
use Text::HatenaLite::Definitions;

sub new {
    my $class = shift;
    return bless {@_}, $class;
}

sub parsed_data {
    if (@_ > 1) {
        $_[0]->{parsed_data} = $_[1];
    }
    return $_[0]->{parsed_data};
}

my $Notations = {};
for my $def (@$Text::HatenaLite::Definitions::Notations) {
    $Notations->{$def->{type}} = $def;
}
$Notations->{text} = $Text::HatenaLite::Definitions::TextNotation;

sub extract_urls {
    my $self = shift;
    my $data = $self->parsed_data or die "|parsed_data| is not set";

    my @url;
    for my $node (@$data) {
        my $def = $Notations->{$node->{type}}
            or die "Definition for |$node->{type}| not found";

        if ($def->{to_url}) {
            my $url = $def->{to_url}->($node->{values});
            push @url, $url if defined $url;
        }
        
    }

    return \@url;
}

1;
