## nconfig
My [NetBSD](https://www.netbsd.org/) specific objects
used to start/stop the system plus some additional Items.

License [unlicense](https://unlicense.org)

## bu\_vnstat.sh
To backup
[vnstat port](https://pkgsrc.se/net/vnstat)
databases on
[NetBSD](https://www.netbsd.org/).
I usually execute this in root's 
[crontab](https://man.netbsd.org/crontab.1)
once per week.

## create\_nbsd.sh
Generate custom settings that can be sourced in on user login.
This should be added root's
[crontab](https://man.netbsd.org/crontab.1)
to execute on reboot.

## dmesg\_t420.txt
[dmesg](https://man.netbsd.org/dmesg.8) for NetBSD 9.3 from
my ThinkPad T420.

## rc.conf
My [rc.conf](https://man.netbsd.org/rc.conf.5)
to start [NetBSD](https://www.netbsd.org/)
services.

## rc.local
My [rc.local](https://man.netbsd.org/rc.local.8),
main purpose is to create user specific
Temporary Directories (TMPDIR).
Users should add source files created by
[create\_nbsd.sh](https://github.com/jmcunx/nconfig/blob/main/create_nbsd.sh)
to their ~/.login, and/or ~/.shrc and/or ~/.profile
depending upon their shell.

## Other Comments
**[Support NetBSD](https://www.netbsd.org/donations/) or
[via github](https://github.com/sponsors/NetBSD)**
