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

AC_DEFUN_ONCE([TOOLCHAIN_SETUP_VISUAL_STUDIO_ENV],
[

# Check if the VS env variables were setup prior to running configure.
# If not, then find vcvarsall.bat and run it automatically, and integrate
# the set env variables into the spec file.
SETUPDEVENV="# No special vars"
if test "x$OPENJDK_BUILD_OS" = "xwindows"; then
    # If vcvarsall.bat has been run, then VCINSTALLDIR is set.
    if test "x$VCINSTALLDIR" != x; then
        # No further setup is needed. The build will happen from this kind
        # of shell.
        SETUPDEVENV="# This spec file expects that you are running bash from within a VS command prompt."
        # Make sure to remind you, if you forget to run make from a cygwin bash shell
        # that is spawned "bash -l" from a VS command prompt.
        CHECK_FOR_VCINSTALLDIR=yes
        AC_MSG_CHECKING([if you are running from within a VS command prompt])
        AC_MSG_RESULT([yes])
    else
        # Ah, we have not yet run vcvarsall.bat/vsvars32.bat/vsvars64.bat. Lets do that. First find it.
        if test "x$VS100COMNTOOLS" != x; then
            VARSBAT=`find "$VS100COMNTOOLS/../.." -name vcvarsall.bat`
	    SEARCH_ROOT="$VS100COMNTOOLS"
        else
            VARSBAT=`find "$PROGRAMFILES" -name vcvarsall.bat`
	    SEARCH_ROOT="$PROGRAMFILES"
        fi
        VCPATH=`dirname "$VARSBAT"`
        VCPATH=`cygpath -w "$VCPATH"`
	if test "x$VARSBAT" = x || test ! -d "$VCPATH"; then
            AC_MSG_CHECKING([if we can find the VS installation])
            AC_MSG_RESULT([no])
            AC_MSG_ERROR([Tried to find a VS installation using both $SEARCH_ROOT but failed. Please run "c:\\cygwin\\bin\\bash.exe -l" from a VS command prompt and then run configure/make from there.])
        fi
        case "$LEGACY_OPENJDK_TARGET_CPU1" in
          i?86)
            VARSBAT_ARCH=x86
            ;;
          *)
            VARSBAT_ARCH=$LEGACY_OPENJDK_TARGET_CPU1
            ;;
        esac
        # Lets extract the variables that are set by vcvarsall.bat/vsvars32.bat/vsvars64.bat
        cd $OUTPUT_ROOT
        bash $SRC_ROOT/common/bin/extractvcvars.sh "$VARSBAT" "$VARSBAT_ARCH"
	cd $CURDIR
	if test ! -s $OUTPUT_ROOT/localdevenv.sh || test ! -s $OUTPUT_ROOT/localdevenv.gmk; then
            AC_MSG_CHECKING([if we can extract the needed env variables])
            AC_MSG_RESULT([no])
            AC_MSG_ERROR([Could not succesfully extract the env variables needed for the VS setup. Please run "c:\\cygwin\\bin\\bash.exe -l" from a VS command prompt and then run configure/make from there.])
        fi 
        # Now set all paths and other env variables. This will allow the rest of 
        # the configure script to find and run the compiler in the proper way.
        . $OUTPUT_ROOT/localdevenv.sh
        AC_MSG_CHECKING([if we can find the VS installation])
	if test "x$VCINSTALLDIR" != x; then 
            AC_MSG_RESULT([$VCINSTALLDIR])
        else 
            AC_MSG_RESULT([no])
            AC_MSG_ERROR([Could not find VS installation. Please install. If you are sure you have installed VS, then please run "c:\\cygwin\\bin\\bash.exe -l" from a VS command prompt and then run configure/make from there.])
        fi
        CHECK_FOR_VCINSTALLDIR=no
	SETUPDEVENV="include $OUTPUT_ROOT/localdevenv.gmk"

	AC_MSG_CHECKING([for msvcr100.dll])
        AC_ARG_WITH(msvcr100dll, [AS_HELP_STRING([--with-msvcr100dll],
            [copy this msvcr100.dll into the built JDK])])
        if test "x$with_msvcr100dll" != x; then
            MSVCR100DLL="$with_msvcr100dll"
        else
            if test "x$OPENJDK_TARGET_CPU_BITS" = x64; then
                MSVCR100DLL=`find "$VCINSTALLDIR/.." -name msvcr100.dll | grep x64 | head --lines 1`
            else
                MSVCR100DLL=`find "$VCINSTALLDIR/.." -name msvcr100.dll | grep x86 | grep -v ia64 | grep -v x64 | head --lines 1`
                if test "x$MSVCR100DLL" = x; then
                    MSVCR100DLL=`find "$VCINSTALLDIR/.." -name msvcr100.dll | head --lines 1`
                fi
            fi
        fi
	if test "x$MSVCR100DLL" = x; then
           AC_MSG_RESULT([no])
	   AC_MSG_ERROR([Could not find msvcr100.dll !])
        fi
        AC_MSG_RESULT([$MSVCR100DLL])
	SPACESAFE(MSVCR100DLL,[the path to msvcr100.dll])
    fi
fi
AC_SUBST(SETUPDEVENV)
AC_SUBST(CHECK_FOR_VCINSTALLDIR)
AC_SUBST(MSVCR100DLL)
])

