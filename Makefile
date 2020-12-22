SHELL := /bin/sh
.SUFFIXES :=

GIT_REV_COUNT != git rev-list --count HEAD 2>/dev/null || echo '0'
GIT_REV_SHORT != git rev-parse --short HEAD 2>/dev/null || echo '0000'
GIT_DIRTY != git diff --no-ext-diff --quiet --exit-code && echo '' || echo '+'
GIT_VERSION := r$(GIT_REV_COUNT).$(GIT_REV_SHORT)$(GIT_DIRTY)
GIT_DATE != git log -1 --format='%as' 2>/dev/null || date '+%Y-%m-%d'

SRC := filer

all: README.pod urxvt-filer.1.gz

README.pod: $(SRC)
	podselect $? \
	    | sed -e :a -e '/^\n*$$/{$$d;N;ba' -e '}' >$@

# URxvt itself installs the man pages for the core extensions in section 1
# with a page header of RXVT-UNICODE (see man 1 urxvt-matcher).
# Removes the INSTALLATION section from the man page.
urxvt-filer.1.gz: $(SRC)
	podselect -section '^(?!.*INSTALLATION).*$$' $? \
	    | pod2man --utf8 --section=1 --quotes=\" --name=urxvt-filer \
	              --nourl \
	              --date=$(GIT_DATE) --release=$(GIT_VERSION) \
	              --center=RXVT-UNICODE \
	    | gzip -9 >$@

tidy:
	perltidy -b $(SRC)

check:
	perlcritic --quiet --harsh --verbose 8 $(SRC)
	perltidy -st -se -ast $(SRC) >/dev/null

clean:
	rm -f urxvt-filer.1.gz

dist-clean: clean
	rm -f *.bak *.tdy

install:
	@echo 'No generic installation provided.'
	@echo 'To install into the users HOME directory, run `$(MAKE) install-home`.'

install-home: $(SRC) urxvt-filer.1.gz
	install -m 644 -Dt "$$HOME/.urxvt/ext/" $(SRC)
	install -m 644 -Dt "$$HOME/.local/share/man/man1/" urxvt-filer.1.gz

.PHONY: all tidy check clean dist-clean install install-home
