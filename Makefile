# Makefile

SHELL := sh -e

LANGUAGES = $(shell cd manpages/po && ls)

SCRIPTS = frontend/live-build-cgi frontend/live-build-cgi.cron frontend/live-build-cgi-status

all: build

test:
	@echo -n "Checking for syntax errors"

	@for SCRIPT in $(SCRIPTS); \
	do \
		sh -n $${SCRIPT}; \
		echo -n "."; \
	done

	@echo " done."

	@echo -n "Checking for bashisms"

	@if [ -x /usr/bin/checkbashisms ]; \
	then \
		for SCRIPT in $(SCRIPTS); \
		do \
			checkbashisms -f -x $${SCRIPT}; \
			echo -n "."; \
		done; \
	else \
		echo "WARNING: skipping bashism test - you need to install devscripts."; \
	fi

	@echo " done."

build:
	@echo "Nothing to build."

install:
	# Installing shared data
	mkdir -p $(DESTDIR)/usr/share/live/build-cgi
	cp -r frontend/* templates VERSION $(DESTDIR)/usr/share/live/build-cgi

	# Installing executables
	install -D -m 0755 frontend/live-build-cgi $(DESTDIR)/usr/lib/cgi-bin/live-build-cgi
	install -D -m 0755 frontend/live-build-cgi-status $(DESTDIR)/usr/lib/cgi-bin/live-build-cgi-status

	# Installing crontabs and defaults
	install -D -m 0755 frontend/live-build-cgi.cron $(DESTDIR)/etc/cron.hourly/live-build-cgi
	install -D -m 0644 frontend/live-build-cgi.crontab $(DESTDIR)/etc/cron.d/live-build-cgi
	install -D -m 0644 frontend/live-build-cgi.default $(DESTDIR)/etc/default/live-build-cgi
	install -D -m 0644 frontend/live-build-cgi.logrotate $(DESTDIR)/etc/logrotate.d/live-build-cgi

	# Installing log structure
	mkdir -p $(DESTDIR)/var/log/live-build-cgi
	chown www-data:www-data $(DESTDIR)/var/log/live-build-cgi

	# Installing manpages
	for MANPAGE in manpages/en/*; \
	do \
		SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$2 }')"; \
		install -D -m 0644 $${MANPAGE} $(DESTDIR)/usr/share/man/man$${SECTION}/$$(basename $${MANPAGE}); \
	done

	for LANGUAGE in $(LANGUAGES); \
	do \
		for MANPAGE in manpages/$${LANGUAGE}/*; \
		do \
			SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$3 }')"; \
			install -D -m 0644 $${MANPAGE} $(DESTDIR)/usr/share/man/$${LANGUAGE}/man$${SECTION}/$$(basename $${MANPAGE} .$${LANGUAGE}.$${SECTION}).$${SECTION}; \
		done; \
	done

uninstall:
	# Uninstalling shared data
	rm -rf $(DESTDIR)/usr/share/live/build-cgi
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/live > /dev/null 2>&1 || true

	# Uninstalling executables
	rm -f $(DESTDIR)/usr/lib/cgi-bin/live-build-cgi
	rm -f $(DESTDIR)/usr/lib/cgi-bin/live-build-cgi-status

	# Uninstalling crontabs and defaults
	rm -f $(DESTDIR)/etc/cron.d/live-build-cgi
	rm -f $(DESTDIR)/etc/cron.hourly/live-build-cgi
	rm -f $(DESTDIR)/etc/default/live-build-cgi
	rm -f $(DESTDIR)/etc/logrotate.d/live-build-cgi

	# Uninstalling log structure
	rm -rf $(DESTDIR)/var/log/live-build-cgi

	# Uninstalling manpages
	for MANPAGE in manpages/en/*; \
	do \
		SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$2 }')"; \
		rm -f $(DESTDIR)/usr/share/man/man$${SECTION}/$$(basename $${MANPAGE} .en.$${SECTION}).$${SECTION}; \
	done

	for LANGUAGE in $(LANGUAGES); \
	do \
		for MANPAGE in manpages/$${LANGUAGE}/*; \
		do \
			SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$3 }')"; \
			rm -f $(DESTDIR)/usr/share/man/$${LANGUAGE}/man$${SECTION}/$$(basename $${MANPAGE} .$${LANGUAGE}.$${SECTION}).$${SECTION}; \
		done; \
	done

clean:

distclean:

reinstall: uninstall install
