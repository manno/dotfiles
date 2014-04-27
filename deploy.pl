#!/usr/bin/perl
# Description: download tarball, filelists, unpack files from list into home dir
# Version: 0.7.github

use strict;
use warnings;
use feature ':5.10';

use POSIX qw(strftime);
use File::Path;
use File::Basename;
use File::Temp qw/tempdir/;
use Digest::MD5;
use Getopt::Std;

=head1 GLOBALS

=cut

my $DEPLOY_SCRIPT_PATH = 'raw/master/deploy.pl';
my $FILELISTS_PATH = 'raw/master/lists';
my $TARBALL_PATH = 'archive';
my $PATCH_PATH = 'raw/master/patches';

# Config
my $dir_prefix = $ENV{'HOME'};
my $hostname = $ENV{'HOST'} || `/bin/hostname`;
chomp $hostname;
my $master_url = 'http://github.com/manno/dotfiles';
my $master_tarball = 'master.tar.gz';
my @master_lists = qw/install.lst delete.lst/;
my $backupdir = '.backup';
my $tar_cmd = '/bin/tar';
my $patch = '/usr/bin/patch';
my $patchlevel = '0';
my $cmd;

# Command line options
our ($opt_h, $opt_i, $opt_u, $opt_d, $opt_p, $opt_m, $opt_g, $opt_v, $opt_U, $opt_D);

=head1 FUNCTIONS

=cut

sub check_available_downloaders {
    my $opt_m = shift;
    my $cmd;
    if ($opt_m) { 
        if    ($opt_m =~ /lwp/i) { eval "require LWP::UserAgent"; $cmd = LWP::UserAgent->new(); }
        elsif ($opt_m =~ /wget/i) { $cmd = `which wget`; chomp $cmd; }
        elsif ($opt_m =~ /curl/i) { $cmd = `which curl`; chomp $cmd; }
        else { die "download method $opt_m not found"; }
        say "using $cmd"; 
    } else {
        # detection
        if ($cmd = `which wget`) {
            chomp $cmd;
            say "using $cmd";
        } elsif (eval "require LWP::UserAgent") {
            $cmd = LWP::UserAgent->new();
            say "using LWP::UserAgent";
        } elsif ($cmd = `which curl`) {
            chomp $cmd;
            say "using $cmd";
        } 
    }
    return $cmd;
}

sub http_get { 
    my ($url) = @_;
    if (ref $cmd eq 'LWP::UserAgent') {
        my $req = HTTP::Request->new(GET => "$url");
        my $res = $cmd->request($req);

        if ($res->is_success()) {
            return $res->content;
        }
        print "error: ".$res->status_line.", ";
        return;

    } elsif ($cmd =~ m/curl$/) {
        return `$cmd -s "$url"`;

    } elsif ($cmd =~ m/wget$/) {
        return `$cmd -q "$url" -O -`;

    } else {
        die "No way to retrieve files, please install either LWP, curl or wget";
    }
}

sub update_deploy_script {
    my $data = http_get( "$master_url/$DEPLOY_SCRIPT_PATH" );
    open my $fh, '>', 'deploy.pl';
    print $fh $data;
    close $fh;
    say "wrote deploy.pl";
}

sub get_dotfiles {
    my @files_get;
    my @files_del;
    for my $listfile (@master_lists) {
        # get and parse file
        say "[+] Loading file list $master_url/$FILELISTS_PATH/$listfile";
        my $data = http_get( "$master_url/$FILELISTS_PATH/$listfile" );
        if (not $data) {
            warn "not found '$listfile'";
        } else {
            for (split /\n/,$data) {
                if (m/^\-(.*)/) {
                    push @files_del, $1;
                } else {
                    push @files_get, $_;
                }
            }
        }
    }
    return { delete_list => \@files_del, get_list => \@files_get };
}

