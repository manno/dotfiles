#!/bin/sh
# Description: helps updating skel directory and lists

print_new_files () {
  # add new files to installer
  echo "# [ ] new files in skel"
  find skel -type f | sed 's/skel\///' | while read f; do 
    echo "$f" | egrep -q "\.gitkeep|.gitignore$" || (grep -q "^$f$" lists/*.lst || echo "$f") 
  done
  echo
}

remove_old_files() {
  # remove old files from installer
  echo "# [ ] files no longer in skel"
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
  echo "# [ ] files from skel that changed in home"
  cd skel
  find . -type f | grep -v $0 | while read f; do diff -q $f ~/$f > /dev/null 2>&1 || echo vimdiff skel/$f ~/$f; done
}


print_new_files
remove_old_files
print_existing_diff
