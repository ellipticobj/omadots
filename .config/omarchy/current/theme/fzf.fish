set -l color00 '#F5E6D3'
set -l color01 '#a02b16'
set -l color02 '#b76e79'
set -l color03 '#644535'
set -l color04 '#AD9980'
set -l color05 '#b76e81'
set -l color06 '#3b3b28'
set -l color07 '#DEA193'
set -l color08 '#6F4C3E'
set -l color09 '#a02b16'
set -l color0A '#b76e79'
set -l color0B '#694C45'
set -l color0C '#AD9980'
set -l color0D '#b76e81'
set -l color0E '#3b3b28'
set -l color0F '#DEA193'

set -l FZF_NON_COLOR_OPTS

for arg in (echo $FZF_DEFAULT_OPTS | tr " " "\n")
    if not string match -q -- "--color*" $arg
        set -a FZF_NON_COLOR_OPTS $arg
    end
end

set -Ux FZF_DEFAULT_OPTS "$FZF_NON_COLOR_OPTS"" --color=bg+:$color00,bg:$color00,spinner:$color0E,hl:$color0D"" --color=fg:$color07,header:$color0D,info:$color0A,pointer:$color0E"" --color=marker:$color0E,fg+:$color06,prompt:$color0A,hl+:$color0D"
