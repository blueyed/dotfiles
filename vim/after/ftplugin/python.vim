" Sort Python imports.
command! -range=% -nargs=* Isort :<line1>,<line2>! cd %:h 2>/dev/null >&2; isort --lines 79 <args> -
command! -range=% -nargs=* Isortdiff :<line1>,<line2>w !cd %:h 2>/dev/null >&2; isort --lines 79 --diff <args> -
