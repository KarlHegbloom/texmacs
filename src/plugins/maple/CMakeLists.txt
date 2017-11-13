set (maple_SRCS src/tm_maple_5.cpp)

include_directories(${TEXMACS_SOURCE_DIR}/TeXmacs/include ${TEXMACS_BINARY_DIR}/src/System)

add_executable (tm_maple_5 ${maple_SRCS})

install(TARGETS tm_maple_5 DESTINATION share/TeXmacs/plugins/maple/bin)
