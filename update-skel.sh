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
    ruby -ne 'h=ENV["HOME"];f=$_.chomp.gsub(/\A\.\//,"");$_=%x(diff -q "#{f}" #{h}/#{f} 2>&1);if /differ/; puts "vi -d skel/#{f} #{h}/#{f}"; elsif /diff:.*#{h}.*: No such file/; puts "cp skel/#{f} #{h}/#{f}"; end'

  # | egrep -v 'vi -d (skel/.bash_profile|skel/.profile)'
}


print_existing_diff
