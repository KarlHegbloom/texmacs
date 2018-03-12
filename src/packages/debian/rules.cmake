#!/usr/bin/make -f
# -*- makefile -*-

BUILD_DIR := obj-$(shell dpkg-architecture -qDEB_BUILD_GNU_TYPE)

export DH_VERBOSE := 1

ifdef $(DH_VERBOSE)
  _CMAKE_VERBOSE_MAKEFILE_ := -DCMAKE_VERBOSE_MAKEFILE=ON
else
  _CMAKE_VERBOSE_MAKEFILE_ := -DCMAKE_VERBOSE_MAKEFILE=OFF
endif

CMAKE_OPTS :=					\
  -DCMAKE_EXPORT_COMPILE_COMMANDS=1		\
  $(_CMAKE_VERBOSE_MAKEFILE_)			\
  -DCMAKE_INSTALL_PREFIX=/usr			\
  -DCMAKE_INSTALL_SYSCONFDIR=/etc		\
  -DCMAKE_INSTALL_LOCALSTATEDIR=/var		\
  -DCMAKE_INSTALL_RUNSTATEDIR=/run		\
  -DTRY_GUILE18_CONFIG_FIRST=ON			\
  -DGUILE_HEADER_18=OFF				\
  -DTEXMACS_GUI=Qt5				\
  -DDISABLE_FASTALLOC=ON


%: debian/BUILD_DIR-stamp ${BUILD_DIR}/Makefile debian/changelog debian/control
	dh $@ --parallel --buildsystem=cmake --builddirectory=${BUILD_DIR}


debian/BUILD_DIR-stamp:
	mkdir -p ${BUILD_DIR}
	touch $@

${BUILD_DIR}/Makefile debian/changelog debian/control: debian/BUILD_DIR-stamp
	(cd ${BUILD_DIR} && cmake ${CMAKE_OPTS} ..)
	touch debian/changelog
	touch debian/control
	touch ${BUILD_DIR}/Makefile


override_dh_update_autotools_config override_dh_autoreconf override_dh_autoreconf_clean override_dh_auto_configure override_dh_strip:
  :

override_dh_auto_clean:
	rm -rf ${BUILD_DIR}
	rm -f debian/BUILD_DIR-stamp
