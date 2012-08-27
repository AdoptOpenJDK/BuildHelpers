#
# Copyright (c) 2011, 2012, Oracle and/or its affiliates. All rights reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
#
# This code is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 only, as
# published by the Free Software Foundation.  Oracle designates this
# particular file as subject to the "Classpath" exception as provided
# by Oracle in the LICENSE file that accompanied this code.
#
# This code is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# version 2 for more details (a copy is included in the LICENSE file that
# accompanied this code).
#
# You should have received a copy of the GNU General Public License version
# 2 along with this work; if not, write to the Free Software Foundation,
# Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
# or visit www.oracle.com if you need additional information or have any
# questions.
#

AC_DEFUN_ONCE([LIB_SETUP_INIT],
[
        
###############################################################################
#
# OS specific settings that we never will need to probe.
#
if test "x$OPENJDK_TARGET_OS" = xlinux; then
    AC_MSG_CHECKING([what is not needed on Linux?])
    PULSE_NOT_NEEDED=yes
    AC_MSG_RESULT([pulse])
fi

if test "x$OPENJDK_TARGET_OS" = xsolaris; then
    AC_MSG_CHECKING([what is not needed on Solaris?])
    ALSA_NOT_NEEDED=yes
    PULSE_NOT_NEEDED=yes
    AC_MSG_RESULT([alsa pulse])
fi

if test "x$OPENJDK_TARGET_OS" = xwindows; then
    AC_MSG_CHECKING([what is not needed on Windows?])
    CUPS_NOT_NEEDED=yes    
    ALSA_NOT_NEEDED=yes
    PULSE_NOT_NEEDED=yes
    X11_NOT_NEEDED=yes
    AC_MSG_RESULT([alsa cups pulse x11])
fi

if test "x$OPENJDK_TARGET_OS" = xmacosx; then
    AC_MSG_CHECKING([what is not needed on MacOSX?])
    ALSA_NOT_NEEDED=yes
    PULSE_NOT_NEEDED=yes
    X11_NOT_NEEDED=yes
    FREETYPE2_NOT_NEEDED=yes    
    # If the java runtime framework is disabled, then we need X11.
    # This will be adjusted below.
    AC_MSG_RESULT([alsa pulse x11])
fi

if test "x$OPENJDK_TARGET_OS" = xbsd; then
    AC_MSG_CHECKING([what is not needed on bsd?])
    ALSA_NOT_NEEDED=yes
    AC_MSG_RESULT([alsa])    
fi

if test "x$OPENJDK" = "xfalse"; then
    FREETYPE2_NOT_NEEDED=yes
fi

###############################################################################
#
# Check for MacOSX support for OpenJDK. If this exists, try to build a JVM
# that uses this API. 
#
AC_ARG_ENABLE([macosx-runtime-support], [AS_HELP_STRING([--disable-macosx-runtime-support],
	[disable the use of MacOSX Java runtime support framework @<:@enabled@:>@])],
	[MACOSX_RUNTIME_SUPPORT="${enableval}"],[MACOSX_RUNTIME_SUPPORT="no"])

USE_MACOSX_RUNTIME_SUPPORT=no
AC_MSG_CHECKING([for explicit Java runtime support in the OS])
if test -f /System/Library/Frameworks/JavaVM.framework/Frameworks/JavaRuntimeSupport.framework/Headers/JavaRuntimeSupport.h; then
    if test "x$MACOSX_RUNTIME_SUPPORT" != xno; then
        MACOSX_RUNTIME_SUPPORT=yes
        USE_MACOSX_RUNTIME_SUPPORT=yes
        AC_MSG_RESULT([yes, does not need alsa freetype2 pulse and X11])
    else
        AC_MSG_RESULT([yes, but explicitly disabled.])
    fi
else
    AC_MSG_RESULT([no])
fi

if test "x$OPENJDK_TARGET_OS" = xmacosx && test "x$USE_MACOSX_RUNTIME_SUPPORT" = xno; then
    AC_MSG_CHECKING([what is not needed on an X11 build on MacOSX?])
    X11_NOT_NEEDED=
    FREETYPE2_NOT_NEEDED=
    AC_MSG_RESULT([alsa pulse])
fi
])

