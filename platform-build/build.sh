#!/bin/bash

#------------------------------------------------------------------------------
#
# This script fetches and builds all of TrickPlay's dependencies.
#
# 1) With no parameters, it builds everything in order and keeps track of
#    what has been built in a file called "built". This lets it keep going where
#    it left off if there is a problem.
#
# 2) With only the parameter 'clean', it deletes the 'built' file and builds
#    everything in order - calling 'make clean' before each one.
#
# 3) With more paramaters, it builds only what is specified, ignoring what the
#    'built' file says. For example 'build.sh GLIB ZLIB' will only build GLIB
#    and ZLIB.
#
#    If one of the parameters is 'clean', it will do 'make clean' before
#    building each one.
#
# By default, stdout is redirected to /dev/null. To see all output, call the
# script like this: 'VERBOSE=1 ./build.sh <parameters>'
#
# To build dynamic versions of clutter and libtpcore, set the environment variable DYNAMIC_BUILD=1
#
#------------------------------------------------------------------------------

set -u
set -e

#------------------------------------------------------------------------------
# This brings in the build environment

THERE=$(cd ${0%/*} && echo $PWD/${0##*/})
THERE=`dirname ${THERE}`

source "${THERE}/env"


#DYNAMIC_BUILD=${DYNAMIC_BUILD:-0}
DYNAMIC_BUILD=1

if [[ ${DYNAMIC_BUILD} == 1 ]]
then
    TP_CORE_SHARED="-DTP_CORE_SHARED=1"
    SHARED="--enable-shared --disable-static"
    ZLIB_SHARED="--shared"
    echo "DYMAMIC build selected"
else
    TP_CORE_SHARED=""
    SHARED="--disable-shared"
    ZLIB_SHARED=""
    echo "STATIC build selected"
fi

if [[ `uname` == 'Linux' ]]
then
	NUM_MAKE_JOBS=-j`awk '/processor/{num_procs+=1} END {print num_procs+1}' /proc/cpuinfo`
	echo "Setting NUM_MAKE_JOBS to '${NUM_MAKE_JOBS}'"
else
	NUM_MAKE_JOBS='-j8'
fi

#------------------------------------------------------------------------------

PROFILING="0"

#------------------------------------------------------------------------------

VERBOSE=${VERBOSE:-0}

if [[ ${VERBOSE} == 1 ]]
then
    OUT=/dev/stdout
else
    OUT=/dev/null
fi

#------------------------------------------------------------------------------
# libiconv

ICONV_V="1.14"
ICONV_DIST="libiconv-${ICONV_V}.tar.gz"
ICONV_SOURCE="libiconv-${ICONV_V}"
ICONV_COMMANDS="gl_cv_header_working_stdint_h=yes ./configure --host=$HOST --prefix=$PREFIX --build=$BUILD $SHARED --with-pic --disable-dependency-tracking && make ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# gettext

GET_TEXT_V="0.18.1.1"
GET_TEXT_DIST="gettext-${GET_TEXT_V}.tar.gz"
GET_TEXT_SOURCE="gettext-${GET_TEXT_V}"
GET_TEXT_COMMANDS="gl_cv_header_working_stdint_h=yes ./configure --host=$HOST --prefix=$PREFIX --build=$BUILD $SHARED --with-pic && make ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"
GET_TEXT_DEPENDS="ICONV"

#------------------------------------------------------------------------------
# libbind
LIBBIND_V="6.0"
LIBBIND_DIST="libbind-${LIBBIND_V}.tar.gz"
LIBBIND_SOURCE="libbind-${LIBBIND_V}"
LIBBIND_URL="ftp://ftp.isc.org/isc/libbind/${LIBBIND_V}/libbind-${LIBBIND_V}.tar.gz"
LIBBIND_COMMANDS="./configure --host=${HOST} --with-randomdev=/dev/random --prefix=$PREFIX && make CFLAGS='$CFLAGS -Iinclude' AR='$AR' ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# libffi

