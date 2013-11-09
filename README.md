= Lite Mode =

Just unpack the important files.

Modify `lists/lite.lst`, run `make lite` and simply unpack the tarball on the target system.

= Installer Mode = 

The dotfiles are stored on github, but deployed to homedirs as plain files. No git checkout is created in the home directory.
The installer script supports merging of existing and removal of old files.

Modify `lists/install.lst` and `lists/delete.lst`, to remove files prepend them with a dash.

On the target system run `deploy.pl` to download the tarball from github and unpack it.

