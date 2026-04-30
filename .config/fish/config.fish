set -gx PATH $HOME/.local/bin /usr/local/bin /usr/bin /bin /usr/sbin /sbin $PATH /opt/cuda/bin

function fish_user_key_bindings

end

starship init fish | source
pyenv init --no-rehash - fish | source

function clear
    command clear
    if command -v fastfetch >/dev/null
        command fastfetch
    end
end

function cclear
    command clear
end

set -g fish_greeting

if status is-interactive
    ssh-add ~/.ssh/fxg4
    clear
end

fish_add_path /home/luna/.spicetify

# terminal-wakatime setup
set -gx PATH "$HOME/.wakatime" $PATH
terminal-wakatime init fish | source