LIBFFI_MV="3.0"
LIBFFI_V="${LIBFFI_MV}.10"
LIBFFI_URL="ftp://sourceware.org/pub/libffi/libffi-${LIBFFI_V}.tar.gz"
LIBFFI_DIST="libffi-${LIBFFI_V}.tar.gz"
LIBFFI_SOURCE="libffi-${LIBFFI_V}"
LIBFFI_COMMANDS="./configure --host=$HOST --prefix=$PREFIX --build=$BUILD $SHARED --with-pic && make ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# glib

GLIB_MV="2.30"
GLIB_V="${GLIB_MV}.2"
GLIB_URL="http://ftp.acc.umu.se/pub/GNOME/sources/glib/${GLIB_MV}/glib-${GLIB_V}.tar.xz"
GLIB_DIST="glib-${GLIB_V}.tar.xz"
GLIB_SOURCE="glib-${GLIB_V}"
GLIB_COMMANDS="(./autogen.sh 2>/dev/null) ; cp ${THERE}/files/config.{sub,guess} . && patch -p1 -i ${THERE}/patches/${GLIB_SOURCE}/NOT-IN-QUILT-APPLIED-AFTER-AUTOCONF-fixup-config-for-android.patch && PATH=$PREFIX/host/bin:$PATH glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=no ac_cv_func_posix_getgrgid_r=no glib_cv_have_qsort_r=no ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED ${GLIB_ICONV} --disable-fam --with-pic CFLAGS=\"$CFLAGS -DG_DISABLE_CHECKS -DG_DISABLE_CAST_CHECKS -I${PREFIX}/include/bind\" && make ${NUM_MAKE_JOBS} install"
GLIB_DEPENDS="LIBFFI"

#------------------------------------------------------------------------------
# We build glib for the host system first, so the cross compiled one can get
# glib-genmarhsal and glib-compile-schemas without having to install a new glib
# on the host system.

GLIB_HOST_DIST="glib-${GLIB_V}.tar.xz"
GLIB_HOST_SOURCE="glib-${GLIB_V}"
GLIB_HOST_COMMANDS="env -i PATH=$PATH ./configure --prefix=$PREFIX/host --disable-fam && make ${NUM_MAKE_JOBS} install && cd .. && rm -rf ./$GLIB_HOST_SOURCE"

#------------------------------------------------------------------------------
# sqlite

SQLITE_V="3071000"
SQLITE_DIST="sqlite-autoconf-${SQLITE_V}.tar.gz"
SQLITE_SOURCE="sqlite-autoconf-${SQLITE_V}"
SQLITE_COMMANDS="./configure --prefix=$PREFIX --host=$HOST  --build=$BUILD --with-pic $SHARED && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# openssl

OPENSSL_V="1.0.0g"
OPENSSL_URL="http://www.openssl.org/source/openssl-${OPENSSL_V}.tar.gz"
OPENSSL_DIST="openssl-${OPENSSL_V}.tar.gz"
OPENSSL_SOURCE="openssl-${OPENSSL_V}"
OPENSSL_COMMANDS="./Configure dist threads --prefix=$PREFIX -fPIC -D_REENTRANT && make CC=$CC RANLIB=$RANLIB AR=\"$AR r\" CXX=$CXX ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# zlib

ZLIB_V="1.2.3"
ZLIB_URL="http://www.zlib.net/zlib-${ZLIB_V}.tar.gz"
ZLIB_DIST="zlib-${ZLIB_V}.tar.gz"
ZLIB_SOURCE="zlib-${ZLIB_V}"
ZLIB_COMMANDS="./configure --prefix=$PREFIX ${ZLIB_SHARED} && make CC=\"$CC\" AR=\"$AR r\" CFLAGS=\"-fPIC\" ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# cares

