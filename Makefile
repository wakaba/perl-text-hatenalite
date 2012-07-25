PROVE = prove
REMOTEDEV_HOST = 

all:

test: safetest

test-deps: pmb-install

safetest: test-deps safetest-main

safetest-main:
	PERL5LIB=$(shell cat config/perl/libs.txt) $(PROVE) t/*.t

Makefile-setupenv: Makefile.setupenv
	make --makefile Makefile.setupenv setupenv-update \
            SETUPENV_MIN_REVISION=20120330

Makefile.setupenv:
	wget -O $@ https://raw.github.com/wakaba/perl-setupenv/master/Makefile.setupenv

setupenv remotedev-test remotedev-reset config/perl/libs.txt \
perl-exec pmb-update pmb-install lperl lprove: %: Makefile-setupenv always
	make --makefile Makefile.setupenv $@ REMOTEDEV_HOST=$(REMOTEDEV_HOST)

always:
