DESTDIR=
PREFIX ?=	/usr/local
SCRIPTS=	1 2 3 ctrlaltdel

PACKAGE=runit-1.3.2
DIRS=doc man etc package src
MANPAGES=runit.8 runit-init.8 runsvdir.8 runsv.8 sv.8 svwaitdown.8 svwaitup.8 \
utmpset.8 runsvchdir.8 runsvstat.8 runsvctrl.8 svlogd.8 chpst.8

.PHONY: all install clean

all: clean .manpages $(DAEMONTOOLS_PD).tar.gz $(PACKAGE).tar.gz

all:
	$(CC) $(CFLAGS) halt.c -o halt $(LDFLAGS)
	$(CC) $(CFLAGS) pause.c -o pause $(LDFLAGS)
	$(CC) $(CFLAGS) vlogger.c -o vlogger $(LDFLAGS)
	$(CC) $(CFLAGS) seedrng.c -o seedrng $(LDFLAGS)

install:
	install -d ${DESTDIR}/${PREFIX}/sbin
	install -m755 halt ${DESTDIR}/${PREFIX}/sbin
	install -m755 pause ${DESTDIR}/${PREFIX}/sbin
	install -m755 vlogger ${DESTDIR}/${PREFIX}/sbin
	install -m755 shutdown ${DESTDIR}/${PREFIX}/sbin/shutdown
	install -m755 modules-load ${DESTDIR}/${PREFIX}/sbin/modules-load
	install -m755 seedrng ${DESTDIR}/${PREFIX}/sbin/seedrng
	install -m755 zzz ${DESTDIR}/${PREFIX}/sbin
	ln -sf zzz ${DESTDIR}/${PREFIX}/sbin/ZZZ
	ln -sf halt ${DESTDIR}/${PREFIX}/sbin/poweroff
	ln -sf halt ${DESTDIR}/${PREFIX}/sbin/reboot
	install -d ${DESTDIR}/${PREFIX}/share/man/man1
	install -m644 pause.1 ${DESTDIR}/${PREFIX}/share/man/man1
	install -d ${DESTDIR}/${PREFIX}/share/man/man8
	install -m644 zzz.8 ${DESTDIR}/${PREFIX}/share/man/man8
	install -m644 shutdown.8 ${DESTDIR}/${PREFIX}/share/man/man8
	install -m644 halt.8 ${DESTDIR}/${PREFIX}/share/man/man8
	install -m644 modules-load.8 ${DESTDIR}/${PREFIX}/share/man/man8
	install -m644 vlogger.8 ${DESTDIR}/${PREFIX}/share/man/man8
	ln -sf halt.8 ${DESTDIR}/${PREFIX}/share/man/man8/poweroff.8
	ln -sf halt.8 ${DESTDIR}/${PREFIX}/share/man/man8/reboot.8
	install -d ${DESTDIR}/etc/sv
	install -d ${DESTDIR}/etc/runit/runsvdir
	install -d ${DESTDIR}/etc/runit/core-services
	install -d ${DESTDIR}/etc/runit/shutdown.d
	install -m644 core-services/*.sh ${DESTDIR}/etc/runit/core-services
	install -m644 shutdown.d/*.sh ${DESTDIR}/etc/runit/shutdown.d
	install -m755 ${SCRIPTS} ${DESTDIR}/etc/runit
	install -m644 functions $(DESTDIR)/etc/runit
	install -m644 crypt.awk  ${DESTDIR}/etc/runit
	install -m644 rc.conf ${DESTDIR}/etc
	install -m755 rc.local ${DESTDIR}/etc
	install -m755 rc.shutdown ${DESTDIR}/etc
	install -d ${DESTDIR}/${PREFIX}/lib/dracut/dracut.conf.d
	install -m644 dracut/*.conf ${DESTDIR}/${PREFIX}/lib/dracut/dracut.conf.d
	ln -sf /run/runit/reboot ${DESTDIR}/etc/runit/
	ln -sf /run/runit/stopit ${DESTDIR}/etc/runit/
	cp -R --no-dereference --preserve=mode,links -v runsvdir/* ${DESTDIR}/etc/runit/runsvdir/
	cp -R --no-dereference --preserve=mode,links -v services/* ${DESTDIR}/etc/sv/

clean:
	-rm -f halt pause vlogger

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
