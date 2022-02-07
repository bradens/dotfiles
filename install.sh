#! /bin/sh

# Make a user bin directory
mkdir -p $HOME/.bin
export PATH=$PATH:$HOME/.bin

# # This is used later in the script for feedback
git clone --quiet https://github.com/molovo/revolver /tmp/revolver > /dev/null
chmod u+x /tmp/revolver/revolver
mv /tmp/revolver/revolver $HOME/.bin/
rm -rf /tmp/revolver

start(){
	revolver --style 'dots4' start "$1"
}

stop(){
	revolver stop
}

echo "Building environment. You must have already got a valid github ssh key."

start "Installing command line tools"
xcode-select --install
stop

start "Setting key repeat"
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)
defaults write -g InitialKeyRepeat -int 12 # normal minimum is 15 (225 ms)
stop

start "Remove the press and hold feature"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
stop

start "Install homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
stop

start "install everything from our Brewfile"
brew bundle
stop

echo "FZF install"
/opt/homebrew/opt/fzf/install

start "install ruby"
rbenv install 3.0.2
stop

start "Link skhd"
ln -s ./.skhdrc ~/.skhdrc
stop

start "Install oh my zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
stop

start "Installing rosetta"
softwareupdate --install-rosetta
stop

start "Install tunnelblick (manual), hit enter to open https://tunnelblick.net/"
read
open https://tunnelblick.net/
echo "Hit enter when finished"
read
stop

echo "Provide your 1password login domain (*.1password.com)"
read domain

echo "Provide your 1password login email"
read email

echo "Sign in to 1password cli"
eval $(op signin $domain $email)

start "Setup secrets file"
npm_token=$(op get item "GitHub package token" | jq -r '.details.sections[0].fields[0].v')

cat >$HOME/.secretsrc <<EOF
export GITHUB_NPM_TOKEN=$npm_token
EOF

stop

start "Setup aws credentials file"

production_aws_access_key_id=$(op get item "aws prod" | jq -r '.details.sections[0].fields[0].v')
production_aws_secret_access_key=$(op get item "aws prod" | jq -r '.details.sections[0].fields[1].v')
staging_aws_access_key_id=$(op get item "aws staging" | jq -r '.details.sections[0].fields[0].v')
staging_aws_secret_access_key=$(op get item "aws staging" | jq -r '.details.sections[0].fields[1].v')
dev_aws_access_key_id=$(op get item "aws dev" | jq -r '.details.sections[0].fields[1].v')
dev_aws_secret_access_key=$(op get item "aws dev" | jq -r '.details.sections[0].fields[2].v')

cat >$HOME/.aws/credentials-test <<EOF
[dev]
aws_access_key_id=$dev_aws_access_key_id
aws_secret_access_key=$dev_aws_secret_access_key

[staging]
aws_access_key_id=$staging_aws_access_key_id
aws_secret_access_key=$staging_aws_secret_access_key

[production]
aws_access_key_id=$production_aws_access_key_id
aws_secret_access_key=$production_aws_secret_access_key
EOF

stop

start "Add gitconfig, zshrc, skhdrc"
ln -sf $(pwd)/.gitconfig ~/.gitconfig
ln -sf $(pwd)/.zshrc ~/.zshrc
ln -sf $(pwd)/.skhdrc ~/.skhdrc
stop
