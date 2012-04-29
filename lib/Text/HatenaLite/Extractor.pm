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

    my $i = 0;
    return $self->{extracted_urls} = {map { $_ => ++$i } @url};
}

sub extract_urls_for_trackback {
    my $self = shift;
    my $found = {};
    return {map { $_ => 1 } grep { not $found->{$_}++ } map {
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
    } keys %{$self->extract_urls}};
}

sub extract_url_names_for_id_call {
    my $self = shift;
    return $self->{extracted_url_names_for_id_call}
        if $self->{extracted_url_names_for_id_call};

    my $data = $self->parsed_data or die "|parsed_data| is not set";

    my %url_name;
    my $i = 0;
    for my $node (@$data) {
        my $def = $Notations->{$node->{type}}
            or die "Definition for |$node->{type}| not found";

        my $code = $self->can($node->{type} . '_notation_to_url_name_for_id_call');
        if ($code) {
            my $url_name = $self->$code($def, $node->{values});
            $url_name{$url_name} = ++$i if defined $url_name;
        }
    }

    return $self->{extracted_url_names_for_id_call} = \%url_name;
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

    my $i = 0;
    return $self->{extracted_image_urls} = {map { $_ => ++$i } @url};
}

sub extract_geo_coords {
    my $self = shift;
    return $self->{extracted_geo_coords} if $self->{extracted_geo_coords};

    my $data = $self->parsed_data or die "|parsed_data| is not set";

    my $list = {};
    my $i = 0;
    for my $node (@$data) {
        my $def = $Notations->{$node->{type}}
            or die "Definition for |$node->{type}| not found";

        my $code = $self->can($node->{type} . '_notation_to_geo_coord');
        if ($code) {
            my $latlon = $self->$code($def, $node->{values});
            $list->{$latlon->[0], $latlon->[1]}
                = [$latlon->[0], $latlon->[1], ++$i] if $latlon;
        }
    }

    return $self->{extracted_geo_coords} = $list;
}

sub head_by_length {
    my ($self, $n, %args) = @_;
    my $data = $self->parsed_data or die "|parsed_data| is not set";
    my $max_objects = $args{max_objects} || 4;
    my $objects = 0;
    
    my $new_data = [];
    for (0..$#$data) {
        if ($_ < $#$data and $n <= 0) {
            push @$new_data, {type => 'text', values => ['...', '...']};
            last;
        }

        my $node = $data->[$_];
        if ($node->{type} eq 'text') {
            my $value = $node->{values}->[1];
            if ($n < length $value) {
                $value = $n > 3 ? substr $value, 0, $n - 3 : '';
                $value .= '...';
                push @$new_data, {type => 'text', values => [$value, $value]};
                last;
            }
            
            push @$new_data, {type => 'text', values => [$value, $value]};
            $n -= length $value;
        } else {
            my $def = $Notations->{$node->{type}}
                or die "Definition for |$node->{type}| not found";
            if ($args{skip_object} and $def->{is_skipped_object}) {
                push @$new_data, {type => 'text', values => ['...', '...']};
                $n -= 3;
                next;
            }
            if ($objects++ > $max_objects) {
                push @$new_data, {type => 'text', values => ['...', '...']};
                last;
            }

            if ($n >= length $node->{values}->[0]) {
                push @$new_data, $node;
                $n -= length $node->{values}->[0];
            } else {
                push @$new_data, {type => 'text', values => ['...', '...']};
                last;
            }
        }
    }

    return $new_data;
}

1;
