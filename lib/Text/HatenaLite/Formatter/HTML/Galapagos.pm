package Text::HatenaLite::Formatter::HTML::Galapagos;
use strict;
use warnings;
use Text::HatenaLite::Formatter::HTML;
use Text::HatenaLite::Formatter::Role::Galapagos;
push our @ISA, qw(
    Text::HatenaLite::Formatter::Role::Galapagos
    Text::HatenaLite::Formatter::HTML
);

1;
