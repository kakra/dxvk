MESON_FLAGS += \
	--buildtype=release \
	--prefix=/ \
	--strip

MESON = meson
NINJA = ninja

DXVK_DLLS = \
	d3d10.dll \
	d3d10_1.dll \
	d3d10core.dll \
	d3d11.dll \
	dxgi.dll

LIB_DLLS_32 = $(DXVK_DLLS:%=dist/lib/wine/dxvk/%)
LIB_DLLS_64 = $(DXVK_DLLS:%=dist/lib64/wine/dxvk/%)

ifndef VERBOSE
MESON += >$(abspath mesonoutput.log)
NINJA += >$(abspath ninjaoutput.log)
.SILENT:
endif

dist:: dist.tar.xz

rebuild::
	$(NINJA) -C build/wine64
	$(NINJA) -C build/wine32

clean::
	rm -Rf build/

FORCE:

build/wine32/build.ninja: LIBDIR=lib
build/wine64/build.ninja: LIBDIR=lib64

build/%/build.ninja: build-%.txt makefile
	echo "Configuring sacred $(@:build/wine%/build.ninja=%)-bit DXVK libraries..."
	$(MESON) $(MESON_FLAGS) --libdir=$(LIBDIR)/wine/dxvk --cross-file=$< $(dir $@)

makefiles:: build/wine64/build.ninja build/wine32/build.ninja
configure: makefiles

build/%: build/%/build.ninja FORCE
	echo "Building $(@:build/wine%=%)-bit DXVK libraries..."
	DESTDIR=$(abspath dist) $(NINJA) -C $@ install

$(LIB_DLLS_32:%.dll=%.dll.so):: build/wine32
$(LIB_DLLS_64:%.dll=%.dll.so):: build/wine64

$(LIB_DLLS_32) $(LIB_DLLS_64): %.dll: %.dll.so
	install -D $< $@

dist.tar.xz: $(LIB_DLLS_32) $(LIB_DLLS_64)
	echo "Creating DXVK distribution..."
	tar cJf $@ $^