AC_DEFUN_ONCE([LIB_SETUP_X11],
[

###############################################################################
#
# Check for X Windows
#

# Check if the user has specified sysroot, but not --x-includes or --x-libraries.
# Make a simple check for the libraries at the sysroot, and setup --x-includes and
# --x-libraries for the sysroot, if that seems to be correct.
if test "x$SYS_ROOT" != "x/"; then
  if test "x$x_includes" = xNONE; then
    if test -f "$SYS_ROOT/usr/X11R6/include/X11/Xlib.h"; then
      x_includes="$SYS_ROOT/usr/X11R6/include"
    fi
  fi
  if test "x$x_libraries" = xNONE; then
    if test -f "$SYS_ROOT/usr/X11R6/lib/libX11.so"; then
      x_libraries="$SYS_ROOT/usr/X11R6/lib"
    fi
  fi
fi

# Now let autoconf do it's magic
AC_PATH_X
AC_PATH_XTRA

if test "x$no_x" = xyes && test "x$X11_NOT_NEEDED" != xyes; then 
    HELP_MSG_MISSING_DEPENDENCY([x11])
    AC_MSG_ERROR([Could not find X11 libraries. $HELP_MSG])
fi

# Some of the old makefiles require a setting of OPENWIN_HOME
# Since the X11R6 directory has disappeared on later Linuxes,
# we need to probe for it.
if test "x$OPENJDK_TARGET_OS" = xlinux; then
    if test -d "$SYS_ROOT/usr/X11R6"; then
        OPENWIN_HOME="$SYS_ROOT/usr/X11R6"
    fi
    if test -d "$SYS_ROOT/usr/include/X11"; then
        OPENWIN_HOME="$SYS_ROOT/usr"
    fi
fi
if test "x$OPENJDK_TARGET_OS" = xsolaris; then
    OPENWIN_HOME="/usr/openwin"
fi
AC_SUBST(OPENWIN_HOME)


#
# Weird Sol10 something check...TODO change to try compile
#
if test "x${OPENJDK_TARGET_OS}" = xsolaris; then
  if test "`uname -r`" = "5.10"; then
     if test "`${EGREP} -c XLinearGradient ${OPENWIN_HOME}/share/include/X11/extensions/Xrender.h`" = "0"; then
     	X_CFLAGS="${X_CFLAGS} -DSOLARIS10_NO_XRENDER_STRUCTS"
     fi
  fi
fi

AC_LANG_PUSH(C)
OLD_CFLAGS="$CFLAGS"
CFLAGS="$CFLAGS $X_CFLAGS"
AC_CHECK_HEADERS([X11/extensions/shape.h X11/extensions/Xrender.h X11/extensions/XTest.h],
                [X11_A_OK=yes],
                [X11_A_OK=no])
CFLAGS="$OLD_CFLAGS"
AC_LANG_POP(C)

if test "x$X11_A_OK" = xno && test "x$X11_NOT_NEEDED" != xyes; then 
    HELP_MSG_MISSING_DEPENDENCY([x11])
    AC_MSG_ERROR([Could not find all X11 headers (shape.h Xrender.h XTest.h). $HELP_MSG])
fi

AC_SUBST(X_CFLAGS)
AC_SUBST(X_LIBS)
])

