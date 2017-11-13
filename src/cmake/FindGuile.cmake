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
  IF(NOT _return_VALUE)

    EXECUTE_PROCESS(COMMAND ${GUILECONFIG_EXECUTABLE}  link 
      OUTPUT_VARIABLE _guileconfig_link )
    
    EXECUTE_PROCESS(COMMAND ${GUILECONFIG_EXECUTABLE}  compile 
      OUTPUT_VARIABLE _guileconfig_compile )

    EXECUTE_PROCESS(COMMAND ${GUILECONFIG_EXECUTABLE}  info libdir 
      OUTPUT_VARIABLE _guileconfig_libdir )


    EXECUTE_PROCESS(COMMAND ${GUILECONFIG_EXECUTABLE}  "--version"
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
    set(Guile_LIBRARIES ${_guile_libraries})
    set(Guile_CFLAGS ${_guile_definitions_with_prefix})
    set(Guile_LIBDIR )
    if(_guileconfig_libdir)
      string(STRIP ${_guileconfig_libdir} Guile_LIBDIR)
    endif(_guileconfig_libdir)

    MESSAGE(">>>" "${Guile_INCLUDE_DIRS}")
    MESSAGE(">>>" "${Guile_LIBRARIES}")
    MESSAGE(">>>" "${Guile_CFLAGS}")
    MESSAGE(">>>" "${_guileconfig_version}")
    MESSAGE(">>>" "${Guile_LIBDIR}")

  ELSE( NOT _return_VALUE)

    MESSAGE(STATUS "guile-config not working; I assume guile is not installed.")

  ENDIF(NOT _return_VALUE)

ELSE(GUILECONFIG_EXECUTABLE)

    MESSAGE(STATUS "guile-config not found; I assume guile is not installed.")


ENDIF(GUILECONFIG_EXECUTABLE)

