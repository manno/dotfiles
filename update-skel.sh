#!/bin/bash
# Description: helps updating skel directory and lists

set -e -o pipefail

print_existing_diff() {
  # find all files from . which changed in $HOME
  echo "# [ ] files from skel/ that changed in $HOME"
  cd skel
  find -L . -type f | \
    grep -v $0 | \
    grep -v '.gitkeep' | \
    sort | \
    ruby -ne '
    h=ENV["HOME"];f=$_.chomp.gsub(/\A\.\//,"");$_=%x(diff -q "#{f}" #{h}/#{f} 2>&1)
    p=ENV["PWD"].gsub(/#{h}/, "$HOME")
    if /differ/
      puts "vi -d skel/#{f} #{h}/#{f}"
    else
      l="ln -s #{p}/#{f} $HOME/#{f}"
      if /diff:.*#{h}.*: No such file/
        puts "# #{l}"
      else
        puts "# rm $HOME/#{f}; #{l}"
      end
    end
' | sort

  # | egrep -v 'vi -d (skel/.bash_profile|skel/.profile)'
}


print_existing_diff
