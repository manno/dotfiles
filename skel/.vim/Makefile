install:
	vim -c ":BundleInstall" -c ":qa" 
	# compile YouCompleteMe
	cd bundle/YouCompleteMe && ./install.sh
	# compile Command-T
	# sudo apt-get install ruby-dev 
	cd bundle/command-t/ruby/command-t && rvm use system && ruby extconf.rb && make clean && make

backup:
	tar -cz --exclude ~/.vim/backups --exclude ~/.vim/spell --exclude ~/.vim/bundle --exclude ~/.vim/tmp -f ~/vimconf.release.tar.gz  ~/.vimrc ~/.vim

update_doc:
	vim -c ":helptags ~/.vim/doc" -c ":q" 

update20131027:
	rm ~/.vim/plugin/{fuzzyfinder.vim,fuzzyfinder_textmate.vim,minibufexpl.vim,bufgrep.vim} ~/.vim/ruby/fuzzy_file_finder.rb ~/.vimfuzzyfinder
	vim -c ":BundleClean L9" -c ":qa" 

update20131101:
	rm ~/vim/plugin/IndentAnything.vim ~/vim/indent/IndentAnything_html.vim
	rm  ~/.vim/doc/taglist.txt ~/.vim/plugin/taglist.vim
	rmdir ~/vim/ruby
	# update config/vundle.vim with IndentAnything
