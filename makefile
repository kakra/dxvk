-include Makefile

CCFLAGS ?= -O3

MESON_FLAGS += \
	--buildtype=release \
	--prefix=/ \
	--strip

MESON = CFLAGS="$(CCFLAGS)" CPPFLAGS="$(CCFLAGS)" meson
NINJA = ninja

rebuild:
	$(NINJA) -C build/wine64
	$(NINJA) -C build/wine32

clean:
	rm -Rf build/wine64
	rm -Rf build/wine32

build/wine64 build/wine32::
	mkdir -p $@

build/wine32::
	$(MESON) $(MESON_FLAGS) --libdir=lib/wine --cross-file=$(subst /,-,$@).txt $@

build/wine64::
	$(MESON) $(MESON_FLAGS) --libdir=lib64/wine --cross-file=$(subst /,-,$@).txt $@

configure: build/wine64 build/wine32

install:
	rm -Rf dist/
	DESTDIR=$(shell pwd)/dist $(NINJA) -C build/wine64 install
	DESTDIR=$(shell pwd)/dist $(NINJA) -C build/wine32 install

dist: install
	tar cJf dist.tar.xz dist/