CARES_V="1.7.5"
CARES_URL="http://c-ares.haxx.se/c-ares-${CARES_V}.tar.gz"
CARES_DIST="c-ares-${CARES_V}.tar.gz"
CARES_SOURCE="c-ares-${CARES_V}"
CARES_COMMANDS="curl_cv_func_recv_args='int,void *,size_t,unsigned int,ssize_t' curl_cv_func_send_args='int,const void *,size_t,unsigned int,ssize_t' curl_cv_func_recvfrom_args='int,void *,size_t,unsigned int,struct sockaddr *,socklen_t *,ssize_t' curl_cv_func_getnameinfo_args='const struct sockaddr *,socklen_t,size_t,int' ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic --disable-dependency-tracking && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# curl

CURL_V="7.24.0"
CURL_URL="http://curl.haxx.se/download/curl-${CURL_V}.tar.bz2"
CURL_DIST="curl-${CURL_V}.tar.bz2"
CURL_SOURCE="curl-${CURL_V}"
CURL_COMMANDS="curl_cv_func_recv_args='int,void *,size_t,unsigned int,ssize_t' curl_cv_func_send_args='int,const void *,size_t,unsigned int,ssize_t' curl_cv_func_recvfrom_args='int,void *,size_t,unsigned int,struct sockaddr *,socklen_t *,ssize_t' curl_cv_func_getnameinfo_args='const struct sockaddr *,socklen_t,size_t,int' ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic --enable-ares --with-ssl --with-zlib --without-random --disable-file --disable-ldap --disable-ldaps --disable-rtsp --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smtp --disable-manual --disable-dict && make ${NUM_MAKE_JOBS} install"
CURL_DEPENDS="CARES ZLIB OPENSSL"
#------------------------------------------------------------------------------
# bzip

BZIP_V="1.0.6"
BZIP_URL="http://www.bzip.org/${BZIP_V}/bzip2-${BZIP_V}.tar.gz"
BZIP_DIST="bzip2-${BZIP_V}.tar.gz"
BZIP_SOURCE="bzip2-${BZIP_V}"
BZIP_COMMANDS="make CC=\"$CC\" AR=\"$AR\" RANLIB=\"$RANLIB\" LDFLAGS=\"$LDFLAGS\" CFLAGS=\"-fPIC $CFLAGS\" PREFIX=\"$PREFIX\" ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# tokyo (DEPRECATED IN 0.0.8)

#TOKYO_V="1.4.42"
#TOKYO_DIST="tokyocabinet-${TOKYO_V}.tar.gz"
#TOKYO_SOURCE="tokyocabinet-${TOKYO_V}"
#TOKYO_COMMANDS="CFLAGS=\"${CFLAGS} -D_SYS_OPENBSD_=1\" ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --disable-shared --with-pic && make ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"
#TOKYO_DEPENDS="BZIP"

#------------------------------------------------------------------------------
# expat

EXPAT_V="2.0.1"
EXPAT_URL="http://sourceforge.net/projects/expat/files/expat/${EXPAT_V}/expat-${EXPAT_V}.tar.gz/download"
EXPAT_DIST="expat-${EXPAT_V}.tar.gz"
EXPAT_SOURCE="expat-${EXPAT_V}"
EXPAT_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# freetype

FREETYPE_V="2.4.8"
FREETYPE_URL="http://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_V}.tar.bz2"
FREETYPE_DIST="freetype-${FREETYPE_V}.tar.bz2"
FREETYPE_SOURCE="freetype-${FREETYPE_V}"
FREETYPE_COMMANDS="CFLAGS='$CFLAGS -std=gnu99' ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# fontconfig

FONTCONFIG_V="2.8.0"
FONTCONFIG_URL="http://fontconfig.org/release/fontconfig-${FONTCONFIG_V}.tar.gz"
FONTCONFIG_DIST="fontconfig-${FONTCONFIG_V}.tar.gz"
FONTCONFIG_SOURCE="fontconfig-${FONTCONFIG_V}"
FONTCONFIG_COMMANDS="(./autogen.sh 2>/dev/null) ; patch -p1 -i ${THERE}/patches/${FONTCONFIG_SOURCE}/NOT-IN-QUILT-APPLIED-AFTER-AUTOCONF-fixup-config-for-android.patch && ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --with-arch=$ARCH $SHARED --with-pic --with-freetype-config=\"$PREFIX/bin/freetype-config\" && V=$VERBOSE make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# pixman

