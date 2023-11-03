cd $HOME
sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended &> /dev/null
mv zshrc .zshrc
echo "exec `which zsh`" > .ashrc