AC_DEFUN_ONCE([TOOLCHAIN_SETUP_SYSROOT_AND_OUT_OPTIONS],
[
###############################################################################
#
# Configure the development tool paths and potential sysroot.
#
AC_LANG(C++)
DEVKIT=
SYS_ROOT=/
AC_SUBST(SYS_ROOT)

# The option used to specify the target .o,.a or .so file.
# When compiling, how to specify the to be created object file.
CC_OUT_OPTION='-o$(SPACE)'
# When linking, how to specify the to be created executable.
EXE_OUT_OPTION='-o$(SPACE)'
# When linking, how to specify the to be created dynamically linkable library.
LD_OUT_OPTION='-o$(SPACE)'
# When archiving, how to specify the to be create static archive for object files.
AR_OUT_OPTION='rcs$(SPACE)'
AC_SUBST(CC_OUT_OPTION)
AC_SUBST(EXE_OUT_OPTION)
AC_SUBST(LD_OUT_OPTION)
AC_SUBST(AR_OUT_OPTION)
])

AC_DEFUN_ONCE([TOOLCHAIN_SETUP_PATHS],
[
# If --build AND --host is set, then the configure script will find any
# cross compilation tools in the PATH. Cross compilation tools
# follows the cross compilation standard where they are prefixed with ${host}.
# For example the binary i686-sun-solaris2.10-gcc
# will cross compile for i686-sun-solaris2.10
# If neither of build and host is not set, then build=host and the
# default compiler found in the path will be used.
# Setting only --host, does not seem to be really supported.
# Please set both --build and --host if you want to cross compile.

DEFINE_CROSS_COMPILE_ARCH=""
HOSTCC=""
HOSTCXX=""
HOSTLD=""
AC_SUBST(DEFINE_CROSS_COMPILE_ARCH)
AC_MSG_CHECKING([if this is a cross compile])
if test "x$OPENJDK_BUILD_SYSTEM" != "x$OPENJDK_TARGET_SYSTEM"; then
    AC_MSG_RESULT([yes, from $OPENJDK_BUILD_SYSTEM to $OPENJDK_TARGET_SYSTEM])
    # We have detected a cross compile!
    DEFINE_CROSS_COMPILE_ARCH="CROSS_COMPILE_ARCH:=$LEGACY_OPENJDK_TARGET_CPU1"
    # Now we to find a C/C++ compiler that can build executables for the build
    # platform. We can't use the AC_PROG_CC macro, since it can only be used
    # once.
    AC_PATH_PROGS(HOSTCC, [cl cc gcc])
    WHICHCMD(HOSTCC)
    AC_PATH_PROGS(HOSTCXX, [cl CC g++])
    WHICHCMD(HOSTCXX)
    AC_PATH_PROG(HOSTLD, ld)
    WHICHCMD(HOSTLD)
    # Building for the build platform should be easy. Therefore
    # we do not need any linkers or assemblers etc.    
else
    AC_MSG_RESULT([no])
fi

# You can force the sys-root if the sys-root encoded into the cross compiler tools
# is not correct.
AC_ARG_WITH(sys-root, [AS_HELP_STRING([--with-sys-root],
    [pass this sys-root to the compilers and linker (useful if the sys-root encoded in
     the cross compiler tools is incorrect)])])

if test "x$with_sys_root" != x; then
    SYS_ROOT=$with_sys_root
fi
                     
# If a devkit is found on the builddeps server, then prepend its path to the
# PATH variable. If there are cross compilers available in the devkit, these
# will be found by AC_PROG_CC et al.
BDEPS_CHECK_MODULE(DEVKIT, devkit, xxx,
                    [# Found devkit
                     PATH="$DEVKIT/bin:$PATH"
                     SYS_ROOT="$DEVKIT/${rewritten_target}/sys-root"
                     if test "x$x_includes" = "xNONE"; then
                         x_includes="$SYS_ROOT/usr/include/X11"
                     fi
                     if test "x$x_libraries" = "xNONE"; then
                         x_libraries="$SYS_ROOT/usr/lib"
                     fi
                    ],
                    [])

if test "x$SYS_ROOT" != "x/" ; then                    
    CFLAGS="--sysroot=$SYS_ROOT $CFLAGS"
    CXXFLAGS="--sysroot=$SYS_ROOT $CXXFLAGS"
    OBJCFLAGS="--sysroot=$SYS_ROOT $OBJCFLAGS" 
    OBJCXXFLAGS="--sysroot=$SYS_ROOT $OBJCFLAGS" 
    CPPFLAGS="--sysroot=$SYS_ROOT $CPPFLAGS"
    LDFLAGS="--sysroot=$SYS_ROOT $LDFLAGS"
fi

# Store the CFLAGS etal passed to the configure script.
ORG_CFLAGS="$CFLAGS"
ORG_CXXFLAGS="$CXXFLAGS"
ORG_OBJCFLAGS="$OBJCFLAGS"

AC_ARG_WITH([tools-dir], [AS_HELP_STRING([--with-tools-dir],
	[search this directory for compilers and tools])], [TOOLS_DIR=$with_tools_dir])

AC_ARG_WITH([devkit], [AS_HELP_STRING([--with-devkit],
	[use this directory as base for tools-dir and sys-root])], [
    if test "x$with_sys_root" != x; then
      AC_MSG_ERROR([Cannot specify both --with-devkit and --with-sys-root at the same time])
    fi
    if test "x$with_tools_dir" != x; then
      AC_MSG_ERROR([Cannot specify both --with-devkit and --with-tools-dir at the same time])
    fi
    TOOLS_DIR=$with_devkit/bin
    SYS_ROOT=$with_devkit/$host_alias/libc
    ])

# autoconf magic only relies on PATH, so update it if tools dir is specified
OLD_PATH="$PATH"
if test "x$TOOLS_DIR" != x; then
  PATH=$TOOLS_DIR:$PATH
fi

# gcc is almost always present, but on Windows we
# prefer cl.exe and on Solaris we prefer CC.
# Thus test for them in this order.
AC_PROG_CC([cl cc gcc])
if test "x$CC" = x; then
    HELP_MSG_MISSING_DEPENDENCY([devkit])
    AC_MSG_ERROR([Could not find a compiler. $HELP_MSG])
fi
if test "x$CC" = xcc && test "x$OPENJDK_BUILD_OS" = xmacosx; then
    # Do not use cc on MacOSX use gcc instead.
    CC="gcc"
fi
WHICHCMD(CC)

AC_PROG_CXX([cl CC g++])
if test "x$CXX" = xCC && test "x$OPENJDK_BUILD_OS" = xmacosx; then
    # The found CC, even though it seems to be a g++ derivate, cannot compile
    # c++ code. Override.
    CXX="g++"
fi
WHICHCMD(CXX)

if test "x$CXX" = x || test "x$CC" = x; then
    HELP_MSG_MISSING_DEPENDENCY([devkit])
    AC_MSG_ERROR([Could not find the needed compilers! $HELP_MSG ])
fi

if test "x$OPENJDK_BUILD_OS" != xwindows; then
    AC_PROG_OBJC
    WHICHCMD(OBJC)
else
    OBJC=
fi

# Restore the flags to the user specified values.
# This is necessary since AC_PROG_CC defaults CFLAGS to "-g -O2"
CFLAGS="$ORG_CFLAGS"
CXXFLAGS="$ORG_CXXFLAGS"
OBJCFLAGS="$ORG_OBJCFLAGS"

# If we are not cross compiling, use the same compilers for
# building the build platform executables.
if test "x$DEFINE_CROSS_COMPILE_ARCH" = x; then
    HOSTCC="$CC"
    HOSTCXX="$CXX"
fi

AC_CHECK_TOOL(LD, ld)
WHICHCMD(LD)
LD="$CC"
LDEXE="$CC"
LDCXX="$CXX"
LDEXECXX="$CXX"
# LDEXE is the linker to use, when creating executables.
AC_SUBST(LDEXE)
# Linking C++ libraries.
AC_SUBST(LDCXX)
# Linking C++ executables.
AC_SUBST(LDEXECXX)

AC_CHECK_TOOL(AR, ar)
WHICHCMD(AR)
if test "x$OPENJDK_BUILD_OS" = xmacosx; then
    ARFLAGS="-r"
else
    ARFLAGS=""
fi
AC_SUBST(ARFLAGS)

COMPILER_NAME=gcc
COMPILER_TYPE=CC
AS_IF([test "x$OPENJDK_BUILD_OS" = xwindows], [
    # For now, assume that we are always compiling using cl.exe. 
    CC_OUT_OPTION=-Fo
    EXE_OUT_OPTION=-out:
    LD_OUT_OPTION=-out:
    AR_OUT_OPTION=-out:
    # On Windows, reject /usr/bin/link, which is a cygwin
    # program for something completely different.
    AC_CHECK_PROG([WINLD], [link],[link],,, [/usr/bin/link])
    # Since we must ignore the first found link, WINLD will contain
    # the full path to the link.exe program.
    WHICHCMD_SPACESAFE([WINLD])
    LD="$WINLD"
    LDEXE="$WINLD"
    LDCXX="$WINLD"
    LDEXECXX="$WINLD"
    # Set HOSTLD to same as LD until we fully support cross compilation
    # on windows.
    HOSTLD="$WINLD"

    AC_CHECK_PROG([MT], [mt], [mt],,, [/usr/bin/mt])
    WHICHCMD_SPACESAFE([MT])
    # The resource compiler
    AC_CHECK_PROG([RC], [rc], [rc],,, [/usr/bin/rc])
    WHICHCMD_SPACESAFE([RC])

    RC_FLAGS="-nologo /l 0x409 /r"
    AS_IF([test "x$VARIANT" = xOPT], [
        RC_FLAGS="$RC_FLAGS -d NDEBUG"
    ])
    JDK_UPDATE_VERSION_NOTNULL=$JDK_UPDATE_VERSION
    AS_IF([test "x$JDK_UPDATE_VERSION" = x], [
        JDK_UPDATE_VERSION_NOTNULL=0
    ])
    RC_FLAGS="$RC_FLAGS -d \"JDK_BUILD_ID=$FULL_VERSION\""
    RC_FLAGS="$RC_FLAGS -d \"JDK_COMPANY=$COMPANY_NAME\""
    RC_FLAGS="$RC_FLAGS -d \"JDK_COMPONENT=$PRODUCT_NAME $JDK_RC_PLATFORM_NAME binary\""
    RC_FLAGS="$RC_FLAGS -d \"JDK_VER=$JDK_MINOR_VERSION.$JDK_MICRO_VERSION.$JDK_UPDATE_VERSION_NOTNULL.$COOKED_BUILD_NUMBER\""
    RC_FLAGS="$RC_FLAGS -d \"JDK_COPYRIGHT=Copyright \xA9 $COPYRIGHT_YEAR\""
    RC_FLAGS="$RC_FLAGS -d \"JDK_NAME=$PRODUCT_NAME $JDK_RC_PLATFORM_NAME $JDK_MINOR_VERSION $JDK_UPDATE_META_TAG\""
    RC_FLAGS="$RC_FLAGS -d \"JDK_FVER=$JDK_MINOR_VERSION,$JDK_MICRO_VERSION,$JDK_UPDATE_VERSION_NOTNULL,$COOKED_BUILD_NUMBER\""

    # lib.exe is used to create static libraries.
    AC_CHECK_PROG([WINAR], [lib],[lib],,,)
    WHICHCMD_SPACESAFE([WINAR])
    AR="$WINAR"
    ARFLAGS="-nologo -NODEFAULTLIB:MSVCRT"

    AC_CHECK_PROG([DUMPBIN], [dumpbin], [dumpbin],,,)
    WHICHCMD_SPACESAFE([DUMPBIN])

    COMPILER_TYPE=CL
    CCXXFLAGS="$CCXXFLAGS -nologo"
])
AC_SUBST(RC_FLAGS)
AC_SUBST(COMPILER_TYPE)

AC_PROG_CPP
WHICHCMD(CPP)

AC_PROG_CXXCPP
WHICHCMD(CXXCPP)

# for solaris we really need solaris tools, and not gnu equivalent
#   these seems to normally reside in /usr/ccs/bin so add that to path before
#   starting to probe
#
#   NOTE: I add this /usr/ccs/bin after TOOLS but before OLD_PATH
#         so that it can be overriden --with-tools-dir
if test "x$OPENJDK_BUILD_OS" = xsolaris; then
    PATH="${TOOLS_DIR}:/usr/ccs/bin:${OLD_PATH}"
fi

# Find the right assembler.
if test "x$OPENJDK_BUILD_OS" = xsolaris; then
    AC_PATH_PROG(AS, as)
    WHICHCMD(AS)
    ASFLAGS=" "
else
    AS="$CC -c"
    ASFLAGS=" "
fi
AC_SUBST(AS)
AC_SUBST(ASFLAGS)

if test "x$OPENJDK_BUILD_OS" = xsolaris; then
    AC_PATH_PROG(NM, nm)
    WHICHCMD(NM)
    AC_PATH_PROG(STRIP, strip)
    WHICHCMD(STRIP)
    AC_PATH_PROG(MCS, mcs)
    WHICHCMD(MCS)
else
    AC_CHECK_TOOL(NM, nm)
    WHICHCMD(NM)
    AC_CHECK_TOOL(STRIP, strip)
    WHICHCMD(STRIP)
fi

###
#
# Check for objcopy
#
#   but search for gobjcopy first...
#   since I on solaris found a broken objcopy...buhh
#
AC_PATH_TOOL(OBJCOPY, gobjcopy)
if test "x$OBJCOPY" = x; then
   AC_PATH_TOOL(OBJCOPY, objcopy)
fi

# Restore old path without tools dir
PATH="$OLD_PATH"
])