sub backup_existing_dotfiles {
    my $dotfiles = shift;
    my $files = join( ' ', @{$dotfiles->{get_list}}, @{$dotfiles->{delete_list}} );
    say "[+] Backup all old files in $backupdir";
    mkdir ($backupdir) if (not -d $backupdir);
    my $date = strftime '%Y%m%d%H%M', localtime;
    `$tar_cmd --exclude=.vim/backups --exclude=.vim/tmp -czf $backupdir/$date.dotfiles.tar.gz $files 2>&1 > /dev/null`;
}

sub delete_dotfiles {
    my @files = @_;
    say "[+] Delete all old files";
    for (@files) {
        if (-e "$_") {
            say "delete $_" if $opt_v;
            unlink "$_";
        } elsif (-d "$_") {
            # TODO remove dirs
            warn "failed to remove $_ (NOT IMPLEMENTED)";
        }
    }
}

# unpack wanted files from tarball to destination
sub unpack_dotfiles {
    my $target_dir = shift;
    my $tarcontent = shift;
    my $list = shift;
    my $files = join( ' ', map { 'dotfiles-master/skel/'.$_ } @{$list});
    open my $fh, "|$tar_cmd -C $target_dir --strip-components=2 -x".$opt_v."z -f - $files 2>/dev/null" or 
        die "error opening $tar_cmd: $!";
    print $fh $tarcontent;
    close $fh;
}

sub md5file {
    my $file = shift;
    die "error with $file" if (not $file or not -r $file or not -f $file);
    open my $fh, $file or die "Can't open '$file': $!";
    binmode($fh);
    return Digest::MD5->new->addfile($fh)->hexdigest;
}

sub update_dotfiles {
    my ($tarcontent, $dotfiles) = @_;

    my $dir = tempdir( DIR => $dir_prefix, CLEANUP => 1 );
    say "using temporary directory $dir" if $opt_v;
    unpack_dotfiles( $dir, $tarcontent, $dotfiles );

    for my $file (@{$dotfiles}) {
        next unless -e "$dir/$file";
        if (-f "$dir_prefix/$file") {
            if (md5file( "$dir_prefix/$file" ) ne md5file( "$dir/$file" )) {
                my $choice = '';
                while ($choice !~ m/^[cneq]$/) {
                    say "\n[ +++ ] New version of $file available";
                    say "Action: <c>opy, <n>ext, <d>how diff, <e>dit in vimdiff, <q>uit program";
                    print "Enter choice and press return: ";
                    $choice = getc;
                    getc;
                    chomp $choice;
                    if ($choice eq 'd') {
                        system('diff', '-up', "$dir_prefix/$file", "$dir/$file");
                        $choice = '';
                    }
                }
                if ($choice eq 'c') {
                    system('cp', "$dir/$file", "$dir_prefix/$file");
                } elsif ($choice eq 'n') {
                    say "skipping $file";
                } elsif ($choice eq 'e') {
                    system('vimdiff', "$dir_prefix/$file", "$dir/$file");
                } elsif ($choice eq 'q') {
                    exit 1;
                }
            }
        } else {
            if (-l "$dir_prefix/$file") {
                say "removing symlink $file" if $opt_v;
                unlink("$dir_prefix/$file");
            }
            # new files in new directories need to be deployed on updates too
            my $target_dir = dirname "$dir_prefix/$file";
            if (! -d $target_dir) {
              mkpath($target_dir);
            }
            system('cp', '-r', "$dir/$file", "$dir_prefix/$file");
        }
    }
}

