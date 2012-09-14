package Text::HatenaLite::Parser;
use strict;
use warnings;
our $VERSION = '1.0';
use Regexp::Assemble;
use Text::HatenaLite::Definitions;
use Text::HatenaLite::Parser::CharRefs;

my $Patterns = $Text::HatenaLite::Definitions::Notations;

my $Regexp = Regexp::Assemble->new(track => 1);
for (@$Patterns) {
    $Regexp->add($_->{pattern});
}

my $PatternToType = {map { $_->{pattern} => $_->{type} } @$Patterns};
my $PatternToPP = {map { $_->{pattern} => $_->{postprocess} } @$Patterns};
my $PatternToAllowRefs = {map { $_->{pattern} => $_->{allow_refs} } @$Patterns};

sub resolve_charrefs ($;$) {
    return unless $_[0] =~ /&/;
    
    no warnings 'utf8';
    $_[0] =~ s{
        &\#[Xx]([0-9A-Fa-f]+); |
        &\#([0-9]+); |
        &([0-9A-Za-z]+[=;]?)
    }{
        if (defined $1) {
            if (hex $1 > 0x10FFFF) {
                "\x{FFFD}";
            } else {
                chr hex $1;
            }
        } elsif (defined $2) {
            if ($2 > 0x10FFFF) {
                "\x{FFFD}";
            } else {
                chr $2;
            }
        } else {
            my $name = $3;
            my $result = '&' . $name;
            my $rem = '';
            {
                my $char = $Text::HatenaLite::Parser::CharRefs->{$name};
                if ($char) {
                    if ($_[1] and $rem =~ /^[=0-9A-Za-z]/) {
                        $result = '&' . $name . $rem;
                    } else {
                        $result = $char . $rem;
                    }
                    last;
                } else {
                    $rem = substr ($name, -1, 1) . $rem;
                    substr ($name, -1, 1) = '';
                    redo if length $name;
                }
            }
            $result;
        }
    }gex;
}

sub parse_string {
    my (undef, $str) = @_;
    $str = '' unless defined $str;
    
    my @token;
    while ((length $str) && $Regexp->match($str)) {
        my $begin = $Regexp->mbegin->[0];
        my $end = $Regexp->mend->[0];
        last if $begin == $end;
        if ($Regexp->mbegin->[0] > 0) {
            push @token, {type => 'text',
                          values => [substr($str, 0, $Regexp->mbegin->[0])]};
            $token[-1]->{values}->[1] = $token[-1]->{values}->[0];
            resolve_charrefs $token[-1]->{values}->[1];
        }
        
        my $pattern = $Regexp->matched;
        push @token, {
            type => ($PatternToType->{$pattern} || die "Unknown pattern: |$pattern|"),
            values => $Regexp->mvar,
        };
        if (my $pp = $PatternToPP->{$pattern}) {
            $pp->($token[-1]->{values});
        }
        if (my $ar = $PatternToAllowRefs->{$pattern}) {
            for (0..$#$ar) {
                next unless $ar->[$_];
                next unless defined $token[-1]->{values}->[$_];
                resolve_charrefs $token[-1]->{values}->[$_], 
                    $ar->[$_] eq 'attr';
            }
        }
        
        $str = substr($str, $Regexp->mend->[0]);
    }
    if (length $str) {
        push @token, {type => 'text', values => [$str, $str]};
        resolve_charrefs $token[-1]->{values}->[1];
    }

    return \@token;
}

1;
