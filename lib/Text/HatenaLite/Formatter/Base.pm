package Text::HatenaLite::Formatter::Base;
use strict;
use warnings;
our $VERSION = '1.0';

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

1;
