#!/usr/bin/env zsh

echo 'Update submodules'
echo '-----------------'
git submodule update --init --recursive

echo 'Install oh-my-zsh'
echo '-----------------'
rm -rf $HOME/.oh-my-zsh
curl -L https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

echo "Install xcode-select"
echo '--------------------'
sudo xcode-select --install > /dev/null 2>&1

echo 'Install homebrew'
echo '----------------'
sudo rm -rf /opt/local/Cellar /opt/local/.git && brew cleanup
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

echo 'Install NVM'
echo '-----------'
brew uninstall --ignore-dependencies node 
brew uninstall --force node 
brew install nvm 
nvm install node
nvm install 12
nvm install 14
nvm install 16
nvm use 16

echo 'Configure npm'
echo '-------------'
npm config set prefix "${HOME}/.npm-packages"


echo 'Install php'
echo '-----------'
brew tap shivammathur/php
brew install shivammathur/php/php@5.6
brew install shivammathur/php/php@7.4
brew install shivammathur/php/php@8.1
brew link --overwrite --force php@8.1

echo 'Install composer'
echo '----------------'
EXPECTED_COMPOSER_CHECKSUM="$(curl https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_COMPOSER_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
if [ "$EXPECTED_COMPOSER_CHECKSUM" != "$ACTUAL_COMPOSER_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
    exit 1
fi
php composer-setup.php
rm composer-setup.php
sudo mv composer.phar /opt/local/bin/composer

echo 'Install laravel valet'
echo '---------------------'
composer global require laravel/valet
valet install

echo 'Install all the brew stuff'
echo '=========================='

echo 'Install some nice quicklook plugins'
echo '-----------------------------------'
brew install --cask qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzip  suspicious-package

echo 'Install iTerm2'
echo '--------------'
brew install --cask iterm2

echo 'Install vim'
echo '-----------'
brew install vim

echo 'Install tree'
echo '------------'
brew install tree

echo 'Install node'
echo '------------'
brew install node

echo 'Install pkg-config'
echo '------------------'
brew install pkg-config

echo 'Install wget'
echo '------------'
brew install wget

echo 'Install httpie'
echo '--------------'
brew install httpie

echo 'Install ncdu'
echo '------------'
brew install ncdu

echo 'Install hub'
echo '-----------'
brew install hub

echo 'Install ack'
echo '-----------'
brew install ack

echo 'Install doctl'
echo '-------------'
brew install doctl

brew install jq

brew install sqlmap

brew install rsync

brew install s3cmd

brew install supervisor

echo 'Install imagemagick'
echo '-------------------'
brew install imagemagick

echo 'Install imagick'
echo '---------------'
pecl install imagick

echo 'Install memcached'
echo '-----------------'
pecl install memcached

echo 'Install xdebug'
echo '--------------'
pecl install xdebug

echo 'Install redis'
echo '-------------'
pecl install redis

echo 'Install mysql'
echo '-------------'
brew install mariadb
brew services start mariadb

echo 'Install yarn'
echo '------------'
brew install yarn

echo 'Install zsh-autosuggestions, syntax-highlighting and completions'
echo '---------------------------'
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install zsh-completions
brew install zsh-vi-mode

echo 'Install Fira Code Font'
echo '----------------------'
brew install font-fira-Code

brew install phpmon

echo 'Install Bind'
echo '------------'
brew install bind

echo 'Install ansible'
echo '---------------'
brew install ansible

echo 'Install awscli'
echo '--------------'
brew install awscli

brew install curl

brew cleanup

echo '++++++++++++++++++++++++++++++'
echo 'All done!'
echo 'Put your custom aliases, exports and functions in .dotfiles-custom/shell'
echo '++++++++++++++++++++++++++++++'