PIXMAN_V="0.24.2"
PIXMAN_URL="http://cgit.freedesktop.org/pixman/snapshot/pixman-${PIXMAN_V}.tar.gz"
PIXMAN_DIST="pixman-${PIXMAN_V}.tar.gz"
PIXMAN_SOURCE="pixman-${PIXMAN_V}"
PIXMAN_COMMANDS="(./autogen.sh 2>/dev/null) ; patch -p1 -i ${THERE}/patches/${PIXMAN_SOURCE}/NOT-IN-QUILT-APPLIED-AFTER-AUTOCONF-fixup-config-for-android.patch && ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic --disable-gtk && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# png

PNG_V="1.5.7"
PNG_URL="http://download.sourceforge.net/libpng/libpng-${PNG_V}.tar.xz"
PNG_DIST="libpng-${PNG_V}.tar.xz"
PNG_SOURCE="libpng-${PNG_V}"
PNG_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# cairo

CAIRO_V="1.10.2"
CAIRO_URL="http://cairographics.org/releases/cairo-${CAIRO_V}.tar.gz"
CAIRO_DIST="cairo-${CAIRO_V}.tar.gz"
CAIRO_SOURCE="cairo-${CAIRO_V}"
CAIRO_COMMANDS="CFLAGS=\"${CFLAGS} -DPNG_SKIP_SETJMP_CHECK=1\" ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic --disable-xlib --disable-ps --disable-pdf --disable-svg && make ${NUM_MAKE_JOBS} install"
CAIRO_DEPENDS="PIXMAN PNG"

#------------------------------------------------------------------------------
# pango

PANGO_MV="1.28"
PANGO_V="${PANGO_MV}.4"
PANGO_URL="http://ftp.gnome.org/pub/GNOME/sources/pango/${PANGO_MV}/pango-${PANGO_V}.tar.bz2"
PANGO_DIST="pango-${PANGO_V}.tar.bz2"
PANGO_SOURCE="pango-${PANGO_V}"
PANGO_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD --without-x $SHARED --with-pic --with-included-modules=yes && make ${NUM_MAKE_JOBS} install"
PANGO_DEPENDS="CAIRO FREETYPE FONTCONFIG"
#------------------------------------------------------------------------------
# jpeg

JPEG_V="8d"
JPEG_URL="http://www.ijg.org/files/jpegsrc.v${JPEG_V}.tar.gz"
JPEG_DIST="jpegsrc.v${JPEG_V}.tar.gz"
JPEG_SOURCE="jpeg-${JPEG_V}"
JPEG_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic --disable-ld-version-script && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# tiff

TIFF_V="4.0.0"
TIFF_URL="ftp://ftp.remotesensing.org/pub/libtiff/tiff-${TIFF_V}.tar.gz"
TIFF_DIST="tiff-${TIFF_V}.tar.gz"
TIFF_SOURCE="tiff-${TIFF_V}"
TIFF_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# gif

GIF_V="4.1.6"
GIF_URL="http://sourceforge.net/projects/giflib/files/giflib%204.x/giflib-${GIF_V}/giflib-${GIF_V}.tar.gz/download"
GIF_DIST="giflib-${GIF_V}.tar.gz"
GIF_SOURCE="giflib-${GIF_V}"
GIF_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# json

JSON_MV="0.12"
JSON_V="${JSON_MV}.6"
JSON_URL="http://ftp.gnome.org/pub/GNOME/sources/json-glib/${JSON_MV}/json-glib-${JSON_V}.tar.xz"
JSON_DIST="json-glib-${JSON_V}.tar.xz"
JSON_SOURCE="json-glib-${JSON_V}"
JSON_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic --disable-glibtest && make ${NUM_MAKE_JOBS} install"
JSON_DEPENDS="GLIB"

#------------------------------------------------------------------------------
# ATK

