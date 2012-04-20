all: CharRefs.pm

CharRefs.pm:
	curl https://raw.github.com/wakaba/manakai/master/lib/Whatpm/_NamedEntityList.pm\
	| sed 's/Whatpm::HTML::EntityChar/Text::HatenaLite::Parser::CharRefs/' \
	> $@ 