AC_DEFUN_ONCE([LIB_SETUP_CUPS],
[

###############################################################################
#
# The common unix printing system cups is used to print from java.
#
AC_ARG_WITH(cups, [AS_HELP_STRING([--with-cups],
    [specify prefix directory for the cups package
	 (expecting the libraries under PATH/lib and the headers under PATH/include)])])
AC_ARG_WITH(cups-include, [AS_HELP_STRING([--with-cups-include],
	[specify directory for the cups include files])])
AC_ARG_WITH(cups-lib, [AS_HELP_STRING([--with-cups-lib],
	[specify directory for the cups library])])

if test "x$CUPS_NOT_NEEDED" = xyes; then
	if test "x${with_cups}" != x || test "x${with_cups_include}" != x || test "x${with_cups_lib}" != x; then
		AC_MSG_WARN([cups not used, so --with-cups is ignored])
	fi
	CUPS_CFLAGS=
	CUPS_LIBS=
else
	CUPS_FOUND=no

	if test "x${with_cups}" = xno || test "x${with_cups_include}" = xno || test "x${with_cups_lib}" = xno; then
	    AC_MSG_ERROR([It is not possible to disable the use of cups. Remove the --without-cups option.])
	fi

	if test "x${with_cups}" != x; then
	    CUPS_LIBS="-L${with_cups}/lib -lcups"
	    CUPS_CFLAGS="-I${with_cups}/include"
	    CUPS_FOUND=yes
	fi
	if test "x${with_cups_include}" != x; then
	    CUPS_CFLAGS="-I${with_cups_include}"
	    CUPS_FOUND=yes
	fi
	if test "x${with_cups_lib}" != x; then
	    CUPS_LIBS="-L${with_cups_lib} -lcups"
	    CUPS_FOUND=yes
	fi
	if test "x$CUPS_FOUND" = xno; then
	    BDEPS_CHECK_MODULE(CUPS, cups, xxx, [CUPS_FOUND=yes])
	fi
	if test "x$CUPS_FOUND" = xno; then
	    # Are the cups headers installed in the default /usr/include location?
	    AC_CHECK_HEADERS([cups/cups.h cups/ppd.h],
	                     [CUPS_FOUND=yes
	                      CUPS_CFLAGS=
	                      CUPS_LIBS="-lcups"
	                      DEFAULT_CUPS=yes])
	fi
	if test "x$CUPS_FOUND" = xno; then
	    # Getting nervous now? Lets poke around for standard Solaris third-party
	    # package installation locations.
	    AC_MSG_CHECKING([for cups headers and libs])
	    if test -s /opt/sfw/cups/include/cups/cups.h; then
	       # An SFW package seems to be installed!
	       CUPS_FOUND=yes
	       CUPS_CFLAGS="-I/opt/sfw/cups/include"
	       CUPS_LIBS="-L/opt/sfw/cups/lib -lcups"
	    elif test -s /opt/csw/include/cups/cups.h; then
	       # A CSW package seems to be installed!
	       CUPS_FOUND=yes
	       CUPS_CFLAGS="-I/opt/csw/include"
	       CUPS_LIBS="-L/opt/csw/lib -lcups"
	    fi
	    AC_MSG_RESULT([$CUPS_FOUND])
	fi
	if test "x$CUPS_FOUND" = xno; then 
	    HELP_MSG_MISSING_DEPENDENCY([cups])
	    AC_MSG_ERROR([Could not find cups! $HELP_MSG ])
	fi
fi

AC_SUBST(CUPS_CFLAGS)
AC_SUBST(CUPS_LIBS)

])

