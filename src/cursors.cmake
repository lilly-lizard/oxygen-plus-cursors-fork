macro(add_cursor cursor color theme dpi)
    add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/oxy-${theme}/svg/${cursor}_${dpi}.svg
                       DEPENDS ${MAKE_SVG} ${CMAKE_CURRENT_SOURCE_DIR}/colors.in ${SVGDIR}/${cursor}.svg
                       COMMAND ${CMAKE_COMMAND} -Dconfig=${CMAKE_CURRENT_SOURCE_DIR}/colors.in
                                                -Dinput=${SVGDIR}/${cursor}.svg
                                                -Doutput=${CMAKE_BINARY_DIR}/oxy-${theme}/svg/${cursor}_${dpi}.svg
                                                -P ${MAKE_SVG}
                      )
    add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/oxy-${theme}/png/${cursor}_${dpi}.png
                       DEPENDS ${CMAKE_BINARY_DIR}/oxy-${theme}/svg/${cursor}_${dpi}.svg
                       COMMAND ${INKSCAPE} --without-gui --export-dpi=${dpi}
                                           --export-png=${CMAKE_BINARY_DIR}/oxy-${theme}/png/${cursor}_${dpi}.png
                                           ${CMAKE_BINARY_DIR}/oxy-${theme}/svg/${cursor}_${dpi}.svg
                      )
endmacro(add_cursor)

macro(add_x_cursor theme cursor dpis)
    set(inputs)
    foreach(dpi ${dpis})
        foreach(png ${${cursor}_inputs})
            string(REPLACE ".png" "_${dpi}.png" png "${png}")
            list(APPEND inputs ${CMAKE_BINARY_DIR}/oxy-${theme}/png/${png})
        endforeach(png)
    endforeach(dpi)
    add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/oxy-${theme}/config/${cursor}.in
                       DEPENDS ${MAKE_CONFIG} ${CONFIGDIR}/${cursor}.in
                       COMMAND ${CMAKE_COMMAND} -Dconfig=${CONFIGDIR}/${cursor}.in
                                                -Doutput=${CMAKE_BINARY_DIR}/oxy-${theme}/config/${cursor}.in
                                                -Ddpis="${dpis}"
                                                -P ${MAKE_CONFIG}
                      )
    add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/oxy-${theme}/cursors/${cursor}
                       DEPENDS ${inputs} ${CMAKE_BINARY_DIR}/oxy-${theme}/config/${cursor}.in
                       COMMAND ${XCURSORGEN} -p ${CMAKE_BINARY_DIR}/oxy-${theme}/png
                                             ${CMAKE_BINARY_DIR}/oxy-${theme}/config/${cursor}.in
                                             ${CMAKE_BINARY_DIR}/oxy-${theme}/cursors/${cursor}
                      )
endmacro(add_x_cursor)

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/packages)
macro(add_theme color theme dpis)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/oxy-${theme}/png)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/oxy-${theme}/svg)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/oxy-${theme}/config)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/oxy-${theme}/cursors)
    set(${theme}_cursors)
    foreach(dpi ${dpis})
        foreach(svg ${SVGS})
            string(REGEX REPLACE ".*/" "" cursor ${svg})
            string(REGEX REPLACE "[.]svg" "" cursor ${cursor})
            add_cursor(${cursor} ${color} ${theme} ${dpi})
        endforeach(svg)
    endforeach(dpi)
    foreach(cursor ${CURSORS})
        add_x_cursor(${theme} ${cursor} "${dpis}")
        list(APPEND ${theme}_cursors ${CMAKE_BINARY_DIR}/oxy-${theme}/cursors/${cursor})
    endforeach(cursor)
    foreach(link ${LINKS})
        file(READ "${link}" link_to)
        string(REGEX REPLACE ".*/" "" cursor ${link})
        string(REGEX REPLACE "[.]link" "" cursor ${cursor})
        add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/oxy-${theme}/cursors/${cursor}
                           DEPENDS ${link}
                           COMMAND ${LN} -sf ${link_to} ${CMAKE_BINARY_DIR}/oxy-${theme}/cursors/${cursor}
                          )
        list(APPEND ${theme}_cursors ${CMAKE_BINARY_DIR}/oxy-${theme}/cursors/${cursor})
    endforeach(link)
    add_custom_target(theme-${theme} ALL DEPENDS ${${theme}_cursors})
    add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/oxy-${theme}/index.theme
                       DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/index.theme
                       COMMAND ${CMAKE_COMMAND} -E copy_if_different
                                                   ${CMAKE_CURRENT_SOURCE_DIR}/index.theme
                                                   ${CMAKE_BINARY_DIR}/oxy-${theme}/index.theme
                      )
    add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/packages/oxy-${theme}.tar.bz2
                       DEPENDS ${${theme}_cursors} ${CMAKE_BINARY_DIR}/oxy-${theme}/index.theme
                       COMMAND ${TAR} cjf ${CMAKE_BINARY_DIR}/packages/oxy-${theme}.tar.bz2
                                      oxy-${theme}/cursors
                                      oxy-${theme}/index.theme
                       WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                      )
    add_custom_target(package-${theme} DEPENDS ${CMAKE_BINARY_DIR}/packages/oxy-${theme}.tar.bz2)
endmacro(add_theme)
