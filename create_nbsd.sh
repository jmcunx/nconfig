#!/bin/sh
#
# FOR NetBSD
#
# attached to a wireless network
# and will create/update /usr/local/bin/jmccue-custom.*
# on reboots
# that can be sourced in on login
#
# Copy to /usr/local/bin/create_obsd.sh
# and execute on reboot
#

f_make_login()
{
    l_ip="$1"

cat << EOF
#!/bin/csh
# Generated `date '+%Y-%m-%d %H:%M:%S'`
# by $sname
#

if ( ! "\`id -u\`" == "0" ) then
    if ( ! \$?USER ) then
        setenv USER "\`id -un\`"
    endif
    if ( -d /mnt/tmpfs ) then
        setenv TMPDIR /mnt/tmpfs/\$USER
    else
        setenv TMPDIR /tmp/\$USER
    endif
    if ( -d /mnt/mfs ) then
        setenv RAMDISK /mnt/mfs/\$USER
    else
        setenv RAMDISK /tmp/\$USER
    endif
    setenv TMP              \$TMPDIR
    setenv TEMP             \$TMPDIR
    setenv TEMPDIR          \$TMPDIR
    setenv TMUX_TMPDIR      \$TMPDIR
    setenv DISTRO           NetBSD
    setenv DOMAIN           jmcunx.com
    setenv HOST             $HOST
    setenv HOSTNAME         $HOST.$DOMAIN
    setenv OS               NetBSD
    setenv WORK_WORKSTATION NO
    if ( ! -d \$TMPDIR ) then
        mkdir \$TMPDIR >& /dev/null && chmod 700 \$TMPDIR
    endif
    if ( ! -d \$RAMDISK ) then
        mkdir \$RAMDISK >& /dev/null && chmod 700 \$RAMDISK
    endif
EOF
    if test "$l_ip" != ""
    then
        echo "    setenv IP               $l_ip"
    fi
    echo "endif"

} # END: f_make_login()

f_make_profile()
{
    l_ip="$1"
cat << EOF
#!/bin/sh
# Generated `date '+%Y-%m-%d %H:%M:%S'`
# by $sname
#

if test ! "\`id -u\`" = "0"
then
    case \$- in
        *i*)
            if test "\$USER" = ""
            then
                USER="\`id -un\`"
                export USER
            fi
            if test -d "/mnt/tmpfs"
            then
                TMPDIR="/mnt/tmpfs/\$USER"
            else
                TMPDIR="/tmp/\$USER"
            fi
            if test -d "/mnt/mfs"
            then
                RAMDISK="/mnt/mfs/\$USER"
            else
                RAMDISK="/tmp/\$USER"
            fi
            TMP=\$TMPDIR
            TEMP=\$TMPDIR
            TEMPDIR=\$TMPDIR
            TMUX_TMPDIR=\$TMPDIR
            export TMPDIR TMP TEMP TEMPDIR TMUX_TMPDIR RAMDISK
            DISTRO=NetBSD
            DOMAIN=jmcunx.com
            HOST=$HOST
            HOSTNAME=$HOST.$DOMAIN
            OS=NetBSD
            WORK_WORKSTATION=NO
            export DISTRO DOMAIN HOST HOSTNAME IP OS WORK_WORKSTATION
            if test ! -d "\$TMPDIR"
            then
                mkdir "\$TMPDIR" 2> /dev/null && chmod 700 "\$TMPDIR"
            fi
            if test ! -d "\$RAMDISK"
            then
                mkdir \$RAMDISK 2> /dev/null && chmod 700 \$RAMDISK
            fi
EOF

    if test "$l_ip" != ""
    then
        echo "            IP=$l_ip"
        echo "            export IP"
    fi
cat << EOF
            ;;
    esac
fi
EOF

} # END: f_make_profile()

f_generate()
{
    l_gen_wdev=""
    l_gen_wother=""
    l_gen_ip="UNKNOWN"
    l_gen_profile=""
    l_gen_login=""
    l_gen_now_fmt=`date '+%Y-%m-%d %H:%M:%S'`
    l_gen_ecode="0"

    case "$HOST" in
        "neutron")
            l_gen_wdev="iwn0"
            l_gen_wother="wm0"
            ;;
        *)
            echo "E003: $HOST not supported"
            return
            ;;
    esac

    if test "`id -u`" = "0"
    then
        l_gen_profile=/usr/local/bin/jmccue-custom.sh
        l_gen_login=/usr/local/bin/jmccue-custom.csh
    else
        if test -d "$TMPDIR"
        then
            l_gen_profile=$TMPDIR/jmccue-custom.sh
            l_gen_login=$TMPDIR/jmccue-custom.csh
        else
            l_gen_profile=$HOME/jmccue-custom.sh
            l_gen_login=$HOME/jmccue-custom.csh
        fi
    fi

    /sbin/ifconfig "$l_gen_wdev" > /dev/null 2>&1
    l_gen_ecode="$?"
    if test "$l_gen_ecode" -ne "0" -a "$l_gen_wother" != ""
    then
        l_gen_wdev="$l_gen_wother"
        /sbin/ifconfig "$l_gen_wdev" > /dev/null 2>&1
        l_gen_ecode="$?"
    fi
    if test "$l_gen_ecode" -eq "0"
    then
        l_gen_ip=`/sbin/ifconfig "$l_gen_wdev" | grep 'inet ' | head -n 1 | awk '{print $2}' | awk -F '/' '{print $1}'`
    fi

    f_make_login "$l_gen_ip"   > $l_gen_login
    /bin/chmod 644 "$l_gen_login"

    f_make_profile "$l_gen_ip" > $l_gen_profile
    /bin/chmod 644 "$l_gen_profile"

} # END: f_generate()

###############################################################################
# main
###############################################################################
sname="$0"

OS="`uname -s`"
HOST="`uname -n | awk -F '.' '{print $1}'`"
export OS HOST

if test "$OS" = "NetBSD"
then
    f_generate
else
    echo "E001: $OS not supported"
fi

### DONE, do not exit
