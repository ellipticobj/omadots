set -gx PATH $HOME/.local/bin /usr/local/bin /usr/bin /bin /usr/sbin /sbin $PATH /opt/cuda/bin $HOME/.cargo/bin

function fish_user_key_bindings

end

starship init fish | source
zoxide init fish --cmd cd | source

function clear
    command clear
    if command -v fastfetch >/dev/null
        command fastfetch
    end
end

function cclear
    command clear
end

alias ls="cats"
alias cat="cats"
alias lls="command ls"
alias ccat="command cat"

alias python="uv run python"

set -e FZF_DEFAULT_OPTS
set -gx FZF_DEFAULT_OPTS " --color=bg+:#333333,bg:#333333,spinner:#868686,hl:#7c7c7c --color=fg:#cccccc,header:#7c7c7c,info:#5e5e5e,pointer:#868686 --color=marker:#868686,fg+:#6f6f6f,prompt:#5e5e5e,hl+:#7c7c7c"
set -Ux FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS"

set -g fish_greeting

if status is-interactive
    ssh-add ~/.ssh/fxg4
    clear
end

fish_add_path /home/luna/.spicetify

# terminal-wakatime setup
set -gx PATH "$HOME/.wakatime" $PATH
terminal-wakatime init fish | source