AC_DEFUN_ONCE([TOOLCHAIN_SETUP_COMPILER_FLAGS_FOR_LIBS],
[

###############################################################################
#
# How to compile shared libraries. 
#

if test "x$GCC" = xyes; then
    COMPILER_NAME=gcc
    PICFLAG="-fPIC"
    LIBRARY_PREFIX=lib
    SHARED_LIBRARY='lib[$]1.so'
    STATIC_LIBRARY='lib[$]1.a'
    SHARED_LIBRARY_FLAGS="-shared"
    SHARED_LIBRARY_SUFFIX='.so'
    STATIC_LIBRARY_SUFFIX='.a'
    OBJ_SUFFIX='.o'
    EXE_SUFFIX=''
    SET_SHARED_LIBRARY_NAME='-Xlinker -soname=[$]1'
    SET_SHARED_LIBRARY_MAPFILE='-Xlinker -version-script=[$]1'
    C_FLAG_REORDER=''
    CXX_FLAG_REORDER=''
    SET_SHARED_LIBRARY_ORIGIN='-Xlinker -z -Xlinker origin -Xlinker -rpath -Xlinker \$$$$ORIGIN/[$]1'
    LD="$CC"
    LDEXE="$CC"
    LDCXX="$CXX"
    LDEXECXX="$CXX"
    POST_STRIP_CMD="$STRIP -g"
    if test "x$JDK_VARIANT" = xembedded; then
        POST_STRIP_CMD="$STRIP --strip-unneeded"
    fi

    # Linking is different on MacOSX
    if test "x$OPENJDK_BUILD_OS" = xmacosx; then
        # Might change in the future to clang.
        COMPILER_NAME=gcc
        SHARED_LIBRARY='lib[$]1.dylib'
        SHARED_LIBRARY_FLAGS="-dynamiclib -compatibility_version 1.0.0 -current_version 1.0.0 $PICFLAG"
        SHARED_LIBRARY_SUFFIX='.dylib'
        EXE_SUFFIX=''
        SET_SHARED_LIBRARY_NAME='-Xlinker -install_name -Xlinker @rpath/[$]1' 
        SET_SHARED_LIBRARY_MAPFILE=''
        SET_SHARED_LIBRARY_ORIGIN='-Xlinker -rpath -Xlinker @loader_path/.'
        POST_STRIP_CMD="$STRIP -S"
    fi
else
    if test "x$OPENJDK_BUILD_OS" = xsolaris; then
        # If it is not gcc, then assume it is the Oracle Solaris Studio Compiler
        COMPILER_NAME=ossc
        PICFLAG="-KPIC"
        LIBRARY_PREFIX=lib
        SHARED_LIBRARY='lib[$]1.so'
        STATIC_LIBRARY='lib[$]1.a'
        SHARED_LIBRARY_FLAGS="-z defs -xildoff -ztext -G"
        SHARED_LIBRARY_SUFFIX='.so'
        STATIC_LIBRARY_SUFFIX='.a'
        OBJ_SUFFIX='.o'
        EXE_SUFFIX=''
        SET_SHARED_LIBRARY_NAME=''
        SET_SHARED_LIBRARY_MAPFILE='-M[$]1'
	C_FLAG_REORDER='-xF'
	CXX_FLAG_REORDER='-xF'
        SET_SHARED_LIBRARY_ORIGIN='-R \$$$$ORIGIN/[$]1'
        CFLAGS_JDK="${CFLAGS_JDK} -D__solaris__"
        CXXFLAGS_JDK="${CXXFLAGS_JDK} -D__solaris__"
        CFLAGS_JDKLIB_EXTRA='-xstrconst'
        POST_STRIP_CMD="$STRIP -x"
        POST_MCS_CMD="$MCS -d -a \"JDK $FULL_VERSION\""
    fi
    if test "x$OPENJDK_BUILD_OS" = xwindows; then
        # If it is not gcc, then assume it is the MS Visual Studio compiler
        COMPILER_NAME=cl
        PICFLAG=""
        LIBRARY_PREFIX=
        SHARED_LIBRARY='[$]1.dll'
        STATIC_LIBRARY='[$]1.lib'
        SHARED_LIBRARY_FLAGS="-LD"
        SHARED_LIBRARY_SUFFIX='.dll'
        STATIC_LIBRARY_SUFFIX='.lib'
        OBJ_SUFFIX='.obj'
        EXE_SUFFIX='.exe'
        SET_SHARED_LIBRARY_NAME=''
        SET_SHARED_LIBRARY_MAPFILE=''
        SET_SHARED_LIBRARY_ORIGIN=''
    fi
fi

AC_SUBST(OBJ_SUFFIX)
AC_SUBST(SHARED_LIBRARY)
AC_SUBST(STATIC_LIBRARY)
AC_SUBST(LIBRARY_PREFIX)
AC_SUBST(SHARED_LIBRARY_SUFFIX)
AC_SUBST(STATIC_LIBRARY_SUFFIX)
AC_SUBST(EXE_SUFFIX)
AC_SUBST(SHARED_LIBRARY_FLAGS)
AC_SUBST(SET_SHARED_LIBRARY_NAME)
AC_SUBST(SET_SHARED_LIBRARY_MAPFILE)
AC_SUBST(C_FLAG_REORDER)
AC_SUBST(CXX_FLAG_REORDER)
AC_SUBST(SET_SHARED_LIBRARY_ORIGIN)
AC_SUBST(POST_STRIP_CMD)
AC_SUBST(POST_MCS_CMD)

# The (cross) compiler is now configured, we can now test capabilities
# of the target platform.
])

