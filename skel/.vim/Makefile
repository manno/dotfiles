compile:
	# compile YouCompleteMe
	#cd bundle/YouCompleteMe && ./install.sh
	# compile Command-T
	bash -l -c 'rvm use system; cd plugged/command-t/ruby/command-t && ruby extconf.rb && make clean && make'

debian_dependencies:
	sudo apt-get install exuberant-ctags cscope
	# YouCompleteMe
	#sudo apt-get install build-essential cmake python-dev 
	# commandt
	sudo apt-get install ruby-dev
	# ag
	sudo apt-get install silversearcher-ag

backup:
	tar -cz --exclude ~/.vim/backups --exclude ~/.vim/spell --exclude ~/.vim/bundle --exclude ~/.vim/tmp -f ~/vimconf.release.tar.gz  ~/.vimrc ~/.vim

update_doc:
	vim +'helptags ~/.vim/doc'

fonts:
	mkdir -p ~/.config/fontconfig/conf.d/
	wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf -O ~/.config/fontconfig/conf.d/10-powerline-symbols.conf
	mkdir -p ~/.fonts
	wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf -O ~/.fonts/PowerlineSymbols.otf
	fc-cache -vf ~/.fonts

