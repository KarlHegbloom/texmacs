/* src/System/config.h.cmake
*/

/* Enable experimental Cocoa port */
#cmakedefine AQUATEXMACS 1

/* check assertions in code */
#cmakedefine DEBUG_ASSERT 1

/* debugging build */
#cmakedefine DEBUG_ON 1

/* Defined if ...-style argument passing works */
#cmakedefine DOTS_OK 1

/* Enable experimental style rewriting code */
#cmakedefine EXPERIMENTAL 1

/* gs path relative to TEXMACS_PATH */
#cmakedefine GS_EXE "@GS_EXE@"

/* gs fonts */
#cmakedefine GS_FONTS "@GS_FONTS@"

/* gs lib */
#cmakedefine GS_LIB "@GS_LIB@"

/* Guile version */
#cmakedefine GUILE_A 1

/* Guile version */
#cmakedefine GUILE_B 1

/* Guile version */
#cmakedefine GUILE_C 1

/* Guile version */
#cmakedefine GUILE_D 1

/* Guile 1.6 header */
#cmakedefine GUILE_HEADER_16 1

/* Guile 1.8 header */
#cmakedefine GUILE_HEADER_18 1

/* Guile version */
#cmakedefine GUILE_VERSION @GUILE_VERSION@

/* Define to 1 if the system has the type `FILE'. */
#cmakedefine HAVE_FILE 1

/* Define to 1 if you have the `gettimeofday' function. */
#cmakedefine HAVE_GETTIMEOFDAY 1

/* Define to 1 if the system has the type `intptr_t'. */
#cmakedefine HAVE_INTPTR_T 1

/* Define to 1 if you have the <inttypes.h> header file. */
#cmakedefine HAVE_INTTYPES_H 1

/* Define to 1 if you have the <memory.h> header file. */
#cmakedefine HAVE_MEMORY_H 1

/* Define to 1 if you have the <pty.h> header file. */
#cmakedefine HAVE_PTY_H 1

/* Define if the Qt framework is available. */
#cmakedefine HAVE_QT 1

/* Define to 1 if you have the <stdint.h> header file. */
#cmakedefine HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#cmakedefine HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#cmakedefine HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#cmakedefine HAVE_STRING_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#cmakedefine HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#cmakedefine HAVE_SYS_TYPES_H 1

/* Define to 1 if the system has the type `time_t'. */
#cmakedefine HAVE_TIME_T 1

/* Define to 1 if you have the <unistd.h> header file. */
#cmakedefine HAVE_UNISTD_H 1

/* Define to 1 if you have the <util.h> header file. */
#cmakedefine HAVE_UTIL_H 1

/* Define to 1 if you have the <X11/Xlib.h> header file. */
#cmakedefine HAVE_X11_XLIB_H 1

/* Define to 1 if you have the <X11/Xutil.h> header file. */
#cmakedefine HAVE_X11_XUTIL_H 1

/* Link axel library with TeXmacs */
#cmakedefine LINKED_AXEL 1

/* Link cairo library with TeXmacs */
#cmakedefine LINKED_CAIRO 1

/* Link freetype library with TeXmacs */
#cmakedefine LINKED_FREETYPE 1

/* Link imlib2 library with TeXmacs */
#cmakedefine LINKED_IMLIB2 1

/* Link sqlite3 library with TeXmacs */
#cmakedefine LINKED_SQLITE3 1

/* Enabling Mac OSX extensions */
#cmakedefine MACOSX_EXTENSIONS 1

/* Disable fast memory allocator */
#cmakedefine NO_FAST_ALLOC 1

/* Use g++ strictly prior to g++ 3.0 */
#cmakedefine OLD_GNU_COMPILER 1

/* OS type */
#cmakedefine OS_CYGWIN 1

/* OS type */
#cmakedefine OS_DARWIN 1

/* OS type */
#cmakedefine OS_FREEBSD 1

/* OS type */
#cmakedefine OS_GNU_LINUX 1

/* OS type */
#cmakedefine OS_IRIX 1

/* OS type */
#cmakedefine OS_MACOS 1

/* OS type */
#cmakedefine OS_MINGW 1

/* OS type */
#cmakedefine OS_POWERPC_GNU_LINUX 1

/* OS type */
#cmakedefine OS_SOLARIS 1

/* OS type */
#cmakedefine OS_SUN 1

/* Define to the address where bug reports for this package should be sent. */
#cmakedefine PACKAGE_BUGREPORT "@PACKAGE_BUGREPORT@"

/* Define to the full name of this package. */
#cmakedefine PACKAGE_NAME "@PACKAGE_NAME@"

/* Define to the full name and version of this package. */
#cmakedefine PACKAGE_STRING "@PACKAGE_STRING@"

/* Define to the one symbol short name of this package. */
#cmakedefine PACKAGE_TARNAME "@PACKAGE_TARNAME@"

/* Define to the home page for this package. */
#cmakedefine PACKAGE_URL "@PACKAGE_URL@"

/* Define to the version of this package. */
#cmakedefine PACKAGE_VERSION "@PACKAGE_VERSION@"

/* Disable DCT */
#cmakedefine PDFHUMMUS_NO_DCT 1

/* Disable Tiff Format */
#cmakedefine PDFHUMMUS_NO_TIFF 1

/* Enabling native PDF renderer */
#cmakedefine PDF_RENDERER 1

/* Enabling Qt pipes */
#cmakedefine QTPIPES 1

/* Enable experimental Qt port */
#cmakedefine QTTEXMACS 1

/* The size of `void *', as computed by sizeof. */
#cmakedefine SIZEOF_VOID_P @SIZEOF_VOID_P@

/* Define to 1 if you have the ANSI C header files. */
#cmakedefine STDC_HEADERS 1

/* Dynamic linking function name */
#cmakedefine TM_DYNAMIC_LINKING @TM_DYNAMIC_LINKING@

/* Use axel library */
#cmakedefine USE_AXEL 1

/* Use cairo library */
#cmakedefine USE_CAIRO 1

/* Use freetype library */
#cmakedefine USE_FREETYPE 1

/* Use ghostscript */
#cmakedefine USE_GS 1

/* Use iconv library */
#cmakedefine USE_ICONV 1

/* Use imlib2 library */
#cmakedefine USE_IMLIB2 1

/* Use Sparkle framework */
#cmakedefine USE_SPARKLE 1

/* Use sqlite3 library */
#cmakedefine USE_SQLITE3 1

/* Use C++ stack backtraces */
#cmakedefine USE_STACK_TRACE 1

/* Use standard X11 port */
#cmakedefine X11TEXMACS 1

/* Define to 1 if the X Window System is missing or not being used. */
#cmakedefine X_DISPLAY_MISSING 1

/* Guile string size type */
#cmakedefine guile_str_size_t @guile_str_size_t@


/* extras not found in config.in ??? */
#cmakedefine HAVE_LT_DLLOADER_H 1
#cmakedefine HAVE_LT_MODULE_OPEN 1
#cmakedefine HAVE_DLFCN_H 1

#cmakedefine SCM_SIZET @SCM_SIZET@
#cmakedefine GUILE_NUM @GUILE_NUM@

#cmakedefine MACOS_QT_MENU @MACOS_QT_MENU@
