set -l color00 '#382952'
set -l color01 '#F07178'
set -l color02 '#C2B8FF'
set -l color03 '#DDCCFF'
set -l color04 '#BB9AF7'
set -l color05 '#B49AE6'
set -l color06 '#A6B8FF'
set -l color07 '#DECCFF'
set -l color08 '#6B578F'
set -l color09 '#FF8A95'
set -l color0A '#B3A8F7'
set -l color0B '#D1BFF7'
set -l color0C '#CBA6F8'
set -l color0D '#C4AAF0'
set -l color0E '#C2CCFF'
set -l color0F '#C3AAF0'

set -l FZF_NON_COLOR_OPTS

for arg in (echo $FZF_DEFAULT_OPTS | tr " " "\n")
    if not string match -q -- "--color*" $arg
        set -a FZF_NON_COLOR_OPTS $arg
    end
end

set -Ux FZF_DEFAULT_OPTS "$FZF_NON_COLOR_OPTS"" --color=bg+:$color00,bg:$color00,spinner:$color0E,hl:$color0D"" --color=fg:$color07,header:$color0D,info:$color0A,pointer:$color0E"" --color=marker:$color0E,fg+:$color06,prompt:$color0A,hl+:$color0D"