AC_DEFUN_ONCE([LIB_SETUP_FREETYPE],
[

###############################################################################
#
# The ubiquitous freetype2 library is used to render fonts.
#
AC_ARG_WITH(freetype, [AS_HELP_STRING([--with-freetype],
	[specify prefix directory for the freetype2 package
     (expecting the libraries under PATH/lib and the headers under PATH/include)])])

# If we are using the OS installed system lib for freetype, then we do not need to copy it to the build tree
USING_SYSTEM_FT_LIB=false

if test "x$FREETYPE2_NOT_NEEDED" = xyes; then
	if test "x$with_freetype" != x || test "x$with_freetype_include" != x || test "x$with_freetype_lib" != x; then
		AC_MSG_WARN([freetype not used, so --with-freetype is ignored])
	fi
	FREETYPE2_CFLAGS=
	FREETYPE2_LIBS=
        FREETYPE2_LIB_PATH=
else
	FREETYPE2_FOUND=no

	if test "x$with_freetype" != x; then
            SPACESAFE(with_freetype,[the path to freetype])
	    FREETYPE2_LIBS="-L$with_freetype/lib -lfreetype"
            if test "x$OPENJDK_TARGET_OS" = xwindows; then
                FREETYPE2_LIBS="$with_freetype/lib/freetype.lib"
            fi
            FREETYPE2_LIB_PATH="$with_freetype/lib"
	    FREETYPE2_CFLAGS="-I$with_freetype/include"
            if test -s $with_freetype/include/ft2build.h && test -d $with_freetype/include/freetype2/freetype; then
                FREETYPE2_CFLAGS="-I$with_freetype/include/freetype2 -I$with_freetype/include"
            fi
	    FREETYPE2_FOUND=yes
   	    if test "x$FREETYPE2_FOUND" = xyes; then
	        # Verify that the directories exist 
                if ! test -d "$with_freetype/lib" || ! test -d "$with_freetype/include"; then
		   AC_MSG_ERROR([Could not find the expected directories $with_freetype/lib and $with_freetype/include])
		fi
	        # List the contents of the lib.
		FREETYPELIB=`ls $with_freetype/lib/libfreetype.so $with_freetype/lib/freetype.dll 2> /dev/null`
                if test "x$FREETYPELIB" = x; then
		   AC_MSG_ERROR([Could not find libfreetype.se nor freetype.dll in $with_freetype/lib])
		fi
	        # Check one h-file
                if ! test -s "$with_freetype/include/ft2build.h"; then
		   AC_MSG_ERROR([Could not find $with_freetype/include/ft2build.h])
		fi
            fi
        fi
	if test "x$FREETYPE2_FOUND" = xno; then
	    BDEPS_CHECK_MODULE(FREETYPE2, freetype2, xxx, [FREETYPE2_FOUND=yes], [FREETYPE2_FOUND=no])
            USING_SYSTEM_FT_LIB=true
	fi
	if test "x$FREETYPE2_FOUND" = xno; then
	    PKG_CHECK_MODULES(FREETYPE2, freetype2, [FREETYPE2_FOUND=yes], [FREETYPE2_FOUND=no])
            USING_SYSTEM_FT_LIB=true
	fi
	if test "x$FREETYPE2_FOUND" = xno; then
	    AC_MSG_CHECKING([for freetype in some standard locations])
	
	    if test -s /usr/X11/include/ft2build.h && test -d /usr/X11/include/freetype2/freetype; then
	        DEFAULT_FREETYPE_CFLAGS="-I/usr/X11/include/freetype2 -I/usr/X11/include"
	        DEFAULT_FREETYPE_LIBS="-L/usr/X11/lib -lfreetype"
	    fi
	    if test -s /usr/include/ft2build.h && test -d /usr/include/freetype2/freetype; then
	        DEFAULT_FREETYPE_CFLAGS="-I/usr/include/freetype2"
	        DEFAULT_FREETYPE_LIBS="-lfreetype"
	    fi
	
	    PREV_CXXCFLAGS="$CXXFLAGS"
	    PREV_LDFLAGS="$LDFLAGS"
	    CXXFLAGS="$CXXFLAGS $DEFAULT_FREETYPE_CFLAGS"
	    LDFLAGS="$LDFLAGS $DEFAULT_FREETYPE_LIBS"
	    AC_LINK_IFELSE([AC_LANG_SOURCE([[#include<ft2build.h>
	                    #include FT_FREETYPE_H 
	                   int main() { return 0; }
	                  ]])],
	                  [
	                      # Yes, the default cflags and libs did the trick.
	                      FREETYPE2_FOUND=yes
	                      FREETYPE2_CFLAGS="$DEFAULT_FREETYPE_CFLAGS"
	                      FREETYPE2_LIBS="$DEFAULT_FREETYPE_LIBS"
	                  ],
	                  [
	                      FREETYPE2_FOUND=no
	                  ])
            CXXCFLAGS="$PREV_CXXFLAGS"
	    LDFLAGS="$PREV_LDFLAGS"
	    AC_MSG_RESULT([$FREETYPE2_FOUND])
            USING_SYSTEM_FT_LIB=true
	fi
	if test "x$FREETYPE2_FOUND" = xno; then
		HELP_MSG_MISSING_DEPENDENCY([freetype2])
		AC_MSG_ERROR([Could not find freetype2! $HELP_MSG ])
	fi    
fi

AC_SUBST(USING_SYSTEM_FT_LIB)
AC_SUBST(FREETYPE2_LIB_PATH)
AC_SUBST(FREETYPE2_CFLAGS)
AC_SUBST(FREETYPE2_LIBS)

])

