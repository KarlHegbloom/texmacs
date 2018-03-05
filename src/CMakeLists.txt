#############################################################################
# MODULE     : Toplevel CMakeLists.txt file for TeXmacs
# COPYRIGHT  : (C) 2016  Joris van der Hoeven
###############################################################################
# This software falls under the GNU general public license version 3 or later.
# It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
# in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
###############################################################################
#
# Initialy created by Massimiliano Gubinelli
#
#  Modifications by Darcy Shen
#
#  Modifications by Karl M. Hegbloom <karl.hegbloom@gmail.com>
#

### --------------------------------------------------------------------
### Basic settings (project independent)
### --------------------------------------------------------------------

cmake_minimum_required(VERSION 3.5)

### --------------------------------------------------------------------
### Project name
### --------------------------------------------------------------------
###
### The name of our project is "TEXMACS". CMakeLists files in this
### project can refer to the root source directory of the project as
### ${TEXMACS_SOURCE_DIR} and to the root binary directory of the
### project as ${TEXMACS_BINARY_DIR}.
###
project(TEXMACS CXX C) # check for C/C++ compiler
set(PACKAGE TeXmacs)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${TEXMACS_SOURCE_DIR}/cmake)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

### --------------------------------------------------------------------
### Include standard modules
### --------------------------------------------------------------------

set(CMAKE_CXX_STANDARD 11)

include(CheckFunctionExists)
include(CheckLibraryExists)
include(CheckIncludeFile)
include(CheckTypeSize)
include(FindPkgConfig)
include(CheckCSourceCompiles)
include(CMakeDependentOption)
include(FindX11)

###
### TODO: write support for CMAKE_BUILD_TYPE
###
set(CMAKE_BUILD_TYPE RelWithDebInfo
  CACHE STRING "Choose the type of build, options are:
None Debug Release RelWithDebInfo MinSizeRel MacPorts."
  STRINGS None Debug Release RelWithDebInfo MinSizeRel MacPorts)

set(DEBUG_ON FALSE)
if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
  set(DEBUG_ON TRUE)
