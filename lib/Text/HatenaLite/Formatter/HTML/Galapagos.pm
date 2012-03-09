package Text::HatenaLite::Formatter::HTML::Galapagos;
use strict;
use warnings;
our $VERSION = '1.0';
use Text::HatenaLite::Formatter::HTML;
use Text::HatenaLite::Formatter::Role::Galapagos;
use Text::HatenaLite::Formatter::Role::NoFlash;
use Text::HatenaLite::Formatter::Role::HatenaMobile;
push our @ISA, qw(
    Text::HatenaLite::Formatter::Role::Galapagos
    Text::HatenaLite::Formatter::Role::NoFlash
    Text::HatenaLite::Formatter::Role::HatenaMobile
    Text::HatenaLite::Formatter::HTML
);

1;