ATK_MV="2.2"
ATK_V="${ATK_MV}.0"
ATK_URL="http://ftp.gnome.org/pub/gnome/sources/atk/${ATK_MV}/atk-${ATK_V}.tar.xz"
ATK_DIST="atk-${ATK_V}.tar.xz"
ATK_SOURCE="atk-${ATK_V}"
ATK_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# uprof

UPROF_MV="0.3"
UPROF_V="${UPROF_MV}"
UPROF_URL="http://uprof.freedesktop.org/releases/uprof/uprof-${UPROF_V}.tar.gz"
UPROF_DIST="uprof-${UPROF_V}.tar.gz"
UPROF_SOURCE="uprof-${UPROF_V}"
UPROF_COMMANDS="./autogen.sh --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic && make ${NUM_MAKE_JOBS} install"
UPROF_DEPENDS="GLIB"

#------------------------------------------------------------------------------
# cogl
COGL_MV="1.8"
COGL_V="${COGL_MV}.2"
COGL_DIST="cogl-${COGL_V}.tar.xz"
COGL_SOURCE="cogl-${COGL_V}"
CLUTTER_PROFILING=""
if [[ $PROFILING != "0" ]]
then
    CLUTTER_PROFILING="--enable-profile=yes"
fi
COGL_COMMANDS="./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic --enable-gles2=yes --enable-gl=no --enable-glx=no --enable-xlib-egl-platform=no --enable-android-egl-platform=yes $CLUTTER_PROFILING --disable-glibtest --enable-gtk-doc-html=no CFLAGS=\"$CFLAGS -DG_DISABLE_CHECKS -DG_DISABLE_CAST_CHECKS -landroid\" && V=$VERBOSE make ${NUM_MAKE_JOBS} install"
COGL_DEPENDS="GLIB PANGO FREETYPE CAIRO FONTCONFIG UPROF"

#------------------------------------------------------------------------------
# clutter

CLUTTER_MV="1.8"
CLUTTER_V="${CLUTTER_MV}.2"
CLUTTER_URL="http://source.clutter-project.org/sources/clutter/${CLUTTER_MV}/clutter-${CLUTTER_V}.tar.xz"
CLUTTER_DIST="clutter-${CLUTTER_V}.tar.xz"
CLUTTER_SOURCE="clutter-${CLUTTER_V}"

#Override Clutter CFLAGS so that it is not built optimized

CLUTTER_COMMANDS="ac_cv_lib_EGL_eglInitialize=yes ac_cv_lib_GLES2_CM_eglInitialize=yes ac_cv_func_malloc_0_nonnull=yes ./configure --prefix=$PREFIX --host=$HOST --build=$BUILD $SHARED --with-pic --with-flavour=eglnative --with-gles=${GLES} --enable-conformance=no --disable-glibtest --enable-gtk-doc-html=no $CLUTTER_PROFILING CFLAGS=\"$CFLAGS -DG_DISABLE_CHECKS -DG_DISABLE_CAST_CHECKS\" && V=$VERBOSE make ${NUM_MAKE_JOBS} install"
CLUTTER_DEPENDS="GLIB PANGO FREETYPE CAIRO FONTCONFIG UPROF COGL"

#------------------------------------------------------------------------------
# avahi

AVAHI_V="0.6.30"
AVAHI_URL="http://avahi.org/download/avahi-${AVAHI_V}.tar.gz"
AVAHI_DIST="avahi-${AVAHI_V}.tar.gz"
AVAHI_SOURCE="avahi-${AVAHI_V}"
AVAHI_COMMANDS="./configure --host=$HOST --prefix=$PREFIX --build=$BUILD $SHARED --with-pic --disable-qt3 --disable-qt4 --disable-gtk --disable-gtk3 --disable-dbus --disable-gdbm --disable-libdaemon --disable-python --disable-pygtk --disable-python-dbus --disable-mono --disable-monodoc --disable-autoipd --disable-doxygen-doc --disable-doxygen-dot --disable-doxygen-xml --with-distro=none --disable-nls --disable-stack-protector $SHARED && make ${NUM_MAKE_JOBS} install"
AVAHI_DEPENDS="GLIB"

#------------------------------------------------------------------------------
# upnp