AC_DEFUN_ONCE([LIB_SETUP_ALSA],
[

###############################################################################
#
# Check for alsa headers and libraries. Used on Linux/GNU systems.
#
AC_ARG_WITH(alsa, [AS_HELP_STRING([--with-alsa],
	[specify prefix directory for the alsa package
	 (expecting the libraries under PATH/lib and the headers under PATH/include)])])
AC_ARG_WITH(alsa-include, [AS_HELP_STRING([--with-alsa-include],
	[specify directory for the alsa include files])])
AC_ARG_WITH(alsa-lib, [AS_HELP_STRING([--with-alsa-lib],
	[specify directory for the alsa library])])

if test "x$ALSA_NOT_NEEDED" = xyes; then
	if test "x${with_alsa}" != x || test "x${with_alsa_include}" != x || test "x${with_alsa_lib}" != x; then
		AC_MSG_WARN([alsa not used, so --with-alsa is ignored])
	fi
	ALSA_CFLAGS=
	ALSA_LIBS=
else
	ALSA_FOUND=no

	if test "x${with_alsa}" = xno || test "x${with_alsa_include}" = xno || test "x${with_alsa_lib}" = xno; then
	    AC_MSG_ERROR([It is not possible to disable the use of alsa. Remove the --without-alsa option.])
	fi

	if test "x${with_alsa}" != x; then
	    ALSA_LIBS="-L${with_alsa}/lib -lalsa"
	    ALSA_CFLAGS="-I${with_alsa}/include"
	    ALSA_FOUND=yes
	fi
	if test "x${with_alsa_include}" != x; then
	    ALSA_CFLAGS="-I${with_alsa_include}"
	    ALSA_FOUND=yes
	fi
	if test "x${with_alsa_lib}" != x; then
	    ALSA_LIBS="-L${with_alsa_lib} -lalsa"
	    ALSA_FOUND=yes
	fi
	if test "x$ALSA_FOUND" = xno; then
	    BDEPS_CHECK_MODULE(ALSA, alsa, xxx, [ALSA_FOUND=yes], [ALSA_FOUND=no])
	fi
	if test "x$ALSA_FOUND" = xno; then
	    PKG_CHECK_MODULES(ALSA, alsa, [ALSA_FOUND=yes], [ALSA_FOUND=no])
	fi
	if test "x$ALSA_FOUND" = xno; then
	    AC_CHECK_HEADERS([alsa/asoundlib.h],
	                     [ALSA_FOUND=yes
	                      ALSA_CFLAGS=-Iignoreme
	                      ALSA_LIBS=-lasound
	                      DEFAULT_ALSA=yes],
	                     [ALSA_FOUND=no])
	fi
	if test "x$ALSA_FOUND" = xno; then 
	    HELP_MSG_MISSING_DEPENDENCY([alsa])
	    AC_MSG_ERROR([Could not find alsa! $HELP_MSG ])
	fi    
fi

AC_SUBST(ALSA_CFLAGS)
AC_SUBST(ALSA_LIBS)

])

