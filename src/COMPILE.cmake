To compile with cmake, on MacOS, using MacPorts:

  sudo port install qt5 cmake ... (and other prerequisites)

  mkdir build
  cd build
  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_INSTALL_PREFIX=/opt/local -DCMAKE_VERBOSE_MAKEFILE=OFF -DCMAKE_INSTALL_SYSCONFDIR=/opt/local/etc -DCMAKE_INSTALL_LOCALSTATEDIR=/opt/local/var -DTEXMACS_GUI=Qt5 -DTRY_GUILE18_CONFIG_FIRST=ON -DGUILE_HEADER_18=ON ..
  make -j
  sudo make install

To compile with cmake, on Ubuntu or Debian:

  cd packages/debian
  ln -s rules.cmake rules
  cd ../..
  ln -s packages/debian .
  fakeroot debian/rules clean binary

