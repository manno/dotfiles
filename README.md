.dotfiles
========

Install
--------------

   chezmoi init manno
   chezmoi git -- remote set-url origin --push git@github.com:manno/dotfiles.git


Migrate
--------------

   cd
   chezmoi managed | while read f; do [ -f "$f" ] && chezmoi add --follow "$f"; done
   chezmoi managed | while read f; do [ -f "$f" ] && diff "$f" <(chezmoi cat "$f"); done
   chezmoi git status
