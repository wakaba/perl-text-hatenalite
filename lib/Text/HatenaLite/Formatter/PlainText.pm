package Text::HatenaLite::Formatter::PlainText;
use strict;
use warnings;
our $VERSION = '1.0';
use Text::HatenaLite::Definitions;
use Text::HatenaLite::Formatter::Base;
use Text::HatenaLite::Formatter::Role::URLs;
push our @ISA, qw(
    Text::HatenaLite::Formatter::Role::URLs
    Text::HatenaLite::Formatter::Base
);
use Mono::ID;

my $Notations = {};
for my $def (@$Text::HatenaLite::Definitions::Notations) {
    $Notations->{$def->{type}} = $def;
}

$Notations->{text} = $Text::HatenaLite::Definitions::TextNotation;

sub text_notation_to_plain_text {
    return $_[2]->[1];
}

sub keyword_notation_to_plain_text {
    return $_[2]->[1];
}

sub httptitle_notation_to_plain_text {
    return $_[2]->[2] . '<' . $_[1]->{to_url}->($_[2]) . '>';
}

sub httpimage_notation_to_plain_text {
    return $_[1]->{to_url}->($_[2]);
}

sub httpsound_notation_to_plain_text {
    return $_[1]->{to_url}->($_[2]);
}

sub httpbarcode_notation_to_plain_text {
    return $_[1]->{to_url}->($_[2]);
}

sub idea_notation_to_plain_text {
    return $_[1]->{to_url}->($_[2]);
}

sub asin_to_plain_text {
    my ($self, $asin, %args) = @_;
    my $title = $self->asin_to_title($asin);
    if (defined $title) {
        return $title . ' (ASIN:' . $asin . ')';
    } else {
        my $label = $args{fallback_label};
        $label = 'ASIN:' . $asin if not defined $label;
        return $label;
    }
}

sub isbn_to_plain_text {
    my $isbn = $_[1];
    my $asin = isbn_to_asin $isbn;
    return $_[0]->asin_to_plain_text($asin, fallback_label => 'ISBN:' . $isbn)
        if $asin;
    return 'ISBN:' . $isbn;
}

sub asin_notation_to_plain_text {
    my $asin = $_[2]->[1];
    $asin =~ tr/a-z-/A-Z/d;
    return $_[2]->[0] unless is_asin $asin;
    return $_[0]->asin_to_plain_text($asin);
}

sub isbn_notation_to_plain_text {
    my $isbn = $_[2]->[1];
    $isbn =~ tr/a-z-/A-Z/d;
    return $_[2]->[0] unless is_isbn $isbn;
    return $_[0]->isbn_to_plain_text($isbn);
}

sub fotolife_notation_to_plain_text {
    return $_[1]->{to_object_url}->($_[2]);
}

sub land_notation_to_plain_text {
    return $_[1]->{to_object_url}->($_[2]);
}

sub ugomemo_notation_to_plain_text {
    return $_[1]->{to_url}->($_[2]);
}

sub as_text {
    my $self = shift;
    my $data = $self->parsed_data or die "|parsed_data| is not set";

    my @l;
    for my $node (@$data) {
        my $def = $Notations->{$node->{type}}
            or die "Definition for |$node->{type}| not found";
        my $code = $self->can($node->{type} . '_notation_to_plain_text')
            || $def->{to_text} || sub { $_[2]->[0] };
        push @l, $self->$code($def, $node->{values});
    }

    return join '', @l;
}

1;