endif(CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")

### --------------------------------------------------------------------
### Set the executable target name
### --------------------------------------------------------------------

set(TeXmacs_binary_name "texmacs.bin")


### Get this now, in order to know Guile's version information.
find_package(Guile REQUIRED)
set(PKGREV "-guile-${Guile_VERSION_STRING}")

if(${Guile_VERSION_STRING} VERSION_LESS 2.0)
  set(DEVEL_VERSION "1.99.6")
  set(DEVEL_RELEASE "1")
  set(STABLE_VERSION "1.99.6")
  set(STABLE_RELEASE "1")
  set(DEVEL_VERSION_MAJOR "1")
  set(DEVEL_VERSION_MINOR "8")
else(${Guile_VERSION_STRING} VERSION_LESS 2.0)
  set(DEVEL_VERSION "2.0.0")
  set(DEVEL_RELEASE "2")
  set(STABLE_VERSION "2.0.0")
  set(STABLE_RELEASE "2")
  set(DEVEL_VERSION_MAJOR "2")
  set(DEVEL_VERSION_MINOR "0")
endif(${Guile_VERSION_STRING} VERSION_LESS 2.0)

message(STATUS "Getting revision control metadata for PKGREV...")
message(STATUS "-- TEXMACS_SOURCE_DIR   : ${TEXMACS_SOURCE_DIR}")

### Set GITDIR. Not set if not there.
if(EXISTS "${TEXMACS_SOURCE_DIR}/.git" AND
    NOT IS_SYMLINK "${TEXMACS_SOURCE_DIR}/.git" AND
    NOT IS_DIRECTORY "${TEXMACS_SOURCE_DIR}/.git")
  file(READ "${TEXMACS_SOURCE_DIR}/.git" GITDIR)
  string(STRIP "${GITDIR}" GITDIR)

elseif(EXISTS "${TEXMACS_SOURCE_DIR}/../.git" AND
    NOT IS_SYMLINK "${TEXMACS_SOURCE_DIR}/../.git" AND
    NOT IS_DIRECTORY "${TEXMACS_SOURCE_DIR}/../.git")
  file(READ "${TEXMACS_SOURCE_DIR}/.git" GITDIR)
  string(STRIP "${GITDIR}" GITDIR)

elseif(EXISTS "${TEXMACS_SOURCE_DIR}/.git")
  set(GITDIR "${TEXMACS_SOURCE_DIR}/.git")

elseif(EXISTS "${TEXMACS_SOURCE_DIR}/../.git")
  set(GITDIR "${TEXMACS_SOURCE_DIR}/../.git")

endif(EXISTS "${TEXMACS_SOURCE_DIR}/.git" AND
  NOT IS_SYMLINK "${TEXMACS_SOURCE_DIR}/.git" AND
  NOT IS_DIRECTORY "${TEXMACS_SOURCE_DIR}/.git")


if(NOT "${GITDIR}" STREQUAL "")
  message(STATUS "-- GITDIR               : ${GITDIR}")
endif(NOT "${GITDIR}" STREQUAL "")


### Can svn work via an indirect repo directory like git can?
if(IS_DIRECTORY "${TEXMACS_SOURCE_DIR}/.svn")
  message(STATUS "-- This is a svn checkout.")
  execute_process(COMMAND svnversion -n .
    WORKING_DIRECTORY "${TEXMACS_SOURCE_DIR}"
    OUTPUT_VARIABLE SVNREV ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

elseif(NOT "${GITDIR}" STREQUAL "" AND IS_DIRECTORY "${GITDIR}/svn")
  message(STATUS "-- This is a git svn clone.")
  ## Do not use `git svn info` for this because it provides incorrect results.
  ## Instead, parse the `git rev-list` for the information that git svn writes
  ## into the commit log during `git svn rebase` on the svn-trunk branch,
  ## which is then merged into the present branch.
  ## Requires sed.
  execute_process(COMMAND git rev-list --max-count=100 --pretty=medium HEAD@{0}
    COMMAND sed -rne "/git-svn-id:/ {s,.*://.*@([^ ]+).*,\\1,p ;/./ q 0}"
    WORKING_DIRECTORY "${TEXMACS_SOURCE_DIR}"
    OUTPUT_VARIABLE SVNREV ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
endif(IS_DIRECTORY "${TEXMACS_SOURCE_DIR}/.svn")

if("${SVNREV}" STREQUAL "" OR
    "${SVNREV}" STREQUAL "exported" OR
    "${SVNREV}" STREQUAL "Unversioned directory")
  ## The above failed, or this is an exported source distribution.
  if(EXISTS "${TEXMACS_SOURCE_DIR}/SVNREV")
    message(STATUS "-- Setting SVNREV from ${TEXMACS_SOURCE_DIR}/SVNREV")
    set(SVNREV "")
    file(READ "${TEXMACS_SOURCE_DIR}/SVNREV" SVNREV)
    string(STRIP "${SVNREV}" SVNREV)
  endif(EXISTS "${TEXMACS_SOURCE_DIR}/SVNREV")
endif("${SVNREV}" STREQUAL "" OR
  "${SVNREV}" STREQUAL "exported" OR
  "${SVNREV}" STREQUAL "Unversioned directory")

if(NOT "${SVNREV}" STREQUAL "")
  file(WRITE "${TEXMACS_SOURCE_DIR}/SVNREV" "${SVNREV}")
  message(STATUS "-- SVNREV               : ${SVNREV}")
  string(APPEND PKGREV "-svn-${SVNREV}")
endif(NOT "${SVNREV}" STREQUAL "")

if(NOT "${GITDIR}" STREQUAL "" AND EXISTS "${GITDIR}")
  message(STATUS "-- Getting git commit count and head treeish for PKGREV...")
  ## We use the commit count to get monotonically increasing version numbers.
  execute_process(COMMAND git log --oneline COMMAND wc -l
    WORKING_DIRECTORY "${TEXMACS_SOURCE_DIR}"
    OUTPUT_VARIABLE GITCOMMITCOUNT ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(COMMAND git log -n 1 --oneline COMMAND cut -f1 -d\ #
    WORKING_DIRECTORY "${TEXMACS_SOURCE_DIR}"
    OUTPUT_VARIABLE GITSHA ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(APPEND PKGREV "-git-n${GITCOMMITCOUNT}-${GITSHA}")
endif(NOT "${GITDIR}" STREQUAL "" AND EXISTS "${GITDIR}")

message(STATUS "-- PKGREV               : ${PKGREV}")

# The string(TIMESTAMP command lacks formatting directives required to form
# a Debian Changelog signature line.

execute_process(COMMAND date "+%a, %d %b %Y %H:%M:%S %z"
  OUTPUT_VARIABLE PKG_DATE ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
if("${PKG_DATE}" STREQUAL "")
  set(PKG_DATE "Tue, 14 Jun 2016 21:21:21 -0600")
endif("${PKG_DATE}" STREQUAL "")



### --------------------------------------------------------------------
### Package Data
### --------------------------------------------------------------------
###
### TODO: Make sure these are used, and learn where
### TODO: Cause it to build a MacPorts port
### TODO: Cause it to build a MacOS dmg app package
### TODO: Cause it to build a Windows installer package
### TODO: Test rpm building and other installer packages
### TODO: Ongoing support for deb building
###
set(PKG_MAINTAINER "Myself <myself@localhost>"
  CACHE STRING "Fullname <email@host.name> for debian/Changelog, etc.")

set(PACKAGE_NAME      "texmacs")
set(PACKAGE_BUGREPORT "https://github.com/texmacs/texmacs/issues")
set(PACKAGE_URL       "https://github.com/texmacs/texmacs")
set(PACKAGE_VERSION   "${DEVEL_VERSION}-${DEVEL_RELEASE}${PKGREV}")
set(PACKAGE_STRING    "${PACKAGE_NAME}-${PACKAGE_VERSION}")
set(PACKAGE_TARNAME   "${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.xz")
set(DEBIAN_NAME ${PACKAGE_NAME})

message(STATUS "-- PKG_MAINTAINER       : ${PKG_MAINTAINER}")
message(STATUS "-- PKG_DATE             : ${PKG_DATE}")
message(STATUS "-- PACKAGE_BUGREPORT    : ${PACKAGE_BUGREPORT}")
message(STATUS "-- PACKAGE_NAME         : ${PACKAGE_NAME}")
message(STATUS "-- PACKAGE_STRING       : ${PACKAGE_STRING}")
message(STATUS "-- PACKAGE_TARNAME      : ${PACKAGE_TARNAME}")
message(STATUS "-- PACKAGE_URL          : ${PACKAGE_URL}")
message(STATUS "-- PACKAGE_VERSION      : ${PACKAGE_VERSION}")

### --------------------------------------------------------------------
### Check for standard functionalities
### --------------------------------------------------------------------

# ? set(GUILE_NUM 1)

set(STDC_HEADERS ON)
set(CMAKE_CXX_FLAGS "-Wno-deprecated-register -include config.h")

check_type_size(FILE     HAVE_FILE)
check_type_size(intptr_t HAVE_INTPTR_T)
check_type_size(time_t   HAVE_TIME_T)

check_include_file(inttypes.h  HAVE_INTTYPES_H)
check_include_file(memory.h    HAVE_MEMORY_H)
check_include_file(stdlib.h    HAVE_STDLIB_H)
check_include_file(strings.h   HAVE_STRINGS_H)
check_include_file(string.h    HAVE_STRING_H)
check_include_file(sys/stat.h  HAVE_SYS_STAT_H)
check_include_file(unistd.h    HAVE_UNISTD_H)
check_include_file(X11/Xlib.h  HAVE_X11_XLIB_H)
check_include_file(X11/Xutil.h HAVE_X11_XUTIL_H)
check_include_file(pty.h       HAVE_PTY_H)
check_include_file(util.h      HAVE_UTIL_H)

check_function_exists(gettimeofday HAVE_GETTIMEOFDAY)

check_function_exists(setenv       HAVE_SETENV)
## check_function_exists(putenv       HAVE_PUTENV)
if(${HAVE_SETENV})
  set(CONFIG_STD_SETENV "#define STD_SETENV")
endif(${HAVE_SETENV})


### --------------------------------------------------------------------
### Check for dl library
###
### Checks for dlopen in standard or dl library
### we are looking in sequence for dlopen or dld_link or shl_load in
### standard libs or libdl or libdld
###
### Shouldn't we just use libtool and libltdl ?  It's what Guile uses.
### --------------------------------------------------------------------

### future? CHECK_INCLUDE_FILE(libltdl/lt_dlloader.h HAVE_LT_DLLOADER_H)
### future? CHECK_LIBRARY_EXISTS(ltdl lt_module_open HAVE_LT_MODULE_OPEN)

### CMAKE_DL_LIBS "dl"

CHECK_INCLUDE_FILE(dlfcn.h HAVE_DLFCN_H)

CHECK_LIBRARY_EXISTS(dl dlopen "" HAVE_DLOPEN)
IF (${HAVE_DLOPEN})
  SET(CONFIG_BDL "-ldl")
  SET(TM_DYNAMIC_LINKING dlopen)
ENDIF (${HAVE_DLOPEN})

IF (NOT ${HAVE_DLOPEN})
  CHECK_LIBRARY_EXISTS(dld dlopen "" HAVE_DLOPEN)
  IF (${HAVE_DLOPEN})
    SET(CONFIG_BDL "-ldld")
    SET(TM_DYNAMIC_LINKING dlopen)
  ENDIF (${HAVE_DLOPEN})
ENDIF (NOT ${HAVE_DLOPEN})


IF (NOT ${HAVE_DLOPEN})
  CHECK_LIBRARY_EXISTS(dl dld_link "" HAVE_DLOPEN)
  IF (${HAVE_DLOPEN})
    SET(CONFIG_BDL "-ldl")
    SET(TM_DYNAMIC_LINKING dld_link)
  ENDIF (${HAVE_DLOPEN})
ENDIF (NOT ${HAVE_DLOPEN})

IF (NOT ${HAVE_DLOPEN})
  CHECK_LIBRARY_EXISTS(dld dld_link "" HAVE_DLOPEN)
  IF (${HAVE_DLOPEN})
    SET(CONFIG_BDL "-ldld")
    SET(TM_DYNAMIC_LINKING dld_link)
  ENDIF (${HAVE_DLOPEN})
ENDIF (NOT ${HAVE_DLOPEN})


IF (NOT ${HAVE_DLOPEN})
  CHECK_LIBRARY_EXISTS(dl shl_load "" HAVE_DLOPEN)
  IF (${HAVE_DLOPEN})
    SET(CONFIG_BDL "-ldl")
    SET(TM_DYNAMIC_LINKING shl_load)
  ENDIF (${HAVE_DLOPEN})
ENDIF (NOT ${HAVE_DLOPEN})

IF (NOT ${HAVE_DLOPEN})
  CHECK_LIBRARY_EXISTS(dld shl_load "" HAVE_DLOPEN)
  IF (${HAVE_DLOPEN})
    SET(CONFIG_BDL "-ldld")
    SET(TM_DYNAMIC_LINKING shl_load)
  ENDIF (${HAVE_DLOPEN})
ENDIF (NOT ${HAVE_DLOPEN})


option (USE_SQLITE3 "Use SQLite3" ON)
if (USE_SQLITE3)
    find_package (SQLite3 REQUIRED)
    option (LINKED_SQLITE3 "Use Linked SQLite3" ON)
endif (USE_SQLITE3)

option (USE_FREETYPE "use Freetype" ON)
if (USE_FREETYPE)
  find_package (Freetype REQUIRED)
  option(LINKED_FREETYPE "Link Freetype at build time." ON)
endif (USE_FREETYPE)

# TODO: fix bitrot in the Cairo plugin.
option (USE_CAIRO "use Cairo" OFF)
if (USE_CAIRO)
  pkg_check_modules(Cairo cairo)
  option(LINKED_CAIRO "Link Cairo at build time." ON)
endif (USE_CAIRO)

option (USE_IMLIB2 "use Imlib2" ON)
if (USE_IMLIB2)
  pkg_check_modules(Imlib2 imlib2)
  option(LINKED_IMLIB2 "Link imlib2 at build time." ON)
endif (USE_IMLIB2)

option (USE_SPARKLE "use Sparkle" OFF)
if(USE_SPARKLE)
  # TODO: Untested
  pkg_check_modules(Sparkle sparkle)
endif(USE_SPARKLE)

find_package(ZLIB)
find_package(JPEG)
find_package(PNG)
find_package(Iconv)
# find_package(axel) # ?

set(USE_GS 1)
set(CONFIG_GS "Ghostscript")

# GS_EXE is not really used by the C++ code, which looks in the PATH
# which is right, since build-configuration time isn't really when to
# look for it anyway.
# set(GS_EXE "gs")
# message(STATUS "  GS_EXE is ${GS_EXE}")
#
# # These next two are unused by any C++ or Scheme code:
# set(GS_FONTS ../share/ghostscript/fonts:/usr/share/fonts:) # Unused
# set(GS_LIB ../share/ghostscript/9.06/lib:) # Unused

if(ZLIB_FOUND AND PNG_FOUND)
  set(PDF_RENDERER 1)
  set(CONFIG_PDF "Pdf")
  set(PDFHUMMUS_NO_TIFF ON)
  set(PDFHUMMUS_NO_DCT ON)
endif(ZLIB_FOUND AND PNG_FOUND)

if(APPLE)
  option(MACOSX_EXTENSIONS "Use Mac specific services (spellchecker, image handling, ...)" ON)
  set(OS_MACOS ON)
  option(MACOS_QT_MENU "Disable MacOS native menu" ON)
endif(APPLE)

# TODO: if windows...
# option(USE_WINDOWS_CONSOLE "enable windows console" OFF)
# if(USE_WINDOWS_CONSOLE)
#   then  AC_MSG_RESULT([enabling Windows console])
#   LC_SCATTER_FLAGS([-mconsole])
#   else  AC_MSG_RESULT([disabling Windows console])
#   LC_SCATTER_FLAGS([-mwindows])
# endif(USE_WINDOWS_CONSOLE)

# set(CONFIG_CXXFLAGS    "")
# set(CONFIG_CXXTEMPLATE "")

set(CONFIG_SO       "so")
set(CONFIG_LIB_PATH "LD_LIBRARY_PATH")

if(APPLE)
  set(CONFIG_SO       "dylib")
  set(CONFIG_LIB_PATH "DYLD_LIBRARY_PATH")
endif(APPLE)

set(CONFIG_CHMOD           "chmod -f")
set(CONFIG_CXXOPTIMIZE     "-ggdb3 -O3 -fexpensive-optimizations -fno-rtti")
set(CONFIG_BSTATIC         "-Wl,-Bstatic")
set(CONFIG_BSHARED         "-Wl,-Bdynamic")
set(CONFIG_BFLAGS          "")
set(CONFIG_BPATH           "-Wl,-rpath,")
set(CONFIG_WORD_LENGTH     "4")
set(CONFIG_WORD_LENGTH_INC "3")
set(CONFIG_WORD_MASK       "0xfffffffc")
set(CONFIG_MAX_FAST        "260 // WORD_LENGTH more than power of 2")

### CMAKE_SIZEOF_VOID_P "8"
check_type_size("void*" SIZE_OF_VOIDP)

message(STATUS "Check if we are on a 64-bits computer...")
if (${SIZE_OF_VOIDP} EQUAL 8)
  ## Sets WORD_LENGTH etc., used by ./src/System/Misc/fast_alloc.[hc]pp
  set(CONFIG_WORD_LENGTH     "8")
  set(CONFIG_WORD_LENGTH_INC "7")
  set(CONFIG_WORD_MASK       "0xfffffffffffffff8")
  set(CONFIG_MAX_FAST        "264 // WORD_LENGTH more than power of 2")
  message(STATUS "== Yes.")
else(${SIZE_OF_VOIDP} EQUAL 8)
  message(STATUS "-- No.")
endif (${SIZE_OF_VOIDP} EQUAL 8)


IF(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
  MESSAGE(STATUS "Final adjustments for an Intel or AMD GNU/Linux host")
  SET(CONFIG_CXXOPTIMIZE "-ggdb3 -O3 -fexpensive-optimizations  -fno-rtti")
  SET(CMAKE_CXX_FLAGS "")
  SET(CMAKE_CXX_FLAGS_DEBUG "-ggdb3")
  SET(CMAKE_CXX_FLAGS_DEBUG_INIT "-ggdb3")
  SET(CMAKE_CXX_FLAGS_MINSIZEREL "-Os -DNDEBUG")
  SET(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "-Os -DNDEBUG")
  SET(CMAKE_CXX_FLAGS_RELEASE "-O3 -fexpensive-optimizations  -fno-rtti -DNDEBUG")
  SET(CMAKE_CXX_FLAGS_RELEASE_INIT "-O3 -fexpensive-optimizations  -fno-rtti -DNDEBUG")
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-ggdb3 -O3 -fexpensive-optimizations -fno-rtti")
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-ggdb3 -O3 -fexpensive-optimizations -fno-rtti")
ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")

IF(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")
  MESSAGE(STATUS "Final adjustments for an Intel or AMD GNU/BSD host")
  SET(CONFIG_CXXOPTIMIZE "-g3 -O3 -fexpensive-optimizations")
ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "FreeBSD")

IF(${CMAKE_SYSTEM_NAME} STREQUAL "SunOS")
  MESSAGE(STATUS "Final adjustments for an Intel or AMS Solaris host")
  SET(CONFIG_CXXOPTIMIZE "-g3 -O3 -fexpensive-optimizations")
  SET(CONFIG_BPATH "-Wl,-R,")
#  SET(X11_LDFLAGS "${X_LIBS} -lXext -lX11 -lsocket")
ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "SunOS")

IF(${CMAKE_SYSTEM_NAME} STREQUAL "CYGWIN_NT-5.1")
  MESSAGE(STATUS "Final adjustments for cygwin host")
  SET(CONFIG_OS "CYGWIN")
  SET(CONFIG_BFLAGS "-Wl,-stack,8388608")
ENDIF(${CMAKE_SYSTEM_NAME} STREQUAL "CYGWIN_NT-5.1")

### --------------------------------------------------------------------
### Experimental options
### --------------------------------------------------------------------

### Does not compile. Turn it off for now.
option(EXPERIMENTAL "Enable experimental Memorizer Environment Evaluate" OFF)

### --------------------------------------------------------------------
###  Guile
### --------------------------------------------------------------------
###

set(SCM_SIZET scm_sizet)
###
if(Guile_VERSION_STRING VERSION_LESS 1.6)
  set(CONFIG_GUILE_SERIAL "A")
  set(GUILE_A 1)
elseif(Guile_VERSION_STRING VERSION_LESS 1.8)
  set(CONFIG_GUILE_SERIAL "B")
  set(GUILE_B 1)
  check_include_file(libguile16.h GUILE_HEADER_16)
elseif(Guile_VERSION_STRING VERSION_LESS 2.0)
  set(CONFIG_GUILE_SERIAL "C")
  set(GUILE_C 1)
  check_include_file(libguile18.h GUILE_HEADER_18)
elseif(Guile_VERSION_STRING VERSION_LESS 3.0)
    set(CONFIG_GUILE_SERIAL "D")
    set(GUILE_D 1)
    set(SCM_SIZET size_t)
else(Guile_VERSION_STRING VERSION_LESS 1.6)
  message(ERROR "Not Guile serial A,B,C or D???")
endif(Guile_VERSION_STRING VERSION_LESS 1.6)

set(CMAKE_REQUIRED_FLAGS     "-Werror ${Guile_CFLAGS}")
set(CMAKE_REQUIRED_INCLUDES  ${Guile_INCLUDE_DIRS})
set(CMAKE_REQUIRED_LIBRARIES ${Guile_LIBRARIES})

# For old versions of Guile.
message(STATUS "Checking guile string size type...")

check_c_source_compiles(  "#include <guile/gh.h>
  #include <libguile.h>
  void print_string (SCM s) {
    int len_r;
    char* r= gh_scm2newstr (s, &len_r); } int main() { return 0; }
" _guile_str_size_test)

if(_guile_str_size_test)
  set(guile_str_size_t int)
else(_guile_str_size_test)
  set(guile_str_size_t size_t)
endif(_guile_str_size_test)


# For old versions of Guile.
message(STATUS "Checking whether ... arguments behave correctly...")

check_c_source_compiles(
" #include <guile/gh.h>
  #include <libguile.h>
  typedef SCM (*FN)(...);
  static SCM identity (SCM x) { return x; }
  void declare () { gh_new_procedure (\"identity\", (FN) identity, 1, 0, 0); }
  int main() { return 0; }
" _guile_dots_test)

if(_guile_dots_test)
  set(DOTS_OK 1)
else(_guile_dots_test)
  set(DOTS_OK)
endif(_guile_dots_test)



### --------------------------------------------------------------------
### Memory allocation options
### --------------------------------------------------------------------

cmake_dependent_option(DISABLE_FASTALLOC
  "Compile with NO_FAST_ALLOC on"
  OFF
  "CONFIG_GUI_IS_QT" ON)

if(${DISABLE_FASTALLOC})
  set(NO_FAST_ALLOC ON)
endif(${DISABLE_FASTALLOC})


### --------------------------------------------------------------------
### GUI selection
### --------------------------------------------------------------------

option (QTPIPES "use Qt pipes" OFF)

set(GUI_TYPE) # nothing or WIN32, MACOSX bundles are treated independetly

if(NOT TEXMACS_GUI)
  set(TEXMACS_GUI "Qt" CACHE STRING "TeXmacs Gui (Qt, Qt5, Qt4, X11, Aqua)")
endif(NOT TEXMACS_GUI)

# TODO: Determine what is the actual minimum Qt5 version?
set(TM_QT5_MIN_VERSION 5.2.0)
set(TM_QT4_MIN_VERSION 4.8.7)


if(TEXMACS_GUI STREQUAL "Qt")
  #find_package(Qt5 ${TM_QT5_MIN_VERSION} COMPONENTS Core Gui Widgets PrintSupport)
  find_package(Qt5 ${TM_QT5_MIN_VERSION} COMPONENTS Core Gui PrintSupport)
  if(Qt5_FOUND)
    set(TEXMACS_GUI "Qt5")
    set(HAVE_QT ON)
  else(Qt5_FOUND)
    find_package(Qt4 ${TM_QT4_MIN_VERSION} COMPONENTS QtCore QtGui)
    if(QT4_FOUND)
      set(TEXMACS_GUI "Qt4")
      set(HAVE_QT ON)
    else(QT4_FOUND)
      message(ERROR "!! Neither Qt5 nor Qt4 found !!")
      # TODO: Detect appropriate default for OS environment? Should stop at the above error anyway.
      # set(TEXMACS_GUI "X11")
    endif(QT4_FOUND)
  endif(Qt5_FOUND)
endif(TEXMACS_GUI STREQUAL "Qt")


if(TEXMACS_GUI STREQUAL "Qt5")

  find_package(Qt5 ${TM_QT5_MIN_VERSION} COMPONENTS Core Gui Widgets PrintSupport REQUIRED)

  if(Qt5_FOUND)
    set(QT_LIBRARIES ${Qt5Core_LIBRARIES} ${Qt5Gui_LIBRARIES} ${Qt5Widgets_LIBRARIES} ${Qt5PrintSupport_LIBRARIES})

    if(WIN32)
      set(GUI_TYPE WIN32)
    endif(WIN32)

    include_directories(
      ${Qt5Core_INCLUDE_DIRS}
      ${Qt5Gui_INCLUDE_DIRS}
      # ${Qt5Widgets_INCLUDE_DIRS}
      ${Qt5PrintSupport_INCLUDE_DIRS}
      # ${Qt5Svg_INCLUDE_DIRS}
      # ${Qt5X11Extras_INCLUDE_DIRS}
      )
    # include(${QT_USE_FILE})
    add_definitions("-DQTTEXMACS")
    set(QTTEXMACS ON)
    set(CONFIG_GUI "QT")
    set(CONFIG_QT "Qt")
    set(CONFIG_GUI_IS_QT ON)
    set(NO_FAST_ALLOC ON)
    set(QTPIPES ON)
    message(STATUS "Enabling Qt GUI")

  else(Qt5_FOUND)
    message(ERROR "Doh! Qt5 is required to compile the Qt5 GUI")
  endif(Qt5_FOUND)

elseif(TEXMACS_GUI STREQUAL "Qt4")

  find_package(Qt4 ${TM_QT4_MIN_VERSION} COMPONENTS QtCore QtGui REQUIRED)

  if(QT4_FOUND)
    if(WIN32)
     set(GUI_TYPE WIN32)
    endif(WIN32)

    include(${QT_USE_FILE})
    add_definitions("-DQTTEXMACS")
    set(CONFIG_GUI "QT")
    set(CONFIG_QT "Qt")
    set(CONFIG_GUI_IS_QT ON)
    set(NO_FAST_ALLOC ON)
    set(QTPIPES ON)
    message(STATUS "Enabling Qt4 GUI")
  else(QT4_FOUND)
    message(ERROR "Qt4 is required to compile the Qt4 GUI")
  endif(QT4_FOUND)


elseif(TEXMACS_GUI STREQUAL "Aqua")

  if (APPLE)
    set(GUI_TYPE MACOSX_BUNDLE)

    set(AQUATEXMACS ON)
    set(COCOA_CFLAGS "")
    set(COCOA_LDFLAGS "-framework COCOA")
    set(CONFIG_GUI "COCOA")
    set(CONFIG_COCOA "Cocoa")

    message(STATUS "Enabling Cocoa GUI")

  else (APPLE)

    message( ERROR "Aqua GUI is not supported on this system")

  endif (APPLE)


else(TEXMACS_GUI STREQUAL "Qt")

  find_package(X11)

  include_directories(${X11_INCLUDE_DIR})
  add_definitions("-DX11TEXMACS")
  set(X11TEXMACS ON)

  set(CONFIG_X11 "X11 Widkit Ghostscript")
  set(CONFIG_GUI "X11")
  set(TEXMACS_GUI "X11")

  message(STATUS "Enabling X11 GUI interface")

endif(TEXMACS_GUI STREQUAL "Qt5")


### --------------------------------------------------------------------
### Documentation options
### --------------------------------------------------------------------

include(Doxygen)


### --------------------------------------------------------------------
### Debugging options
### --------------------------------------------------------------------

# TODO set up debugging options, debug build, experimental, etc.
set(USE_STACK_TRACE ON)
set(DEBUG_ASSERT ON)


### --------------------------------------------------------------------
### Warning options
### --------------------------------------------------------------------


### --------------------------------------------------------------------
### Optimization options
### --------------------------------------------------------------------


### --------------------------------------------------------------------
### Generate configure headers
### --------------------------------------------------------------------

configure_file(${TEXMACS_SOURCE_DIR}/src/System/config.h.cmake ${TEXMACS_SOURCE_DIR}/src/System/config.h)
configure_file(${TEXMACS_SOURCE_DIR}/src/System/config.h.cmake ${TEXMACS_BINARY_DIR}/src/System/config.h)

set(tm_orig            ${TEXMACS_SOURCE_DIR})
set(CONFIG_HOST_OS     "linux-gnu") # TODO: should not be hard-coded
set(CONFIG_HOST_VENDOR "pc") # TODO: should not be hard-coded
set(CONFIG_HOST_CPU    ${CMAKE_SYSTEM_PROCESSOR})
set(CONFIG_USER        $ENV{USER})
string(TIMESTAMP CONFIG_DATE)
set(tm_devel          TeXmacs-${DEVEL_VERSION})
set(tm_stable         TeXmacs-${STABLE_VERSION})
set(tm_devel_release  ${tm_devel}-${DEVEL_RELEASE})
set(tm_stable_release ${tm_stable}-${STABLE_RELEASE})

configure_file(${TEXMACS_SOURCE_DIR}/src/System/tm_configure.in ${TEXMACS_BINARY_DIR}/src/System/tm_configure.hpp)

set(prefix      ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${prefix})
set(datarootdir ${prefix}/share)
set(datadir     ${datarootdir})
set(tmdata      ${datarootdir}/TeXmacs)
set(tmbin       ${exec_prefix}/lib/texmacs/TeXmacs)
set(tmsrc       ${TEXMACS_SOURCE_DIR})

configure_file(misc/scripts/texmacs.in ${TEXMACS_BINARY_DIR}/misc/script/texmacs @ONLY)

configure_file(misc/scripts/fig2ps.in ${TEXMACS_BINARY_DIR}/misc/scripts/fig2ps @ONLY)

configure_file(misc/man/texmacs.1.in ${TEXMACS_SOURCE_DIR}/misc/man/texmacs.1 @ONLY)


file(REMOVE ${TEXMACS_SOURCE_DIR}/packages/debian/control)

configure_file(${TEXMACS_SOURCE_DIR}/packages/debian/control.in
  ${TEXMACS_SOURCE_DIR}/packages/debian/control @ONLY)

file(REMOVE ${TEXMACS_SOURCE_DIR}/packages/debian/changelog)

configure_file(${TEXMACS_SOURCE_DIR}/packages/debian/changelog.in
  ${TEXMACS_SOURCE_DIR}/packages/debian/changelog @ONLY)


### --------------------------------------------------------------------
### Compile sources
### --------------------------------------------------------------------

add_subdirectory(src)
add_subdirectory(plugins)
add_subdirectory(misc)
add_subdirectory(TeXmacs)


# autogenerate dependency information
set (CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)

### --------------------------------------------------------------------
### Complete bundle if MacOSX
### --------------------------------------------------------------------

if(APPLE AND NOT TEXMACS_GUI STREQUAL X11)
  set(BUNDLE_DEBUG_EXTENSION)
  if(DEBUG)
    set(BUNDLE_DEBUG_EXTENSION "_debug")
  endif(DEBUG)
  set(APP_BUNDLE_NAME ${TeXmacs_binary_name}${BUNDLE_DEBUG_EXTENSION}".app")
  add_custom_target(bundle
    mkdir -p ${TEXMACS_BINARY_DIR}/${APP_BUNDLE_NAME}/Contents/MacOS
    COMMAND mkdir -p ${TEXMACS_BINARY_DIR}/${APP_BUNDLE_NAME}/Contents/Resources
    COMMAND cp ${TEXMACS_SOURCE_DIR}/misc/bundle/Info.plist ${TEXMACS_BINARY_DIR}/${APP_BUNDLE_NAME}/Contents/Resources
    COMMAND cp ${TEXMACS_SOURCE_DIR}/misc/bundle/TeXmacs ${TEXMACS_BINARY_DIR}/${APP_BUNDLE_NAME}/Contents/MacOS
    COMMAND chmod a+x ${TEXMACS_BINARY_DIR}/${APP_BUNDLE_NAME}/Contents/MacOS/TeXmacs
    # TODO: what else?
    )
endif(APPLE AND NOT TEXMACS_GUI STREQUAL X11)


### --------------------------------------------------------------------
### Installation
### --------------------------------------------------------------------

# TODO: Check for MacOS compatibility; please think of MacPorts.
include(GNUInstallDirs)

### bin/
install(FILES
  ${TEXMACS_BINARY_DIR}/misc/script/texmacs
  ${TEXMACS_BINARY_DIR}/misc/scripts/fig2ps
  ${TEXMACS_SOURCE_DIR}/misc/scripts/tm_gs
  DESTINATION bin
  PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
  GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ)

### Makes the directory exist at the DESTINATION.
install(FILES  DESTINATION share/TeXmacs/bin
  PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ)

### include/
install(DIRECTORY TeXmacs/include DESTINATION ${CMAKE_INSTALL_PREFIX})

### share/
install(DIRECTORY TeXmacs DESTINATION share
  PATTERN "include" EXCLUDE)
install(DIRECTORY plugins DESTINATION share/TeXmacs
  PATTERN "bin" EXCLUDE)
### TODO: are these the right locations for MacOS or ...?
install(FILES TeXmacs/misc/mime/texmacs.applications DESTINATION share/application_registry)
install(FILES TeXmacs/misc/mime/texmacs.desktop      DESTINATION share/applications)
install(FILES TeXmacs/misc/images/TeXmacs.svg        DESTINATION share/icons/gnome/scalable/apps)
install(FILES TeXmacs/misc/images/text-texmacs.svg   DESTINATION share/icons/gnome/scalable/mimetypes)
install(FILES TeXmacs/misc/mime/texmacs.xml          DESTINATION share/mime/packages)
install(FILES TeXmacs/misc/pixmaps/TeXmacs.xpm       DESTINATION share/pixmaps)

### share/man
set(TOOLS "texmacs" "fig2ps")
set(MAN_SECTION "1")
#
# foreach(TOOL ${TOOLS})
#   set(TOOL_MANFILE "${CMAKE_CURRENT_SOURCE_DIR}/misc/man/${TOOL}.${MAN_SECTION}")
#   set(TOOL_MANFILE_GZ "${CMAKE_CURRENT_BINARY_DIR}/${TOOL}.${MAN_SECTION}.gz")
#   add_custom_command(
#     OUTPUT "${TOOL_MANFILE_GZ}"
#     COMMAND gzip -c "${TOOL_MANFILE}" > "${TOOL_MANFILE_GZ}"
#     MAIN_DEPENDENCY "${TOOL_MANFILE}"
#     COMMENT "Building ${TOOL} man page"
#     VERBATIM
#     )
#   add_custom_target("${TOOL}.${MAN_SECTION}" ALL DEPENDS "${TOOL_MANFILE_GZ}")
#   install(FILES "${TOOL_MANFILE_GZ}" DESTINATION "share/man/man${MAN_SECTION}")
# endforeach(TOOL)


###
### Last so everything is defined when it happens.
###
option(SAVE_SYSTEM_INFORMATION
  "Save cmake System Information to CMakeSystemInformation.txt"
  OFF)
if(${SAVE_SYSTEM_INFORMATION})
  set(RESULT_FILE CMakeSystemInformation.txt)
  include(SystemInformation)
endif(${SAVE_SYSTEM_INFORMATION})
