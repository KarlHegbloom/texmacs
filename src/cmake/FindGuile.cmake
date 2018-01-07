# - Locate the GNU Guile library
# Once done, this will define
#
#  Guile_FOUND - system has Guile
#  Guile_INCLUDE_DIRS - the Guile include directories
#  Guile_LIBRARIES - link these to use Guile
#  Guile_VERSION_STRING - version of Guile

option(TRY_GUILE18_CONFIG_FIRST "Try guile18-config before guile-config" ON)
option(GUILE_HEADER_18 "<libguile18.h>" ON)

if(TRY_GUILE18_CONFIG_FIRST)
  find_program(GUILECONFIG_EXECUTABLE NAMES guile18-config guile-config guile22-config)
else(TRY_GUILE18_CONFIG_FIRST)
  find_program(GUILECONFIG_EXECUTABLE NAMES guile-config guile22-config guile18-config)
endif(TRY_GUILE18_CONFIG_FIRST)

# if guile-config has been found
IF(GUILECONFIG_EXECUTABLE)

  EXECUTE_PROCESS(COMMAND ${GUILECONFIG_EXECUTABLE} link 
    OUTPUT_VARIABLE _guileconfigDevNull RESULT_VARIABLE _return_VALUE  )

  # and if the package of interest also exists for guile-config, then
  # get the information
  if(NOT _return_VALUE)

    #  -pthread  -lguile -lltdl -lgmp -lcrypt -lm -lltdl
    execute_process(COMMAND ${GUILECONFIG_EXECUTABLE}  link
      OUTPUT_VARIABLE _guileconfig_link )

    # -pthread
    execute_process(COMMAND ${GUILECONFIG_EXECUTABLE}  compile
      OUTPUT_VARIABLE _guileconfig_compile )

    execute_process(COMMAND ${GUILECONFIG_EXECUTABLE}  info libguileinterface # = 21:0:4
      OUTPUT_VARIABLE _guileconfig_libguileinterface )

    execute_process(COMMAND ${GUILECONFIG_EXECUTABLE}  info guileversion # = 1.8.8
      OUTPUT_VARIABLE _guileconfig_guileversion )

    execute_process(COMMAND ${GUILECONFIG_EXECUTABLE}  info pkgincludedir # = /usr/include/guile
      OUTPUT_VARIABLE _guileconfig_pkgincludedir )

    execute_process(COMMAND ${GUILECONFIG_EXECUTABLE}  info pkglibdir # = /usr/lib/guile
      OUTPUT_VARIABLE _guileconfig_pkglibdir )

    execute_process(COMMAND ${GUILECONFIG_EXECUTABLE}  info pkgdatadir # = /usr/share/guile
      OUTPUT_VARIABLE _guileconfig_pkgdatadir )

    execute_process(COMMAND ${GUILECONFIG_EXECUTABLE}  info includedir # = /usr/include
      OUTPUT_VARIABLE _guileconfig_includedir )

    execute_process(COMMAND ${GUILECONFIG_EXECUTABLE}  info libdir # = /usr/lib
      OUTPUT_VARIABLE _guileconfig_libdir )

    execute_process(COMMAND ${GUILECONFIG_EXECUTABLE}  "--version"
      OUTPUT_VARIABLE _guileconfig_version ERROR_VARIABLE _guileconfig_version )
    
  
    
    ## parsing
    STRING(REGEX MATCHALL "[-][L]([^ ;])+" _guile_libdirs_with_prefix "${_guileconfig_link}" )
    STRING(REGEX MATCHALL "[-][l]([^ ;])+" _guile_libraries_with_prefix "${_guileconfig_link}" )
    STRING(REGEX MATCHALL "[-][I]([^ ;])+" _guile_includes_with_prefix "${_guileconfig_compile}" )
    STRING(REGEX MATCHALL "[-][D]([^ ;])+" _guile_definitions_with_prefix "${_guileconfig_compile}" )
    STRING(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" Guile_VERSION_STRING "${_guileconfig_version}")
      
    STRING(REPLACE "-L" " " _guile_libdirs ${_guile_libdirs_with_prefix} "")
    STRING(REPLACE "-l" " " _guile_lib_list "${_guile_libraries_with_prefix}" )
    STRING(REPLACE "-I" " " _guile_includes "${_guile_includes_with_prefix}" )
    #    SEPARATE_ARGUMENTS(_guile_libdirs)

    # MESSAGE(STATUS ${_guile_libraries_with_prefix})
    SET(_guile_libraries "")

    FOREACH(i ${_guile_lib_list})
      STRING(STRIP ${i} i)
      IF (i)
        IF(NOT _guile_flag_library_${i}) # avoid copies
          find_library(_guile_tmp_library_${i}
            NAMES ${i}
            PATHS ${_guile_libdirs}
           )
         #  MESSAGE(STATUS ">>>>>>>>>" ${_guile_tmp_library_${i}})
          IF(_guile_tmp_library_${i})   
            SET(_guile_flag_library_${i})
            SET(_guile_libraries ${_guile_libraries} ${_guile_tmp_library_${i}})
          ENDIF(_guile_tmp_library_${i})
        ENDIF(NOT _guile_flag_library_${i}) 
      ENDIF (i)
    ENDFOREACH(i)

    set(Guile_FOUND YES)
    set(Guile_INCLUDE_DIRS ${_guile_includes})
    set(Guile_LIBRARIES    ${_guile_libraries})
    set(Guile_CFLAGS       ${_guile_definitions_with_prefix})
    set(guileconfig_version)
    if(_guileconfig_version)
      string(STRIP ${_guileconfig_version} guileconfig_version)
    endif(_guileconfig_version)
    set(Guile_LIBDIR)
    if(_guileconfig_libdir)
      string(STRIP ${_guileconfig_libdir} Guile_LIBDIR)
    endif(_guileconfig_libdir)

    MESSAGE(STATUS "-- Guile_FOUND          : ${Guile_FOUND}")
    MESSAGE(STATUS "-- Guile_INCLUDE_DIRS   : ${Guile_INCLUDE_DIRS}")
    MESSAGE(STATUS "-- Guile_LIBRARIES      : ${Guile_LIBRARIES}")
    MESSAGE(STATUS "-- Guile_CFLAGS         : ${Guile_CFLAGS}")
    MESSAGE(STATUS "-- guileconfig_version  : ${guileconfig_version}")
    MESSAGE(STATUS "-- Guile_LIBDIR         : ${Guile_LIBDIR}")

  ELSE( NOT _return_VALUE)

    MESSAGE(STATUS "guile-config not working; I assume guile is not installed.")

  ENDIF(NOT _return_VALUE)

ELSE(GUILECONFIG_EXECUTABLE)

    MESSAGE(STATUS "guile-config not found; I assume guile is not installed.")


ENDIF(GUILECONFIG_EXECUTABLE)

