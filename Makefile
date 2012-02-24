PROVE = prove

all:

test: safetest

safetest:
	$(PROVE) t/*.t
