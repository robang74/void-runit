DESTDIR=

PACKAGE=runit-2.1.2
DIRS=doc man etc package src
PREFIX ?=	/usr/local
SCRIPTS=	1 2 3 ctrlaltdel
MANPAGES=runit.8 runit-init.8 runsvdir.8 runsv.8 sv.8 utmpset.8 \
  runsvchdir.8 svlogd.8 chpst.8

all: clean .manpages $(PACKAGE).tar.gz

.manpages:
	for i in $(MANPAGES); do \
	  rman -S -f html -r '' < man/$$i | \
	  sed -e "s}name='sect\([0-9]*\)' href='#toc[0-9]*'>\(.*\)}name='sect\1'>\2}g ; \
	  s}<a href='#toc'>Table of Contents</a>}<a href='http://smarden.org/pape/'>G. Pape</a><br><a href='index.html'>runit</A><hr>}g ; \
	  s}<!--.*-->}}g" \
	  > doc/$$i.html ; \
	done ; \
	echo 'fix up html manually...'
	echo 'patch -p0 <manpagehtml.diff && exit'
	sh
	find . -name '*.orig' -exec rm -f {} \;
	touch .manpages

$(PACKAGE).tar.gz:
	rm -rf TEMP
	mkdir -p TEMP/admin/$(PACKAGE)
	make -C src clean
	cp -a $(DIRS) TEMP/admin/$(PACKAGE)/
	ln -sf ../etc/debian TEMP/admin/$(PACKAGE)/doc/
	for i in TEMP/admin/$(PACKAGE)/etc/*; do \
	  test -d $$i && ln -s ../2 $$i/2; \
	done
	chmod -R g-ws TEMP/admin
	chmod +t TEMP/admin
	find TEMP -exec touch {} \;
	su -c '\
	  chown -R root:root TEMP/admin ; \
	  (cd TEMP && tar --exclude CVS -cpzf ../$(PACKAGE).tar.gz admin); \
	  rm -rf TEMP'

clean:
	find . -name \*~ -exec rm -f {} \;
	find . -name .??*~ -exec rm -f {} \;
	find . -name \#?* -exec rm -f {} \;

cleaner: clean
	rm -f $(PACKAGE).tar.gz
	for i in $(MANPAGES); do rm -f doc/`basename $$i`.html; done
	rm -f .manpages

all:
	$(CC) $(CFLAGS) halt.c -o halt
	$(CC) $(CFLAGS) pause.c -o pause

install:
	install -d ${DESTDIR}/${PREFIX}/bin
	install -m755 halt ${DESTDIR}/${PREFIX}/bin
	install -m755 pause ${DESTDIR}/${PREFIX}/bin
	install -m755 shutdown.sh ${DESTDIR}/${PREFIX}/bin/shutdown
	ln -s halt ${DESTDIR}/${PREFIX}/bin/poweroff
	ln -s halt ${DESTDIR}/${PREFIX}/bin/reboot
	install -d ${DESTDIR}/${PREFIX}/share/man/man1
	install -m644 pause.1 ${DESTDIR}/${PREFIX}/share/man/man1
	install -d ${DESTDIR}/etc/sv
	install -d ${DESTDIR}/etc/runit/runsvdir
	install -m755 ${SCRIPTS} ${DESTDIR}/etc/runit
	install -m644 rc.conf ${DESTDIR}/etc
	install -d ${DESTDIR}/${PREFIX}/lib/dracut/dracut.conf.d
	install -m644 dracut/*.conf ${DESTDIR}/${PREFIX}/lib/dracut/dracut.conf.d
	cp -aP runsvdir/* ${DESTDIR}/etc/runit/runsvdir/
	cp -aP services/* ${DESTDIR}/etc/sv/

clean:
	-rm -f halt pause
