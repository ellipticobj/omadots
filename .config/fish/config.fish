set -gx PATH $HOME/.local/bin /usr/local/bin /usr/bin /bin /usr/sbin /sbin $PATH

function fish_user_key_bindings

end

starship init fish | source
pyenv init - fish | source

function clear
    command clear
    if command -v fastfetch >/dev/null
        command fastfetch
    end
end

fish_config theme choose "Rosé Pine Dawn"
set -g fish_greeting

if status is-interactive
    clear
end

fish_add_path /home/luna/.spicetify
