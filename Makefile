SCP?=scp

all: build

.PHONY: serve
serve: build
	php -S localhost:8000 -t build

.PHONY: s
s: serve

.PHONY: cs
rs: | clean serve

build:
	bin/blog.sh

.PHONY: clean
clean:
	rm -fr build

push: PRODUCTION=true
push:
	PRODUCTION="$(PRODUCTION)" make clean all
	bin/blog.sh push

ftppush: PRODUCTION=true
ftppush:
	PRODUCTION="$(PRODUCTION)" make clean all
	bin/blog.sh ftppush
