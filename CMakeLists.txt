cmake_minimum_required(VERSION 3.8)
project(YACC_C99)
include_directories(.)

find_program(LEX_EXE flex)
if (LEX_EXE STREQUAL "LEX_EXE-NOTFOUND")
    message(FATAL_ERROR "Install flex!")
endif (LEX_EXE STREQUAL "LEX_EXE-NOTFOUND")

find_program(YACC_EXE bison)
if (YACC_EXE STREQUAL "YACC_EXE-NOTFOUND")
    message(FATAL_ERROR "Install bison!")
endif (YACC_EXE STREQUAL "YACC_EXE-NOTFOUND")

# reuseable cmake macro for yacc
MACRO(YACC_FILE _filename)
    GET_FILENAME_COMPONENT(_basename ${_filename} NAME_WE)
    ADD_CUSTOM_COMMAND(
            OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${_basename}.cpp ${CMAKE_CURRENT_BINARY_DIR}/${_basename}.h
            COMMAND ${YACC_EXE} -d --output=${_basename}.cpp ${CMAKE_CURRENT_SOURCE_DIR}/${_filename})
ENDMACRO(YACC_FILE)

# reuseable cmake macro for lex
MACRO(LEX_FILE _filename)
    GET_FILENAME_COMPONENT(_basename ${_filename} NAME_WE)
    ADD_CUSTOM_COMMAND(
            OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${_basename}.c
            COMMAND ${LEX_EXE} -o${_basename}.cpp ${CMAKE_CURRENT_SOURCE_DIR}/${_filename})
ENDMACRO(LEX_FILE)

YACC_FILE(yacc.y)
LEX_FILE(lex.l)

add_executable(parser
        yacc.cpp
        lex.cpp
        )