AC_DEFUN_ONCE([TOOLCHAIN_SETUP_COMPILER_FLAGS_FOR_OPTIMIZATION],
[

###############################################################################
#
# Setup the opt flags for different compilers
# and different operating systems.
#
C_FLAG_DEPS="-MMD -MF"
CXX_FLAG_DEPS="-MMD -MF"

case $COMPILER_TYPE in
  CC )
    D_FLAG="-g"
    case $COMPILER_NAME in
      gcc )
      	case $OPENJDK_TARGET_OS in
	  macosx )
	    # On MacOSX we optimize for size, something
	    # we should do for all platforms?
	    C_O_FLAG_HI="-Os"
	    C_O_FLAG_NORM="-Os"
	    C_O_FLAG_NONE=""
	    ;;
	  *)
	    C_O_FLAG_HI="-O3"
	    C_O_FLAG_NORM="-O2"
	    C_O_FLAG_NONE="-O0"
	    CFLAGS_DEBUG_SYMBOLS="-g"
	    CXXFLAGS_DEBUG_SYMBOLS="-g"
	    if test "x$OPENJDK_TARGET_CPU_BITS" = "x64" && test "x$DEBUG_LEVEL" = "xfastdebug"; then
	       CFLAGS_DEBUG_SYMBOLS="-g1"
	       CXXFLAGS_DEBUG_SYMBOLSG="-g1"
	    fi
	    ;;
	esac
        CXX_O_FLAG_HI="$C_O_FLAG_HI"
        CXX_O_FLAG_NORM="$C_O_FLAG_NORM"
        CXX_O_FLAG_NONE="$C_O_FLAG_NONE"
        ;;
      ossc )
        #
        # Forte has different names for this with their C++ compiler...
        #
	C_FLAG_DEPS="-xMMD -xMF"
	CXX_FLAG_DEPS="-xMMD -xMF"

