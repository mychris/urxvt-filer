SHELL := /bin/sh

GIT_REV_COUNT != git rev-list --count HEAD 2>/dev/null || echo '0'
GIT_REV_SHORT != git rev-parse --short HEAD 2>/dev/null || echo '0000'
GIT_DIRTY != git diff --no-ext-diff --quiet --exit-code && echo '' || echo '+'
GIT_VERSION := r$(GIT_REV_COUNT).$(GIT_REV_SHORT)$(GIT_DIRTY)
GIT_DATE != git log -1 --format='%as' 2>/dev/null || date '+%Y-%m-%d'

all: README.pod urxvt-file-chooser.1.gz

README.pod: file-chooser
	podselect $< | sed -e :a -e '/^\n*$$/{$$d;N;ba' -e '}' >$@

# URxvt itself installs the man pages for the core extensions in section 1
# with a page header of RXVT-UNICODE (see man 1 urxvt-matcher)
urxvt-file-chooser.1: file-chooser
	pod2man --utf8 --section=1 --quotes=\" --name=urxvt-file-chooser \
	        --date=$(GIT_DATE) --release=$(GIT_VERSION) \
	        --center=RXVT-UNICODE $< $@

urxvt-file-chooser.1.gz: urxvt-file-chooser.1
	gzip -c $< >$@

tidy: file-chooser
	perltidy -b $<

check: file-chooser
	perlcritic --quiet --harsh --verbose 8 $<
	perltidy -st -se -ast $< >/dev/null

clean:
	rm -f urxvt-file-chooser.1 urxvt-file-chooser.1.gz

dist-clean: clean
	rm -f *.bak *.tdy

install:
	@echo 'No generic installation provided.'
	@echo 'To install into the users HOME directory, run `make install-home`.'

install-home: file-chooser urxvt-file-chooser.1.gz
	install -m 644 -Dt "$$HOME/.urxvt/ext/" file-chooser
	install -m 644 -Dt "$$HOME/.local/share/man/man1/" urxvt-file-chooser.1.gz

.PHONY: all tidy check clean dist-clean install install-home

