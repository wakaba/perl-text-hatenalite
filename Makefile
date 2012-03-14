PROVE = prove
REMOTEDEV_HOST = 

all:

test: safetest

safetest: local-submodules carton-install config/perl/libs.txt safetest-main

safetest-main:

safetest:
	PERL5LIB=$(shell cat config/perl/libs.txt) $(PROVE) t/*.t

Makefile-setupenv: Makefile.setupenv
	make --makefile Makefile.setupenv setupenv-update \
            SETUPENV_MIN_REVISION=20120313

Makefile.setupenv:
	wget -O $@ https://raw.github.com/wakaba/perl-setupenv/master/Makefile.setupenv

setupenv remotedev-test remotedev-reset config/perl/libs.txt \
carton-install carton-update local-submodules: %: Makefile-setupenv always
	make --makefile Makefile.setupenv $@ REMOTEDEV_HOST=$(REMOTEDEV_HOST)

always:
