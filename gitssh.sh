ssh-keygen -t ed25519

eval "$(ssh-agent -s)"

git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
