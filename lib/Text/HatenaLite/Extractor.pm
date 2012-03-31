package Text::HatenaLite::Extractor;
use strict;
use warnings;
our $VERSION = '1.0';
use Text::HatenaLite::Definitions;
use Text::HatenaLite::Formatter::Role::URLs;
push our @ISA, qw(Text::HatenaLite::Formatter::Role::URLs);

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
    return $self->{extracted_urls} if $self->{extracted_urls};

    my $data = $self->parsed_data or die "|parsed_data| is not set";

    my @url;
    for my $node (@$data) {
        my $def = $Notations->{$node->{type}}
            or die "Definition for |$node->{type}| not found";

        my $code = $self->can($node->{type} . '_notation_to_url');
        if ($code) {
            my $url = $self->$code($def, $node->{values});
            push @url, $url if defined $url;
        } elsif ($def->{to_url}) {
            my $url = $def->{to_url}->($node->{values});
            push @url, $url if defined $url;
        }
        
    }

    return $self->{extracted_urls} = \@url;
}

sub extract_urls_for_trackback {
    my $self = shift;
    my $found = {};
    return [grep { not $found->{$_}++ } map {
        (m{
            ^https?://
            (?:
                f\.hatena\.(?:ne\.jp|com)/[^/]+/[0-9]+ |
                (?:ugomemo|flipnote)\.hatena\.(?:ne\.jp|com)/[^/]+/movie/[^/]+ |
                d\.hatena\.ne\.jp/[^/]+/.+ |
                [0-9a-z-]+\.g\.hatena\.ne\.jp/[^/]+/.+ |
                q\.hatena\.ne\.jp/[0-9]+ |
                i\.hatena\.ne\.jp/idea/[0-9]+ |
                anond\.hatelabo\.jp/[0-9]+
            )
        }xig);
    } @{$self->extract_urls}];
}

sub extract_image_urls {
    my $self = shift;
    return $self->{extracted_image_urls} if $self->{extracted_image_urls};

    my $data = $self->parsed_data or die "|parsed_data| is not set";

    my @url;
    for my $node (@$data) {
        my $def = $Notations->{$node->{type}}
            or die "Definition for |$node->{type}| not found";

        my $code = $self->can($node->{type} . '_notation_to_image_url');
        if ($code) {
            my $url = $self->$code($def, $node->{values});
            push @url, $url if defined $url;
        } elsif (($def->{to_object_url} || $def->{to_url}) and
                 $def->{has_image}) {
            my $url = ($def->{to_object_url} || $def->{to_url})
                ->($node->{values});
            push @url, $url if defined $url;
        }
    }

    return $self->{extracted_image_urls} = \@url;
}

1;
