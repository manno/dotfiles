.dotfiles
========

Lite Mode
---------

Just unpack the important files.

Modify `lists/lite.lst`, run `make lite` and simply unpack the tarball on the target system.

Installer Mode
--------------

The dotfiles are stored on github, but deployed to homedirs as plain files. No git checkout is created in the home directory.
The installer script supports merging of existing and removal of old files.

Modify `lists/install.lst` and `lists/delete.lst`, to remove files prepend them with a dash.

On the target system run `deploy.pl` to download the tarball from github and unpack it.

### Usage

    deploy.pl [-h] [-v] [-p lists] [-m method] [-U url] [-d dir] [-u|-g|-D]
        -u         : update already deployed machine using vimdiff
        -D         : diff current dotfiles against tarball
        -g         : get a fresh deploy script

        -d dir     : target dir (/home/user)
        -U url     : source url (http://github.com/manno/dotfiles)
        -m method  : download method (lwp, wget or curl)
        -v         : verbose

### Examples

    deploy.pl -u
    deploy.pl -m wget -d "test"
