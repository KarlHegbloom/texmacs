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
  -DTRY_GUILE18_CONFIG_FIRST=ON			\
  -DGUILE_HEADER_18=OFF				\
  -DTEXMACS_GUI=Qt5

# -DCMAKE_BUILD_TYPE=RelWithDebInfo

%: cmake debian/changelog debian/control
	dh --parallel --buildsystem=cmake $@

cmake:
	(mkdir ${BUILD_DIR}; \
	 cd ${BUILD_DIR};     \
	 cmake ${CMAKE_OPTS} ..)

debian/changelog:
	cp $@.in $@
	touch $@.in

debian/control:
	cp $@.in $@
	touch $@.in


override_dh_update_autotools_config:
	:

override_dh_auto_configure: cmake
	:

override_dh_strip:
	:

.PHONY: cmake