sub diff_dotfiles {
    my ($tarcontent, $dotfiles) = @_;

    say "=============== begin diff mode (local -> tarball)";
    say "[+] Unpacking files to temp dir" if $opt_v;
    my $dir = tempdir( DIR => $dir_prefix, CLEANUP => 1 );
    say "using temporary directory $dir" if $opt_v;
    unpack_dotfiles( $dir, $tarcontent, $dotfiles->{get_list} );

    my @new_files;
    my @changed_files;
    for my $file (@{$dotfiles->{get_list}}) {
        next unless -e "$dir/$file";
        if (-f "$dir_prefix/$file") {
            if (md5file( "$dir_prefix/$file" ) ne md5file( "$dir/$file" )) {
                system('diff', '-up', "$dir_prefix/$file", "$dir/$file");
                push @changed_files, $file;
            }
        } elsif (not -e "$dir_prefix/$file") {
            push @new_files, $file;
        }
    }

    for my $file (@new_files) {
        say "Only in tarball: $file";
    }

    for my $file (@{$dotfiles->{delete_list}}) {
        next unless -e "$dir_prefix/$file";
        say "Only in local dir: $file";
    }

    say 'for f in '.join(' ', @changed_files).'; do vimdiff $HOME/$f $SKEL/$f; done' if ($#changed_files > 0);

}

# check if a patch file exists for this host and get/apply it
sub apply_host_patch {
    say "[+] Loading host ($hostname) specific patch\n";
    my $data = http_get( "$master_url/$PATCH_PATH/d.$hostname.patch" );
    # 404 FIXME

    if ($data and $data =~ /---/) {
        open my $fh, "|$patch -p$patchlevel";
        print $fh $data;
        close $fh;
    }
}

sub print_usage_and_exit {
    say "usage: deploy.pl [-h] [-v] [-p lists] [-m method] [-U url] [-d dir] [-i|-u|-g|-D]";
    say '    -i         : install dotfiles';
    say '    -u         : update already deployed machine using vimdiff';
    say '    -D         : diff current dotfiles against tarball';
    say '    -g         : get a fresh deploy script';
    say '';
    say "    -d dir     : target dir ($dir_prefix)";
    say "    -U url     : source url ($master_url)";
    say "    -p lists   : lists to use (". join(',', @master_lists) .")";
    say '    -m method  : download method (lwp, wget or curl)';
    say "    -v         : verbose\n";
    say 'i.e:';
    say '    deploy.pl -u';
    say '    deploy.pl -m wget -d "otherhome/"';
    say '    deploy.pl -p install.lst,delete.lst"';
    exit 0;
}

=head1 COMMAND LINE INITIALIZATION

=cut

$opt_v = '';
$opt_u = 1;
getopts('hd:U:m:Dugv');
print_usage_and_exit if $opt_h; 

$opt_u = 0 if $opt_i or $opt_i or $opt_g or $opt_D;
$opt_v = 'v' if $opt_v;
$master_url = $opt_U if $opt_U;
$dir_prefix = $opt_d if $opt_d;

if ($opt_p) {
    @master_lists = split (/,/, $opt_p);
    say "fetching [@master_lists]";
}

# initialization
chdir( $dir_prefix );

# how to get files: wget,libwww-perl,curl
$cmd = check_available_downloaders;

=head1 MAIN


=cut

# update infrastructure
if ($opt_g) {
    update_deploy_script;
    exit 0;
}

# build file list and tarball
my $dotfiles = get_dotfiles;

say "[+] Loading deploy tarball";
my $tarcontent = http_get( "$master_url/$TARBALL_PATH/$master_tarball" );
die "not found '$master_tarball'" unless $tarcontent;

##############################
if ($opt_u) {
    # update and diff
    backup_existing_dotfiles( $dotfiles );
    delete_dotfiles( @{$dotfiles->{delete_list}} );
    say "[+] Updating files";
    update_dotfiles( $tarcontent, $dotfiles->{get_list} );
    say "";
    apply_host_patch;

} elsif ($opt_D) { 
    diff_dotfiles( $tarcontent, $dotfiles );

} elsif ($opt_i) {
    # unpack wanted files from tarball to correct destination -C /home/user/
    backup_existing_dotfiles( $dotfiles );
    delete_dotfiles( @{$dotfiles->{delete_list}} );
    say "[+] Unpack new files";
    unpack_dotfiles( $dir_prefix, $tarcontent, $dotfiles->{get_list} );
    say "";
    apply_host_patch;
} else {
    print_usage_and_exit;
}

# vim: set ts=4 sw=4:
