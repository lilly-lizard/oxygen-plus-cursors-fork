macro(adjust in_size in_xhot in_yhot in_png)
   math(EXPR out_size "( ${in_size} * ${dpi} ) / 96")
   math(EXPR out_xhot "( ${in_xhot} * ${dpi} ) / 96")
   math(EXPR out_yhot "( ${in_yhot} * ${dpi} ) / 96")
   string(REPLACE ".png" "_${dpi}.png" out_png "${in_png}")
   set(out_line "${out_size} ${out_xhot} ${out_yhot} ${out_png} ${ARGN}")
   string(REPLACE ";" " " out_line "${out_line}")
   list(APPEND out_contents "${out_line}")
endmacro(adjust)

set(out_contents)
string(REPLACE " " ";" dpis "${dpis}")
foreach(dpi ${dpis})
   file(READ "${config}" in_contents)
   string(REPLACE "\n" ";" in_contents "${in_contents}")
   foreach(in_line ${in_contents})
      string(REGEX REPLACE "[ \t]+" ";" in_line "${in_line}")
      adjust(${in_line})
   endforeach(in_line)
endforeach(dpi)
string(REPLACE ";" "\n" out_contents "${out_contents}")
file(WRITE "${output}" "${out_contents}\n")
