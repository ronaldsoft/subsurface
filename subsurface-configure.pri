#
# Global settings
#
# Set some C constructs to be diagnosed as errors:
#  - calling implicit functions
#  - casting from integers to pointers or vice-versa without an explicit cast
# Also turn on C99 mode with GNU extensions
*-g++*: QMAKE_CFLAGS += -Werror=int-to-pointer-cast -Werror=pointer-to-int-cast -Werror=implicit-int
!win32-msvc*: QMAKE_CFLAGS += -std=gnu99

# Don't turn warnings on (but don't suppress them either)
CONFIG -= warn_on warn_off

# Turn exceptions off
!win32-msvc*: QMAKE_CXXFLAGS += -fno-exceptions
CONFIG += exceptions_off

# Check if we have pkg-config
equals($$QMAKE_HOST.os, "Windows"):NUL=NUL
else:NUL=/dev/null
system(pkg-config --version 2>$$NUL >$$NUL) {
    CONFIG += link_pkgconfig
} else {
    message("pkg-config not found, no detection performed. See README for details")
}

#
# Find libdivecomputer
#
!isEmpty(LIBDCDEVEL) {
    # find it next to our sources
    INCLUDEPATH += ../libdivecomputer/include
    LIBS += ../libdivecomputer/src/.libs/libdivecomputer.a
    # Libusb-1.0 is only required if libdivecomputer was built with it.
    # And libdivecomputer is only built with it if libusb-1.0 is
    # installed. So get libusb if it exists, but don't complain
    # about it if it doesn't.
    LIBS += $$system(pkg-config --libs libusb-1.0 2> /dev/null)
} else:exists(/usr/local/lib/libdivecomputer.a) {
    LIBS += -L/usr/local/lib -ldivecomputer
} else:exists(/usr/local/lib64/libdivecomputer.a) {
    LIBS += -L/usr/local/lib64 -ldivecomputer
} else:link_pkgconfig {
    # find it via pkg-config
    PKGCONFIG += libdivecomputer
}

# Libusb-1.0 is only required if libdivecomputer was built with it.
# And libdivecomputer is only built with it if libusb-1.0 is
# installed. So get libusb if it exists, but don't complain
# about it if it doesn't.
#link_pkgconfig: packagesExist(libusb-1.0): PKGCONFIG += libusb-1.0

#
# Find libxml2 and libxslt
#
# They come with shell scripts that contain the information we need, so we just
# run them. They also come with pkg-config files, but those are missing on
# Mac (where they are part of the XCode-supplied tools).
#
XML2_CFLAGS = $$system(xml2-config --cflags 2>$$NUL)
XSLT_CFLAGS = $$system(xslt-config --cflags 2>$$NUL)
XML2_LIBS = $$system(xml2-config --libs 2>$$NUL)
XSLT_LIBS = $$system(xslt-config --libs 2>$$NUL)
link_pkgconfig {
    isEmpty(XML2_CFLAGS)|isEmpty(XML2_LIBS): \
        error("Could not find libxml2. Did you forget to install it?")
    isEmpty(XSLT_CFLAGS)|isEmpty(XSLT_LIBS): \
        error("Could not find libxslt. Did you forget to install it?")
}

QMAKE_CFLAGS *= $$XML2_CFLAGS $$XSLT_CFLAGS
QMAKE_CXXFLAGS *= $$XML2_CFLAGS $$XSLT_CFLAGS
LIBS *= $$XML2_LIBS $$XSLT_LIBS

#
# Find other pkg-config-based projects
# We're searching for:
#  libzip
#  sqlite3
link_pkgconfig: PKGCONFIG += libzip sqlite3

#
# Find libmarble
#
# Before Marble 4.9, the GeoDataTreeModel.h header wasn't installed
# Check if it's present by trying to compile
# ### FIXME: implement that
win32: CONFIG(debug, debug|release): LIBS += -lmarblewidgetd
else: LIBS += -lmarblewidget

#
# Platform-specific changes
#
win32 {
    LIBS += -lwsock32
    DEFINES -= UNICODE
}

#
# misc
#
!equals(V, 1): CONFIG += silent
MOC_DIR = .moc
UI_DIR = .uic
RCC_DIR = .rcc
OBJECTS_DIR = .obj