# Extra options used with HIGHEST
#
# WARNING: Use of OPTIMIZATION_LEVEL=HIGHEST in your Makefile needs to be
#          done with care, there are some assumptions below that need to
#          be understood about the use of pointers, and IEEE behavior.
#
# Use non-standard floating point mode (not IEEE 754)
CC_HIGHEST="$CC_HIGHEST -fns"
# Do some simplification of floating point arithmetic (not IEEE 754)
CC_HIGHEST="$CC_HIGHEST -fsimple"
# Use single precision floating point with 'float'
CC_HIGHEST="$CC_HIGHEST -fsingle"
# Assume memory references via basic pointer types do not alias
#   (Source with excessing pointer casting and data access with mixed 
#    pointer types are not recommended)
CC_HIGHEST="$CC_HIGHEST -xalias_level=basic"
# Use intrinsic or inline versions for math/std functions
#   (If you expect perfect errno behavior, do not use this)
CC_HIGHEST="$CC_HIGHEST -xbuiltin=%all"
# Loop data dependency optimizations (need -xO3 or higher)
CC_HIGHEST="$CC_HIGHEST -xdepend"
# Pointer parameters to functions do not overlap
#   (Similar to -xalias_level=basic usage, but less obvious sometimes.
#    If you pass in multiple pointers to the same data, do not use this)
CC_HIGHEST="$CC_HIGHEST -xrestrict"
# Inline some library routines
#   (If you expect perfect errno behavior, do not use this)
CC_HIGHEST="$CC_HIGHEST -xlibmil"
# Use optimized math routines
#   (If you expect perfect errno behavior, do not use this)
#  Can cause undefined external on Solaris 8 X86 on __sincos, removing for now
#CC_HIGHEST="$CC_HIGHEST -xlibmopt"

        case $LEGACY_OPENJDK_TARGET_CPU1 in
          i586)
            C_O_FLAG_HIGHEST="-xO4 -Wu,-O4~yz $CC_HIGHEST -xchip=pentium"
            C_O_FLAG_HI="-xO4 -Wu,-O4~yz"
            C_O_FLAG_NORM="-xO2 -Wu,-O2~yz"
            C_O_FLAG_NONE=""
            CXX_O_FLAG_HIGHEST="-xO4 -Qoption ube -O4~yz $CC_HIGHEST -xchip=pentium"
            CXX_O_FLAG_HI="-xO4 -Qoption ube -O4~yz"
            CXX_O_FLAG_NORM="-xO2 -Qoption ube -O2~yz"
            CXX_O_FLAG_NONE=""
            ;;
          sparc)
            CFLAGS_JDK="${CFLAGS_JDK} -xmemalign=4s"
            CXXFLAGS_JDK="${CXXFLAGS_JDK} -xmemalign=4s"
            CFLAGS_JDKLIB_EXTRA="${CFLAGS_JDKLIB_EXTRA} -xregs=no%appl"
            CXXFLAGS_JDKLIB_EXTRA="${CXXFLAGS_JDKLIB_EXTRA} -xregs=no%appl"
            C_O_FLAG_HIGHEST="-xO4 -Wc,-Qrm-s -Wc,-Qiselect-T0 $CC_HIGHEST -xprefetch=auto,explicit -xchip=ultra"
            C_O_FLAG_HI="-xO4 -Wc,-Qrm-s -Wc,-Qiselect-T0"
            C_O_FLAG_NORM="-xO2 -Wc,-Qrm-s -Wc,-Qiselect-T0"
            C_O_FLAG_NONE=""
            CXX_O_FLAG_HIGHEST="-xO4 -Qoption cg -Qrm-s -Qoption cg -Qiselect-T0 $CC_HIGHEST -xprefetch=auto,explicit -xchip=ultra"
            CXX_O_FLAG_HI="-xO4 -Qoption cg -Qrm-s -Qoption cg -Qiselect-T0"
            CXX_O_FLAG_NORM="-xO2 -Qoption cg -Qrm-s -Qoption cg -Qiselect-T0"
            CXX_O_FLAG_NONE=""
            ;;
        esac

    CFLAGS_DEBUG_SYMBOLS="-g -xs"
    CXXFLAGS_DEBUG_SYMBOLS="-g0 -xs"
    esac
    ;;
  CL )
    D_FLAG=
    C_O_FLAG_HI="-O2"
    C_O_FLAG_NORM="-O1"
    C_O_FLAG_NONE="-Od"
    CXX_O_FLAG_HI="$C_O_FLAG_HI"
    CXX_O_FLAG_NORM="$C_O_FLAG_NORM"
    CXX_O_FLAG_NONE="$C_O_FLAG_NONE"
    ;;
