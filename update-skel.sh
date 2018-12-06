#!/bin/sh
# Description: helps updating skel directory and lists

set -e -o pipefail

print_new_files () {
  # add new files to installer
  echo "# [ ] new files in skel (not in lists/)"
  find skel -type f | sed 's/skel\///' | sort | while read f; do
    echo "$f" | egrep -q "\.gitkeep|.gitignore$" || (grep -q "^$f$" lists/*.lst || echo "$f")
  done
  echo
}

remove_old_files() {
  # remove old files from installer
  echo "# [ ] files no longer in skel, but in tarball lists/"
  for list in lists/install.lst lists/lite.lst; do
    grep -hv "^-" $list | while read f; do
      if [ ! -e skel/$f ]; then
        echo $list" -"$f
        perl -ni -e 'if (m@^'$f'$@) {  print "-".$_; } else { print $_; }' $list
      fi
    done
  done
  echo
}


print_existing_diff() {
  # find all files from . which changed in $HOME
  echo "# [ ] files from skel/ that changed in $HOME"
  cd skel
  find -L . -type f | \
    grep -v $0 | \
    grep -v '.gitkeep' | \
    sort | \
    ruby -ne 'h=ENV["HOME"];f=$_.chomp.gsub(/\A\.\//,"");$_=%x(diff -q "#{f}" #{h}/#{f} 2>&1);if /differ/; puts "vi -d skel/#{f} #{h}/#{f}"; elsif /diff:.*#{h}.*: No such file/; puts "cp skel/#{f} #{h}/#{f}"; end'

  # | egrep -v 'vi -d (skel/.bash_profile|skel/.profile)'
}


print_new_files
remove_old_files
print_existing_diff
# perl deploy.pl -D
