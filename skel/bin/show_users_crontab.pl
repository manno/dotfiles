#!/usr/bin/perl
# Description: show all users crontabs

$cron='/usr/bin/crontab -l -u';
$pw_file='/etc/passwd';
open (INPW,"<$pw_file");

while (<INPW>)
{
	@zeile=split /:/;
	if ($zeile[0] ne '') {
		system "$cron $zeile[0]";
		#print $zeile[0] ."\n";
	}
}
close INPW;