esac

if test -z "$C_O_FLAG_HIGHEST"; then
   C_O_FLAG_HIGHEST="$C_O_FLAG_HI"
fi

if test -z "$CXX_O_FLAG_HIGHEST"; then
   CXX_O_FLAG_HIGHEST="$CXX_O_FLAG_HI"
fi

AC_SUBST(C_O_FLAG_HIGHEST)
AC_SUBST(C_O_FLAG_HI)
AC_SUBST(C_O_FLAG_NORM)
AC_SUBST(C_O_FLAG_NONE)
AC_SUBST(CXX_O_FLAG_HIGHEST)
AC_SUBST(CXX_O_FLAG_HI)
AC_SUBST(CXX_O_FLAG_NORM)
AC_SUBST(CXX_O_FLAG_NONE)
AC_SUBST(C_FLAG_DEPS)
AC_SUBST(CXX_FLAG_DEPS)
])

AC_DEFUN_ONCE([TOOLCHAIN_SETUP_COMPILER_FLAGS_FOR_JDK],
[

if test "x$CFLAGS" != "x${ADDED_CFLAGS}"; then
   AC_MSG_WARN([Ignoring CFLAGS($CFLAGS) found in environment. Use --with-extra-cflags"])
fi

if test "x$CXXFLAGS" != "x${ADDED_CXXFLAGS}"; then
   AC_MSG_WARN([Ignoring CXXFLAGS($CXXFLAGS) found in environment. Use --with-extra-cxxflags"])
fi

if test "x$LDFLAGS" != "x${ADDED_LDFLAGS}"; then
   AC_MSG_WARN([Ignoring LDFLAGS($LDFLAGS) found in environment. Use --with-extra-ldflags"])
fi

AC_ARG_WITH(extra-cflags, [AS_HELP_STRING([--with-extra-cflags],
    [extra flags to be used when compiling jdk c-files])])

AC_ARG_WITH(extra-cxxflags, [AS_HELP_STRING([--with-extra-cxxflags],
    [extra flags to be used when compiling jdk c++-files])])

AC_ARG_WITH(extra-ldflags, [AS_HELP_STRING([--with-extra-ldflags],
    [extra flags to be used when linking jdk])])

CFLAGS_JDK="${CFLAGS_JDK} $with_extra_cflags"
CXXFLAGS_JDK="${CXXFLAGS_JDK} $with_extra_cxxflags"
LDFLAGS_JDK="${LDFLAGS_JDK} $with_extra_ldflags"

###############################################################################
#
# Now setup the CFLAGS and LDFLAGS for the JDK build.
# Later we will also have CFLAGS and LDFLAGS for the hotspot subrepo build.
#
case $COMPILER_NAME in
      gcc )
      	  CCXXFLAGS_JDK="$CCXXFLAGS $CCXXFLAGS_JDK -W -Wall -Wno-unused -Wno-parentheses \
                          -pipe \
                          -D_GNU_SOURCE -D_REENTRANT -D_LARGEFILE64_SOURCE"
	  case $OPENJDK_TARGET_CPU_ARCH in
	  arm )
            # on arm we don't prevent gcc to omit frame pointer but do prevent strict aliasing
	    CFLAGS_JDK="${CFLAGS_JDK} -fno-strict-aliasing"
	  ;;
	  ppc )
            # on ppc we don't prevent gcc to omit frame pointer nor strict-aliasing
	  ;;
	  * )
	    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -fno-omit-frame-pointer"
	    CFLAGS_JDK="${CFLAGS_JDK} -fno-strict-aliasing"
          ;;
	  esac
          ;;
      ossc )
      	  CFLAGS_JDK="$CFLAGS_JDK -xc99=%none -xCC -errshort=tags -Xa -v -mt -norunpath -xnolib"
      	  CXXFLAGS_JDK="$CXXFLAGS_JDK -errtags=yes +w -mt -features=no%except -DCC_NOEX"
          ;;
      cl )
          CCXXFLAGS_JDK="$CCXXFLAGS $CCXXFLAGS_JDK -Zi -MD -Zc:wchar_t- -W3 -wd4800 \
               -D_STATIC_CPPLIB -D_DISABLE_DEPRECATE_STATIC_CPPLIB -DWIN32_LEAN_AND_MEAN \
	       -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE \
	       -DWIN32 -DIAL"
          case $LEGACY_OPENJDK_TARGET_CPU1 in
              i?86 )
                  CCXXFLAGS_JDK="$CCXXFLAGS_JDK -D_X86_ -Dx86"
                  ;;
              amd64 )
                  CCXXFLAGS_JDK="$CCXXFLAGS_JDK -D_AMD64_ -Damd64"
                  ;;
          esac
          ;;