UPNP_V="1.6.15"
UPNP_DIST="libupnp-${UPNP_V}.tar.bz2"
UPNP_SOURCE="libupnp-${UPNP_V}"
UPNP_COMMANDS="./configure --host=$HOST --prefix=$PREFIX --build=$BUILD $SHARED --with-pic && make ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# uriparser

URI_V="0.7.6"
URI_DIST="uriparser-${URI_V}.tar.bz2"
URI_SOURCE="uriparser-${URI_V}"
URI_COMMANDS="./configure --host=$HOST --prefix=$PREFIX --build=$BUILD $SHARED --with-pic --disable-test --disable-doc && make ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# uuid

UUID_V="1.6.2"
UUID_DIST="uuid-${UUID_V}.tar.gz"
UUID_SOURCE="uuid-${UUID_V}"
UUID_COMMANDS="sed -i \"s/-c -s -m/-c -m/\" Makefile.in && ac_cv_va_copy=no ./configure --host=$HOST --prefix=$PREFIX --build=$BUILD --includedir=$PREFIX/include/ossp $SHARED --with-pic && make ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# libsndfile

SNDFILE_V="1.0.25"
SNDFILE_DIST="libsndfile-${SNDFILE_V}.tar.gz"
SNDFILE_SOURCE="libsndfile-${SNDFILE_V}"
SNDFILE_COMMANDS="./configure --host=$HOST --prefix=$PREFIX --build=$BUILD $SHARED --disable-cpu-clip  --disable-sqlite --disable-alsa --disable-external-libs --with-pic && make ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"
SNDFILE_URL="http://www.mega-nerd.com/libsndfile/files/${SNDFILE_DIST}"

#------------------------------------------------------------------------------
# libxml2

XML_V="2.7.8"
XML_DIST="libxml2-${XML_V}.tar.gz"
XML_SOURCE="libxml2-${XML_V}"
XML_COMMANDS="./configure --host=$HOST --prefix=$PREFIX --build=$BUILD $SHARED --with-pic && make ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# libsoup

SOUP_V="2.36.1"
SOUP_DIST="libsoup-${SOUP_V}.tar.xz"
SOUP_SOURCE="libsoup-${SOUP_V}"
SOUP_COMMANDS="./configure --host=$HOST --prefix=$PREFIX --build=$BUILD $SHARED --with-pic --without-gnome --disable-glibtest --disable-gtk-doc-html && make ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"

#------------------------------------------------------------------------------
# libexif

EXIF_V="0.6.20"
EXIF_DIST="libexif-${EXIF_V}.tar.gz"
EXIF_SOURCE="libexif-${EXIF_V}"
EXIF_COMMANDS="./configure --host=$HOST --prefix=$PREFIX --build=$BUILD $SHARED --with-pic --disable-docs && make ${NUM_MAKE_JOBS} && make ${NUM_MAKE_JOBS} install"
EXIF_DEPENDS="ICONV GET_TEXT"

#------------------------------------------------------------------------------

ALL="ZLIB ICONV GET_TEXT EXPAT XML EXIF LIBFFI LIBBIND GLIB SQLITE OPENSSL CARES CURL BZIP FREETYPE FONTCONFIG PIXMAN PNG CAIRO PANGO JPEG TIFF GIF JSON ATK COGL CLUTTER AVAHI UPNP URI UUID SNDFILE SOUP"

#-----------------------------------------------------------------------------

HERE=${PWD}

SOURCE=${HERE}/lib-source

LIB_BUILD=${HERE}/lib-build

#-----------------------------------------------------------------------------
# If the output directory does not exist, create it and copy the baseline
# files to it.

