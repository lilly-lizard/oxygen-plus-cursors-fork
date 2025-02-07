find_program(TAR tar)
# TODO abort if tar not found (or does not understand cjf?)

find_program(INKSCAPE inkscape)
# TODO abort if inkscape not found

find_program(XCURSORGEN xcursorgen)
# TODO abort if xcursorgen not found

find_program(LN ln)

macro(set_dependencies cursor)
    file(READ ${CONFIGDIR}/${cursor}.in config_contents)
    string(REPLACE "\n" ";" config_contents ${config_contents})
    set(${cursor}_inputs)
    foreach(png ${config_contents})
        string(REGEX REPLACE "[0-9]* [0-9]* [0-9]* " "" png ${png})
        string(REGEX REPLACE "[.]png [0-9]*$" ".png" png ${png})
        list(APPEND ${cursor}_inputs ${png})
    endforeach(png)
endmacro(set_dependencies)

set(CURSORS)
foreach(config ${CONFIGS})
    string(REGEX REPLACE ".*/" "" cursor ${config})
    string(REGEX REPLACE "[.]in" "" cursor ${cursor})
    list(APPEND CURSORS ${cursor})
    set_dependencies(${cursor})
endforeach(config)