esac

###############################################################################
#
# Cross-compile arch specific flags

#
if test "x$JDK_VARIANT" = "xembedded"; then
   CCXXFLAGS_JDK="$CCXXFLAGS_JDK -DJAVASE_EMBEDDED"
fi

case $OPENJDK_TARGET_CPU_ARCH in
arm )
    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -fsigned-char"
    ;;
ppc )
    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -fsigned-char"
    ;;
esac

###############################################################################

CCXXFLAGS_JDK="$CCXXFLAGS_JDK $ADD_LP64"

# The package path is used only on macosx?
PACKAGE_PATH=/opt/local
AC_SUBST(PACKAGE_PATH)

# Sometimes we use a cpu dir (.../lib/amd64/server) 
# Sometimes not (.../lib/server) 
LIBARCHDIR="$LEGACY_OPENJDK_TARGET_CPU2/"
if test "x$ENDIAN" = xlittle; then
    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -D_LITTLE_ENDIAN"
else
    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -D_BIG_ENDIAN"
fi
if test "x$OPENJDK_TARGET_OS" = xlinux; then
    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -DLINUX"
fi
if test "x$OPENJDK_TARGET_OS" = xwindows; then
    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -DWINDOWS"
fi
if test "x$OPENJDK_TARGET_OS" = xsolaris; then
    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -DSOLARIS"
fi
if test "x$OPENJDK_TARGET_OS" = xmacosx; then
    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -DMACOSX -D_ALLBSD_SOURCE"
    LIBARCHDIR=""
fi
if test "x$OPENJDK_TARGET_OS" = xbsd; then
    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -DBSD -D_ALLBSD_SOURCE"
fi
if test "x$DEBUG_LEVEL" = xrelease; then
    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -DNDEBUG"
else
    CCXXFLAGS_JDK="$CCXXFLAGS_JDK -DDEBUG"
fi

CCXXFLAGS_JDK="$CCXXFLAGS_JDK -DARCH='\"$LEGACY_OPENJDK_TARGET_CPU1\"' -D$LEGACY_OPENJDK_TARGET_CPU1"
CCXXFLAGS_JDK="$CCXXFLAGS_JDK -DRELEASE='\"$RELEASE\"'"

CCXXFLAGS_JDK="$CCXXFLAGS_JDK \
        -I${JDK_OUTPUTDIR}/include \
        -I${JDK_OUTPUTDIR}/include/$OPENJDK_TARGET_OS \
        -I${JDK_TOPDIR}/src/share/javavm/export \
        -I${JDK_TOPDIR}/src/$LEGACY_OPENJDK_TARGET_OS_API/javavm/export \
        -I${JDK_TOPDIR}/src/share/native/common \
        -I${JDK_TOPDIR}/src/$LEGACY_OPENJDK_TARGET_OS_API/native/common"

