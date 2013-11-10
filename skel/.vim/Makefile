install:
	vim -c ":BundleInstall" -c ":qa" 
	# compile YouCompleteMe
	cd bundle/YouCompleteMe && ./install.sh
	# compile Command-T
	cd bundle/command-t/ruby/command-t && rvm use system && ruby extconf.rb && make clean && make

debian_dependencies:
	sudo apt-get exuberant-ctags cscope
	# YouCompleteMe
	sudo apt-get install build-essential cmake python-dev 
	# commandt
	sudo apt-get ruby-dev

backup:
	tar -cz --exclude ~/.vim/backups --exclude ~/.vim/spell --exclude ~/.vim/bundle --exclude ~/.vim/tmp -f ~/vimconf.release.tar.gz  ~/.vimrc ~/.vim

update_doc:
	vim -c ":helptags ~/.vim/doc" -c ":q" 

vundle_clean:
	vim -c ":BundleClean L9" -c ":qa" 
