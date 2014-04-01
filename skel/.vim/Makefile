install:
	mv ~/.vim/bundle/vundle /tmp
	git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
	vim -c ":BundleInstall" -c ":qa" 
	# compile YouCompleteMe
	cd bundle/YouCompleteMe && ./install.sh
	# compile Command-T
	rvm use system --default
	cd bundle/command-t/ruby/command-t && ruby extconf.rb && make clean && make

debian_dependencies:
	sudo apt-get install exuberant-ctags cscope
	# YouCompleteMe
	sudo apt-get install build-essential cmake python-dev 
	# commandt
	sudo apt-get install ruby-dev

backup:
	tar -cz --exclude ~/.vim/backups --exclude ~/.vim/spell --exclude ~/.vim/bundle --exclude ~/.vim/tmp -f ~/vimconf.release.tar.gz  ~/.vimrc ~/.vim

update_doc:
	vim -c ":helptags ~/.vim/doc" -c ":q" 

vundle_clean:
	vim -c ":BundleClean" -c ":qa" 