# The shared libraries are compiled using the picflag.
CFLAGS_JDKLIB="$CCXXFLAGS_JDK $CFLAGS_JDK $PICFLAG $CFLAGS_JDKLIB_EXTRA"
CXXFLAGS_JDKLIB="$CCXXFLAGS_JDK $CXXFLAGS_JDK $PICFLAG $CXXFLAGS_JDKLIB_EXTRA "

# Executable flags
CFLAGS_JDKEXE="$CCXXFLAGS_JDK $CFLAGS_JDK"
CXXFLAGS_JDKEXE="$CCXXFLAGS_JDK $CXXFLAGS_JDK"

# Now this is odd. The JDK native libraries have to link against libjvm.so
# On 32-bit machines there is normally two distinct libjvm.so:s, client and server.
# Which should we link to? Are we lucky enough that the binary api to the libjvm.so library
# is identical for client and server? Yes. Which is picked at runtime (client or server)?
# Neither, since the chosen libjvm.so has already been loaded by the launcher, all the following
# libraries will link to whatever is in memory. Yuck. 
#
# Thus we offer the compiler to find libjvm.so first in server then in client. It works. Ugh.
if test "x$COMPILER_TYPE" = xCL; then
    LDFLAGS_JDK="$LDFLAGS_JDK -nologo -opt:ref -incremental:no"
    if test "x$LEGACY_OPENJDK_TARGET_CPU1" = xi586; then 
        LDFLAGS_JDK="$LDFLAGS_JDK -safeseh"
    fi
    # TODO: make -debug optional "--disable-full-debug-symbols"
    LDFLAGS_JDK="$LDFLAGS_JDK -debug"
    LDFLAGS_JDKLIB="${LDFLAGS_JDK} -dll -libpath:${JDK_OUTPUTDIR}/lib"
    LDFLAGS_JDKLIB_SUFFIX=""
    if test "x$OPENJDK_TARGET_CPU_BITS" = "x64"; then
        LDFLAGS_STACK_SIZE=1048576
    else
        LDFLAGS_STACK_SIZE=327680
    fi
    LDFLAGS_JDKEXE="${LDFLAGS_JDK} /STACK:$LDFLAGS_STACK_SIZE"
else
    # If this is a --hash-style=gnu system, use --hash-style=both, why?
    HAS_GNU_HASH=`$CC -dumpspecs 2>/dev/null | $GREP 'hash-style=gnu'`
    if test -n "$HAS_GNU_HASH"; then
        # And since we now know that the linker is gnu, then add -z defs, to forbid
        # undefined symbols in object files.
        LDFLAGS_JDK="${LDFLAGS_JDK} -Xlinker --hash-style=both -Xlinker -z -Xlinker defs"
        if test "x$DEBUG_LEVEL" == "xrelease"; then
            # When building release libraries, tell the linker optimize them.
            # Should this be supplied to the OSS linker as well?
            LDFLAGS_JDK="${LDFLAGS_JDK} -Xlinker -O1"
        fi
    fi

    LDFLAGS_JDKLIB="${LDFLAGS_JDK} $SHARED_LIBRARY_FLAGS \
                    -L${JDK_OUTPUTDIR}/lib/${LIBARCHDIR}server \
                    -L${JDK_OUTPUTDIR}/lib/${LIBARCHDIR}client \
  	            -L${JDK_OUTPUTDIR}/lib/${LIBARCHDIR}"
    LDFLAGS_JDKLIB_SUFFIX="-ljvm -ljava"
    if test "x$COMPILER_NAME" = xossc; then
        LDFLAGS_JDKLIB_SUFFIX="$LDFLAGS_JDKLIB_SUFFIX -lc"
    fi

    # Only the jli library is explicitly linked when the launchers are built.
    # The libjvm is then dynamically loaded/linked by the launcher.
    LDFLAGS_JDKEXE="${LDFLAGS_JDK}"
    if test "x$OPENJDK_TARGET_OS" != "xmacosx"; then
       LDFLAGS_JDKEXE="$LDFLAGS_JDKEXE -L${JDK_OUTPUTDIR}/lib/${LIBARCHDIR}jli"
       LDFLAGS_JDKEXE_SUFFIX="-ljli"
    fi
fi

# Adjust flags according to debug level.
case $DEBUG_LEVEL in
      fastdebug ) 
              CFLAGS="$CFLAGS $D_FLAG"
              JAVAC_FLAGS="$JAVAC_FLAGS -g"
              ;;
      slowdebug )
              CFLAGS="$CFLAGS $D_FLAG"
	      C_O_FLAG_HI="$C_O_FLAG_NONE"
	      C_O_FLAG_NORM="$C_O_FLAG_NONE"
	      CXX_O_FLAG_HI="$CXX_O_FLAG_NONE"
	      CXX_O_FLAG_NORM="$CXX_O_FLAG_NONE"
              JAVAC_FLAGS="$JAVAC_FLAGS -g"
              ;;
esac              

                
AC_SUBST(CFLAGS_JDKLIB)
AC_SUBST(CFLAGS_JDKEXE)

AC_SUBST(CXXFLAGS_JDKLIB)
AC_SUBST(CXXFLAGS_JDKEXE)

AC_SUBST(LDFLAGS_JDKLIB)
AC_SUBST(LDFLAGS_JDKEXE)
AC_SUBST(LDFLAGS_JDKLIB_SUFFIX)
AC_SUBST(LDFLAGS_JDKEXE_SUFFIX)
])