if [[ ! -d "${PREFIX}" ]]
then

    mkdir "${PREFIX}"

    if [[ -d ${THERE}/base ]]
    then
        cp -r ${THERE}/base/* ${PREFIX}/
    fi

fi

#-----------------------------------------------------------------------------

if [[ ! -d "${SOURCE}" ]]
then
    mkdir "${SOURCE}"
fi

if [[ ! -d "${LIB_BUILD}" ]]
then
    mkdir "${LIB_BUILD}"
fi

#-----------------------------------------------------------------------------
# Get the list of things that have already been built - this lets you keep
# going where you left off if something fails.

touch ${HERE}/built

BUILT=`cat ${HERE}/built`

#-----------------------------------------------------------------------------
# If there are parameters, we build those regardless of whether they
# have been built or not

CLEAN=0

STATE=1

if [[ $# > 0 ]]
then
    if [[ $# == 1 && $1 == "clean" ]]
    then
        rm ${HERE}/built
        BUILT=""
        CLEAN=1
    else
        ALL="$@"
        BUILT=""
        STATE=0
        if [[ ${ALL} == *clean* ]]
        then
            CLEAN=1
        fi
    fi
fi

#-----------------------------------------------------------------------------

for THIS in ${ALL}; do

    if [[ ${THIS} == "clean" ]]
    then
        continue
    fi

    if [[ $BUILT == "" ]]
    then
      DOIT=1
    else
      set +e
      grep -q "^$THIS$" $HERE/built
      DOIT=$?
      set -e
    fi

    if [[ $DOIT != 0 ]]
    then

        THIS_V=${THIS}_V
        THIS_URL=${THIS}_URL
        THIS_DIST=${THIS}_DIST
        THIS_SOURCE=${THIS}_SOURCE
        THIS_COMMANDS=${THIS}_COMMANDS


        echo "================================================================="
        echo "== Building ${!THIS_SOURCE}...($THIS)"
        echo "================================================================="

        # If the source directory does not exist, unpack the dist


        if [[ ! -d "${LIB_BUILD}/${!THIS_SOURCE}" ]]
        then

            cd ${SOURCE}

            # If the dist does not exist, download it

            if [[ ! -f "${!THIS_DIST}" ]]
            then
                wget "http://developer.trickplay.com/sources/${!THIS_DIST}"
            fi

            cd ${LIB_BUILD}

            if [[ "${!THIS_DIST:0-3}" == "bz2" ]]
            then
                tar jxf "${SOURCE}/${!THIS_DIST}"
            elif [[ "${!THIS_DIST:0-2}" == "xz" ]]
            then
                tar Jxf "${SOURCE}/${!THIS_DIST}"
            else
                tar zxf "${SOURCE}/${!THIS_DIST}"
            fi

	        # Patches

            if [[ -d "${THERE}/patches/${!THIS_SOURCE}" ]]
	        then
			    cd "${LIB_BUILD}/${!THIS_SOURCE}"
			    QUILT_PATCHES="${THERE}/patches/${!THIS_SOURCE}" quilt push -a
	        fi
        fi


        # cd into the source directory for this one

        cd ${LIB_BUILD}/${!THIS_SOURCE}

        # clean

        if [[ ${CLEAN} == 1 ]]
        then
            make ${NUM_MAKE_JOBS} clean > ${OUT}
        fi

        # configure and build
        echo "executing command: ${!THIS_COMMANDS} > ${OUT}" > ${OUT}
        eval ${!THIS_COMMANDS} > ${OUT}

        # Save it to the built file

        if [[ ${STATE} == 1 ]]
        then

            echo "${THIS}" >> ${HERE}/built

        fi

        # cd back here

        cd ${HERE}

    fi

done

#------------------------------------------------------------------------------
# Fetch NaturalDocs

ND_DIST="NaturalDocs-1.52.zip"

if [[ ! -d ${SOURCE}/nd ]]
then

    cd ${SOURCE}
    if [[ ! -f "./${ND_DIST}" ]]
    then
        wget "http://developer.trickplay.com/sources/${ND_DIST}"
    fi
    mkdir nd
    unzip "${ND_DIST}" -d ./nd/
    chmod +x ./nd/NaturalDocs
    cd ${HERE}

fi

#------------------------------------------------------------------------------
# Trickplay

if [[ -f "${THERE}/../CMakeLists.txt" ]]
then

    if [[ ! -d ${HERE}/tp-build ]]
    then

        TP_PROFILING=""
        if [[ $PROFILING != "0" ]]
        then
            TP_PROFILING="-DTP_PROFILING=1"
        fi

        mkdir ${HERE}/tp-build
        cd ${HERE}/tp-build

        cmake   -DCMAKE_TOOLCHAIN_FILE=${THERE}/toolchain.cmake \
                -DCMAKE_BUILD_TYPE=MinSizeRel \
                -DTP_CLUTTER_BACKEND_EGL=1 \
                -DNATURAL_DOCS=${SOURCE}/nd/NaturalDocs \
                $TP_CORE_SHARED \
	            $TP_PROFILING \
                "${THERE}/../"
    fi

    echo "================================================================="
    echo "== Building libtpcore..."
    echo "================================================================="

    make -C ${HERE}/tp-build ${NUM_MAKE_JOBS} --no-print-directory
    make -C ${HERE}/tp-build --no-print-directory oem-docs apps install

fi

#------------------------------------------------------------------------------
# Build a test exe

if [[ -d "${THERE}/test" ]]
then

    echo "================================================================="
    echo "== Link test..."
    echo "================================================================="

    ${CXX} -o ${HERE}/test \
        -g -Wall -fPIC \
        -L ${PREFIX}/lib \
        -I ${PREFIX}/include \
        -Wl,--start-group \
        -ltpcore \
        -ltplua \
        -lclutteralphamode \
	    -ljson-glib-1.0 \
	    -latk-1.0 \
        -lcogl \
        -lcogl-pango \
	    -lclutter-eglnative-1.0 \
	    -lavahi-core \
	    -lavahi-common \
	    -lavahi-glib \
	    -lpango-1.0 \
	    -lpangocairo-1.0 \
	    -lpangoft2-1.0 \
	    -lcairo \
	    -lpixman-1 \
	    -lpng15 \
	    -lpng \
	    -ltiff \
	    -ltiffxx \
	    -lgif \
	    -ljpeg.8 \
	    -lfontconfig \
	    -lfreetype \
	    -lexpat-tp \
	    -lbz2 \
	    -lcurl \
	    -lcares \
	    -lz \
	    -lssl \
	    -lcrypto \
	    -lsqlite3 \
	    -lffi \
	    -lgio-2.0 \
	    -lgmodule-2.0 \
	    -lgobject-2.0 \
	    -lglib-2.0 \
	    -lgthread-2.0 \
	    -ldl \
	    -luuid \
	    -luriparser \
	    -lupnp \
	    -lixml \
	    -lthreadutil \
	    -lGLESv2 \
	    -lEGL \
	    -lcairo-gobject \
	    -lsndfile \
	    -lsoup-2.4 \
	    -lxml2 \
        -lexif-tp \
        -lintl \
        -liconv \
        -landroid \
	    ${THERE}/test/main.cpp \
	    -Wl,--end-group

    rm -rf ${HERE}/test
fi

#------------------------------------------------------------------------------
# Build Android project

if [[ -d "${THERE}/android" ]]
then

    echo "================================================================="
    echo "== Building Android JNI project"
    echo "================================================================="

    rsync -a "${THERE}/android/" "${HERE}/android/"
    cd "${HERE}/android"
    rm -rf bin libs obj

    mkdir -p assets
    if [ ! -e "assets/resources.zip" ]; then
        (cd "${PREFIX}"; zip -9vr "${HERE}/android/assets/resources.zip" "resources")
    else
        echo "Resources.zip is already there -- skipping"
    fi
    cd assets
    md5sum resources.zip > resources.zip.md5sum

    mkdir -p apps
    cp -v "${PREFIX}/apps/"*.zip apps
    cd apps
    for i in *.zip;do
        md5sum "${i}" > "${i}.md5sum"
    done

    cd "${HERE}/android"
    TRICKPLAY_PDK_DIR="${PREFIX}" ndk-build ${NUM_MAKE_JOBS}
    android update project -p . -s
    ant debug
    cp "${HERE}/android/bin/"*.apk "${HERE}"

fi
