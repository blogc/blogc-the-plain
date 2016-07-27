# Content

AUTHOR_NAME = "Author"
AUTHOR_EMAIL = "author@example.org"
AUTHOR_GRAVATAR = "00000000000000000000000000000000"
SITE_TITLE = "Site Title"
SITE_TAGLINE = "Site Tagline"
LOCALE = "en_US.utf-8"

POSTS_PER_PAGE_ATOM = 10

POSTS = \
	post2 \
	post1 \
	$(NULL)

PAGES = \
	about \
	$(NULL)

ASSETS = \
	assets/core.css \
	$(NULL)


# Arguments

BLOGC ?= $(shell which blogc)
BLOGC_RUNSERVER ?= $(shell which blogc-runserver 2> /dev/null)
MKDIR ?= $(shell which mkdir)
CP ?= $(shell which cp)

BLOGC_RUNSERVER_HOST ?= 127.0.0.1
BLOGC_RUNSERVER_PORT ?= 8080

OUTPUT_DIR ?= _build
BASE_DOMAIN ?= http://example.org
BASE_URL ?=

DATE_FORMAT = "%B %d, %Y"
DATE_FORMAT_INDEX = "%b %d, %Y"
DATE_FORMAT_ATOM = "%Y-%m-%dT%H:%M:%SZ"

BLOGC_COMMAND = \
	LC_ALL=$(LOCALE) \
	$(BLOGC) \
		-D AUTHOR_NAME=$(AUTHOR_NAME) \
		-D AUTHOR_EMAIL=$(AUTHOR_EMAIL) \
		-D AUTHOR_GRAVATAR=$(AUTHOR_GRAVATAR) \
		-D SITE_TITLE=$(SITE_TITLE) \
		-D SITE_TAGLINE=$(SITE_TAGLINE) \
		-D BASE_DOMAIN=$(BASE_DOMAIN) \
		-D BASE_URL=$(BASE_URL) \
	$(NULL)


# Rules

all: \
	$(OUTPUT_DIR)/index.html \
	$(OUTPUT_DIR)/atom.xml \
	$(addprefix $(OUTPUT_DIR)/, $(ASSETS)) \
	$(addprefix $(OUTPUT_DIR)/post/, $(addsuffix /index.html, $(POSTS))) \
	$(addprefix $(OUTPUT_DIR)/, $(addsuffix /index.html, $(PAGES)))

$(OUTPUT_DIR)/index.html: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT_INDEX) \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/atom.xml: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/atom.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT_ATOM) \
		-D FILTER_PAGE=1 \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE_ATOM) \
		-l \
		-o $@ \
		-t templates/atom.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

IS_POST = 0

$(OUTPUT_DIR)/post/%/index.html: IS_POST = 1

$(OUTPUT_DIR)/%/index.html: content/%.txt templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		$(shell test "$(IS_POST)" -eq 1 && echo -D IS_POST=1) \
		-o $@ \
		-t templates/main.tmpl \
		$<

$(OUTPUT_DIR)/assets/%: assets/% Makefile
	$(MKDIR) -p $(dir $@) && \
		$(CP) $< $@

ifneq ($(BLOGC_RUNSERVER),)
.PHONY: serve
serve: all
	$(BLOGC_RUNSERVER) \
		-t $(BLOGC_RUNSERVER_HOST) \
		-p $(BLOGC_RUNSERVER_PORT) \
		$(OUTPUT_DIR)
endif

clean:
	rm -rf "$(OUTPUT_DIR)"

.PHONY: all clean