AC_DEFUN_ONCE([LIB_SETUP_MISC_LIBS],
[

###############################################################################
#
# Check for the jpeg library
#

USE_EXTERNAL_LIBJPEG=true
AC_CHECK_LIB(jpeg, main, [],
             [ USE_EXTERNAL_LIBJPEG=false
               AC_MSG_NOTICE([Will use jpeg decoder bundled with the OpenJDK source])
             ])
AC_SUBST(USE_EXTERNAL_LIBJPEG)
        
###############################################################################
#
# Check for the gif library
#

USE_EXTERNAL_LIBJPEG=true
AC_CHECK_LIB(gif, main, [],
             [ USE_EXTERNAL_LIBGIF=false
               AC_MSG_NOTICE([Will use gif decoder bundled with the OpenJDK source])
             ])
AC_SUBST(USE_EXTERNAL_LIBGIF)

###############################################################################
#
# Check for the zlib library
#

AC_ARG_WITH(zlib, [AS_HELP_STRING([--with-zlib],
	[use zlib from build system or OpenJDK source (system, bundled) @<:@bundled@:>@])])

AC_CHECK_LIB(z, compress,
             [ ZLIB_FOUND=yes ],
             [ ZLIB_FOUND=no ])

AC_MSG_CHECKING([for which zlib to use])

DEFAULT_ZLIB=bundled
if test "x$OPENJDK_TARGET_OS" = xmacosx; then
#
# On macosx default is system...on others default is 
#
    DEFAULT_ZLIB=system
fi

if test "x${ZLIB_FOUND}" != "xyes"; then
#
# If we don't find any system...set default to bundled
#
    DEFAULT_ZLIB=bundled
fi

#
# If user didn't specify, use DEFAULT_ZLIB
#
if test "x${with_zlib}" = "x"; then
    with_zlib=${DEFAULT_ZLIB}
fi

if test "x${with_zlib}" = "xbundled"; then
    USE_EXTERNAL_LIBZ=false
    AC_MSG_RESULT([bundled])
elif test "x${with_zlib}" = "xsystem"; then
    if test "x${ZLIB_FOUND}" = "xyes"; then
        USE_EXTERNAL_LIBZ=true
        AC_MSG_RESULT([system])
    else
        AC_MSG_RESULT([system not found])
        AC_MSG_ERROR([--with-zlib=system specified, but no zlib found!])  
    fi
else
    AC_MSG_ERROR([Invalid value for --with-zlib: ${with_zlib}, use 'system' or 'bundled'])  
fi

AC_SUBST(USE_EXTERNAL_LIBZ)

###############################################################################
LIBZIP_CAN_USE_MMAP=true
if test "x$JDK_VARIANT" = "xembedded"; then
   LIBZIP_CAN_USE_MMAP=false
fi
AC_SUBST(LIBZIP_CAN_USE_MMAP)

###############################################################################
#
# Check if altzone exists in time.h
#

AC_LINK_IFELSE([AC_LANG_PROGRAM([#include <time.h>], [return (int)altzone;])],
            [has_altzone=yes],
            [has_altzone=no])
if test "x$has_altzone" = xyes; then
    AC_DEFINE([HAVE_ALTZONE], 1, [Define if you have the external 'altzone' variable in time.h])
fi

###############################################################################
#
# Check the maths library
#

AC_CHECK_LIB(m, cos, [],
             [ 
                  AC_MSG_NOTICE([Maths library was not found])
             ])
AC_SUBST(LIBM)

###############################################################################
#
# Check for libdl.so

save_LIBS="$LIBS"
LIBS=""
AC_CHECK_LIB(dl,dlopen)
LIBDL="$LIBS"
AC_SUBST(LIBDL)
LIBS="$save_LIBS"

])

AC_DEFUN_ONCE([LIB_SETUP_STATIC_LINK_LIBSTDCPP],
[
###############################################################################
#
# statically link libstdc++ before C++ ABI is stablized on Linux unless 
# dynamic build is configured on command line.
#
AC_ARG_ENABLE([static-link-stdc++], [AS_HELP_STRING([--disable-static-link-stdc++],
	[disable static linking of the C++ runtime on Linux @<:@enabled@:>@])],,
	[
		enable_static_link_stdc__=yes
    ])

if test "x$OPENJDK_TARGET_OS" = xlinux; then
    # Test if -lstdc++ works.
    AC_MSG_CHECKING([if dynamic link of stdc++ is possible])
    AC_LANG_PUSH(C++)
    OLD_CXXFLAGS="$CXXFLAGS"
    CXXFLAGS="$CXXFLAGS -lstdc++"
    AC_LINK_IFELSE([AC_LANG_PROGRAM([], [return 0;])],
            [has_dynamic_libstdcxx=yes],
            [has_dynamic_libstdcxx=no])
    CXXFLAGS="$OLD_CXXFLAGS"
    AC_LANG_POP(C++)
    AC_MSG_RESULT([$has_dynamic_libstdcxx])

    # Test if stdc++ can be linked statically.
    AC_MSG_CHECKING([if static link of stdc++ is possible])
    STATIC_STDCXX_FLAGS="-Wl,-Bstatic -lstdc++ -lgcc -Wl,-Bdynamic"
    AC_LANG_PUSH(C++)
    OLD_LIBS="$LIBS"
    OLD_CXX="$CXX"
    LIBS="$STATIC_STDCXX_FLAGS"
    CXX="$CC"                       
    AC_LINK_IFELSE([AC_LANG_PROGRAM([], [return 0;])],
            [has_static_libstdcxx=yes],
            [has_static_libstdcxx=no])
    LIBS="$OLD_LIBS"
    CXX="$OLD_CXX"
    AC_LANG_POP(C++)
    AC_MSG_RESULT([$has_static_libstdcxx])

    if test "x$has_static_libcxx" = xno && test "x$has_dynamic_libcxx" = xno; then
        AC_MSG_ERROR([I cannot link to stdc++! Neither dynamically nor statically.])
    fi

    if test "x$enable_static_link_stdc__" = xyes && test "x$has_static_libstdcxx" = xno; then
        AC_MSG_NOTICE([Static linking of libstdc++ was not possible reverting to dynamic linking.])
        enable_static_link_stdc__=no
    fi

    if test "x$enable_static_link_stdc__" = xno && test "x$has_dynamic_libstdcxx" = xno; then
        AC_MSG_NOTICE([Dynamic linking of libstdc++ was not possible reverting to static linking.])
        enable_static_link_stdc__=yes
    fi

    AC_MSG_CHECKING([how to link with libstdc++])
    if test "x$enable_static_link_stdc__" = xyes; then
        LIBCXX="$LIBCXX $STATIC_STDCXX_FLAGS"
        LDCXX="$CC"
        AC_MSG_RESULT([static])
    else
        LIBCXX="$LIBCXX -lstdc++"
        LDCXX="$CXX"
        AC_MSG_RESULT([dynamic])
    fi
fi

# libCrun is the c++ runtime-library with SunStudio (roughly the equivalent of gcc's libstdc++.so)
if test "x$OPENJDK_TARGET_OS" = xsolaris && test "x$LIBCXX" = x; then
    LIBCXX="/usr/lib${LEGACY_OPENJDK_TARGET_CPU3}/libCrun.so.1"
fi

# TODO better (platform agnostic) test
if test "x$OPENJDK_TARGET_OS" = xmacosx && test "x$LIBCXX" = x && test "x$GCC" = xyes; then
    LIBCXX="-lstdc++"
fi

AC_SUBST(LIBCXX)

])
