#!/bin/bash

if test $(uname) = 'Linux'; then
    sudo apt-get install rubygems1.8
fi

sudo gem install interactive_editor
sudo gem install rails
sudo gem install wirble
sudo gem install plist
sudo gem install pry
sudo gem install pry-doc
sudo gem install rubygems-test

