#!/bin/ksh
#
# backup vnstat database in case of a crash
#        copy to /usr/local/bin/bu_vnstat.sh
# and add to root cron as
#    47 19 * * * /usr/local/bin/bu_vnstat.sh
# to backup the databases once per day
#
# change variable "g_dir_bhome" to the Directory where Backups
# will go
#

f_cpfile()
{
    l_cp_ifile="$1"
    l_cp_ofile="$2"

    if test ! -f "$l_cp_ifile"
    then
	return
    fi

    if test -f "$l_cp_ofile"
    then
	cmp "$l_cp_ofile" "$l_cp_ifile" > /dev/null 2>&1
	if test "$?" -eq "0"
	then
	    return
	fi
	if test ! -s "$l_cp_ifile"
	then
	    return
	fi
    fi

    logger "INFO vnstat b/u: Backing up $l_cp_ifile"
    cp "$l_cp_ifile" "$l_cp_ofile"
    chmod 640 "$l_cp_ofile"         > /dev/null 2>&1
    chown $g_owner:$g_group "$l_cp_ofile" > /dev/null 2>&1
    
} # END: f_cpfile()

f_bu_netbsd()
{
    if test "`id -u`" != "0"
    then
	return
    fi

    if test -d "$g_dir_vnstat" -a -d "$g_dir_bu"
    then
	f_cpfile "/usr/pkg/etc/vnstat.conf"  "$g_dir_bu/vnstat.conf.$HOST"
	/usr/sbin/service vnstatd status > /dev/null 2>&1
	l_rcvnstat="$?"
	if test "$l_rcvnstat" -eq "0"
	then
	    /usr/sbin/service vnstatd stop > /dev/null 2>&1
	fi
	sleep 1
	f_cpfile "$g_dir_vnstat/vnstat.db" "$g_dir_bu/vnstat.db.$HOST"
	f_cpfile "$g_dir_vnstat/em0"       "$g_dir_bu/em0.$HOST"
	f_cpfile "$g_dir_vnstat/enc0"      "$g_dir_bu/enc0.$HOST"
	f_cpfile "$g_dir_vnstat/iwn0"      "$g_dir_bu/iwn0.$HOST"
	f_cpfile "$g_dir_vnstat/iwm0"      "$g_dir_bu/iwm0.$HOST"
	f_cpfile "$g_dir_vnstat/pflog0"    "$g_dir_bu/pflog0.$HOST"
	f_cpfile "$g_dir_vnstat/tun0"      "$g_dir_bu/tun0.$HOST"
	f_cpfile "$g_dir_vnstat/bge0"      "$g_dir_bu/bge0.$HOST"
	f_cpfile "$g_dir_vnstat/ath0"      "$g_dir_bu/ath0.$HOST"
	f_cpfile "$g_dir_vnstat/wm0"       "$g_dir_bu/wm0.$HOST"
	if test "$l_rcvnstat" -eq "0"
	then
	    /usr/sbin/service vnstatd start > /dev/null 2>&1
	fi
    fi

} # END: f_bu_netbsd()

#
# main
#
OS=`uname -s`
HOST="`uname -n | awk -F '.' '{print $1}'`"
export OS HOST

g_dir_bhome=/u/BU
g_owner="jmccue"
g_group="jmccue"
g_dir_bu=$g_dir_bhome/$HOST/vnstat
g_dir_vnstat=/var/db/vnstat

case "$OS" in
    "NetBSD")
	f_bu_netbsd
	;;
    *)
	echo "E020: OS $OS not supported"
	;;
esac

exit 0
