#break main
#run localhost

set pagination 0

# use base16
set radix 16

# debug gnome-vfs-*
#handle SIG33 nostop noprint

# debug mono
handle SIGPWR nostop noprint 
handle SIGXCPU nostop noprint 

define pregs
    printf "eax      0x%0.8x   % 0.10d              ebx      0x%0.8x   % 0.10d\n", $eax, $eax, $ebx, $ebx
    printf "ecx      0x%0.8x   % 0.10d              edx      0x%0.8x   % 0.10d\n", $ecx, $ecx, $edx, $edx
    printf "ebp      0x%0.8x   % 0.10d               es      0x%0.4x   fs  0x%0.4x   gs  0x%0.4x\n", $ebp, $ebp, $es, $fs, $gs
    printf "esp      0x%0.8x   % 0.10d               ss      0x%0.4x\n", $esp, $esp, $ss
    printf "esi      0x%0.8x   % 0.10d               ds      0x%0.4x\n", $esi, $esi, $ds
    printf "eip      0x%0.8x   % 0.10d               cs      0x%0.4x\n", $eip, $eip, $cs
    printf "edi      0x%0.8x   % 0.10d\n", $edi, $edi
    printf "eflags   %d %d %d %d %d %d %d %d %d %d %d %d %d %d | %d %d %d %d %d %d %d %d\n", ($eflags & (1<<21)) > 0, ($eflags & (1<<20)) > 0, ($eflags & (1<<19)) > 0,  ($eflags & (1<<18)) > 0,  ($eflags & (1<<17)), ($eflags & (1<<16)) > 0,  ($eflags & (1<<15)) > 0,  ($eflags & (1<<14)) > 0,  ($eflags & (1<<13)) > 0, ($eflags & (1<<12)) > 0,  ($eflags & (1<<11)) > 0,  ($eflags & (1<<10)) > 0, ($eflags & (1<<9)) > 0, ($eflags & (1<<8)) > 0, ($eflags & (1<<7)) > 0, ($eflags & (1<<6)) > 0, ($eflags & (1<<5)) > 0, ($eflags & (1<<4)) > 0, ($eflags & (1<<3)) > 0, ($eflags & (1<<2)) > 0, ($eflags & (1<<1)) > 0, ($eflags & (1<<0)) > 0
    printf "         I V V A V R - N I I O D I T | S Z - A - P - C\n"
    printf "         D I I C V R   T P P F F F F | F F   F   F   F\n"
    printf "           P F   M F     L L         |\n"
end

define w
    x/8i $pc
end

define stack
    x/8x $esp
end

define btall
    thread apply all bt full
end

define mono_stack
 set $mono_thread = mono_thread_current ()
 if ($mono_thread == 0x00)
   printf "No mono thread associated with this thread\n"
 else
   set $ucp = malloc (sizeof (ucontext_t))
   call (void) getcontext ($ucp)
   call (void) mono_print_thread_dump ($ucp)
   call (void) free ($ucp)
 end
end
