compile:
	# compile YouCompleteMe
	cd bundle/YouCompleteMe && ./install.sh
	cd bundle/vimproc.vim && make

update:
	nvim +BundleInstall
	cd ~/.nvim/bundle && git pull

install:
	git clone https://github.com/gmarik/vundle.git ~/.nvim/bundle/vundle
	nvim +BundleInstall

