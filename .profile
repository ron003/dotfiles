:
#   $RCSfile: .profile,v $
#   $Revision: 1.129 $
#   $Date: 2025/08/22 21:21:33 $
if [ -z "${sourced_time_profile_frst-}" ];then
    sourced_time_profile_frst=`date +%Y-%m-%d_%H:%M:%S.%N_%Z`
    sourced_time_profile_last=$sourced_time_profile_frst
    sourced_time_profile_cnt=1
else
    sourced_time_profile_last=`date +%Y-%m-%d_%H:%M:%S.%N_%Z`
    sourced_time_profile_cnt=$((sourced_time_profile_cnt+1))
fi
if [ "${ENVONLY:-}" = 1 -a "${XUSERFILESEARCHPATH:-}" != "" ];then
    if expr "${XUSERFILESEARCHPATH:-}" : "$HOME/.desktop-`hostname`" >/dev/null;then
	: #do nothing
    else
	XUSERFILESEARCHPATH=$HOME/.desktop-`hostname`/%N:${XUSERFILESEARCHPATH:-}
    fi
fi

export BASH_SILENCE_DEPRECATION_WARNING=1 # For mac os x big sur.

# make undefined vars behave as in csh
#set -u
#important to use full paths here b/c I might be sourcing this b/c I've lost
#my path
#THIS FILE DOESN'T GET SOURCED DURING 'rsh <command>' SO WHY HAVE echo_ok??
echo_ok=""
if [ -f /bin/tty ] && /bin/tty -s; then
    echo_ok=1
elif [ -f /usr/bin/tty ] && /usr/bin/tty -s; then
    echo_ok=1
fi
#if test -f /usr/bin/tty && /usr/bin/tty -s ; then echo_ok=1 ; fi
if [ $echo_ok ];then
    echo "executing .profile - pwd=`pwd`"
fi

#if [ \! -f /etc/profile ];then
#    # Ignore keyboard interrupts.
#    trap ""  2 3
#        # Allow the user to break the Message-Of-The-Day only.
#        trap "trap '' 2"  2
#        cat -s /etc/motd
#        trap "" 2
#    trap  2 3
#fi

#LANG=en; export LANG  # circa 2007 (for kek systems (error msgs)) Ref. man -a locale
#LANG=C; export LANG  # 2013.05.15 linux-3.7.1 kernel build (perl) complains if LANG=en
#LC_ALL=C; export LC_ALL  # for perl at kek 2007-10-05
# 2015.11.20 try not setting LANG,LC_ALL; 2016/04/19 try setting LANG;
# 2018/09/15 not setting (see cvs log)
# 2020-08-01 trying LANG strip UTF-8 (again)
# 2020-08-24 UTF-8 stripped incompatible with Fedora28 "terminal-server"  Maybe do if interactive??
#test -n "$LANG" && LANG=`echo "$LANG" |sed -e 's/\.UTF-8//'` # adding -u8 to xterm doesn't seem to work; see comment above
case `hostname` in
    ronlap77) :;; # 2021-03-26 setting LC_ALL=C seems to cause sort change (separate Upper/lower case) in evolution folders listing
    *)  :;; #LC_ALL=C; export LC_ALL;;
esac

MYHOME=`echo ~ron`
test "$MYHOME" = '~ron' && MYHOME=`/bin/csh -fc "echo ~ron" 2>/dev/null`
if [ \( "$MYHOME" = "" -o ! -d "$MYHOME" \) -a -d /home/ron ];then MYHOME=/home/ron; fi
if [ "$MYHOME" = "" ];then
    # incase no /bin/csh (pxelinux_initramfs.sh system) and sh is bash
    myhome=`sh -c 'echo ~ron'`
    test "$myhome" = '~ron' || MYHOME="$myhome"
fi
test -n "$MYHOME" || MYHOME=$HOME
if   [ -f $MYHOME/.bashrc ];then BASHRC=$MYHOME/.bashrc
elif [ -f .bashrc         ];then BASHRC=.bashrc;  fi

CDPATH=.:..:$MYHOME:$MYHOME/work2:$MYHOME/work
export CDPATH MYHOME
export ETHERMAC_ERE='84.5C.31.34.A1.E0|00.30.93.12.42.17|FC.4C.EA.F6.62.EF|40.D1.33.98.77.86|FC.4C.EA.FB.ED.AE'
#MAILCHECK=120;export MAILCHECK	#don't know if needs export, don't fully understand
#SHACCT=$HOME/.shacct; export SHACCT	# for use with acctcom
NNTPSERVER=fnnews.fnal.gov; export NNTPSERVER;#needed for (network) news reading

if [ ! "${default_path-}" ];then
    default_path=$PATH; export default_path
else
    non_default_path=$PATH
    PATH=$default_path	# for when path is messed up and we re-source
    # it's OK if there was extra stuff, just not OK if key components were
    # missing. Put extra stuff back
    for pp in `echo $non_default_path | sed -e 's/:/ /g'`;do
        if echo :$PATH: | grep ":$pp:" >/dev/null;then : OK;else
            test -d "$pp" && PATH=$PATH:$pp
        fi
    done
fi
if   [ ! -r $MYHOME/.nofermi -a -r /usr/local/etc/fermi.profile -a "${ENVONLY:-}" != 1 ];then
    expr "$-" : '.*u' >/dev/null && set +u && setu=1 || setu=
    . /usr/local/etc/fermi.profile
    test -n "$setu" && set -u; unset setu
#    export FERMI_PROFILE_HAS_RUN=T
    export default_fermi_path; default_fermi_path=$PATH
fi

umask 002

# the next line is suggested by the tset man page
if [ "$echo_ok" -a ! "${TERM:-}" ]; then echo '$TERM not set'; fi
#if [ "${TERM:-}" ]; then TERM=vt220; fi # `less` messes up with this
if [ "$echo_ok" ]; then
    echo ".profile: changing TERM=\"$TERM\" to vt100"
    mesg y 	# could also do chmod u+x `tty`
fi
#TERM=vt100   2019-10-10 trying to get tmux mouse copy/paste to work

CVS_RSH=ssh; export CVS_RSH

# SHOULD THIS BE IN .BASHRC???
#if [ !"${SSH_AUTH_SOCK-}" ];then
#    echo Doing ssh stuff...
#    eval `ssh-agent`
#    ssh-add
#fi
sshreagent(){
  test -n "$SSH_AGENT_PID" && return
  psaux=`ps aux`
  if agentpid=`echo "$psaux" | awk '/ron .*ssh-agent/{print$2;xx=1;exit} END{exit !xx}'`;then
    export SSH_AGENT_PID=$agentpid
    socknum=`expr $agentpid - 1`
    export SSH_AUTH_SOCK=`echo /tmp/ssh-*/agent.$socknum`   # shell glob
  else
    eval `ssh-agent`; : ssh-add  # ssh-add should/may ask for password - do it manually
  fi
}
sshreagent

remove_dups() # <var> [sep]
{
    rd_silent=0
    rd_report_only=0
    while test $# -gt 0; do
        case "$1" in
        -s) rd_silent=1;shift;;
        -r) rd_report_only=1;shift;;
        *) break
        esac
    done
    test $# -eq 0 && { echo "usage: remove_dups <va> [sep]"; echo example: remove_dups PATH; return; }
    test $# -eq  2 && rd_sep=$2 || rd_sep=:
    rd_vnam=$1
    eval rd_xx=\"\$$rd_vnam\"
    rdp=
    rd_duplicates=0
    rd_ifs_sav="$IFS"
    IFS=$rd_sep
    for rdi in $rd_xx;do IFS="$rd_ifs_sav"
        if [ "$rdp" = "" ];then rdp=$rdi; continue; fi
        if expr ":$rdp:" : ".*:$rdi:" >/dev/null; then
            if [ $rd_silent = 0 ];then echo "$0: duplicate in $rd_vnam removed: $rdi">&2;fi
            rd_duplicates=1
        else
            rdp="$rdp:$rdi"
        fi
    done
    if [ $rd_silent = 0 -a $rd_duplicates = 0 ];then echo "$0: $rd_vnam no dups" >&2; fi
    test $rd_report_only = 0 && eval $rd_vnam=\"$rdp\"
    unset rdi rdp rd_vnam rd_xx rd_sep
    unset rd_silent rd_report_only rd_duplicates
    unset rd_ifs_sav
}

fix_path()
{
    silent=
    report_only=0
    for i in ${*-}; do
        case $i in
        -s) silent=1;;  -r) report_only=1;;  -net) no_net=1;;
        *)  echo "$0: usage: fix_path [-s] [-r] [-net] # -s for silent; -r for report only; -net for remove">&2
            return;;
        esac
    done
    p=
    duplicates=0
    if [ "${no_net-}" ];then mpts=`awk '{print $2;}' /proc/mounts | sort -u`; fi
    remove_dups ${silent:+-s} PATH
    t="$IFS"
    IFS=":"   # Note: allow components with " ". (I can put back IFS anytime after 'for')
    for i in $PATH;do IFS="$t"
        if [ "$i" = "" ];then
            if [ -z "$silent" ];then echo "$0: \"\" in PATH removed">&2;fi
            duplicates=1
            continue;
        fi
        if [ "${no_net-}" ];then
            mp_net=
            for mp in $mpts;do
                #i_resolved=`cd $i;pwd`
                if expr "$i" : "$mp" >/dev/null;then
                    if grep ":.* $mp " /proc/mounts >/dev/null;then
                        mp_net=$mp;break
                    fi
                fi
            done
            if [ "$mp_net" ];then
                if [ -z "$silent" ];then echo "$0: mp_net=$mp_net";fi
                continue
            fi
        fi
        if [ ! -d "$i" ];then
            if [ -z "$silent" ];then echo "$0: non-existant directory $i removed">&2;fi
            duplicates=1
            continue;
        fi
        if [ "$p" = "" ];then p=$i; continue; fi
        p="$p:$i"
    done
    IFS="$t"
    p=`echo "$p" | sed -e 's/^\.://;s/:\.:/:/g;s/:\.$//'`
    if [ -z "$silent" -a "$PATH" != "$p" ];then echo "$0: components removed" >&2; fi
    if [ $report_only = 0 ];then PATH="$p";fi
    if [ "${no_net-}" ];then
        ld_l=
        IFS=":" # Note: allow components with " ". (I can put back IFS anytime after 'for')
        for i in ${LD_LIBRARY_PATH-};do IFS="$t"
            mp_net=
            for mp in $mpts;do
                #i_resolved=`cd $i;pwd`
                if expr "$i" : "$mp" >/dev/null;then
                    if grep ":.* $mp " /proc/mounts >/dev/null;then
                        mp_net=$mp;break
                    fi
                fi
            done
            if [ "$mp_net" ];then continue;fi
            ld_l="${ld_l:+$ld_l:}$i"
        done
        IFS="$t"   # in case LD_LIBRARY_PATH is null
        if [ -z "$silent" -a "$ld_l" = "${LD_LIBRARY_PATH-}" ];then
            echo "$0: LD_LIBRARY_PATH ok (no net)" >&2
        else
            echo "$0: LD_LIBRARY_PATH has net paths" >&2
        fi
        if [ $report_only = 0 -a "${LD_LIBRARY_PATH-}" ];then LD_LIBRARY_PATH="$ld_l";fi
    fi
    unset i p unset silent report_only mpts no_net ld_l t
}

set_path()
{
    fix_path -s "$@"  # to help some versions of expr AND set_path cannot handle dups
    # from petravick's .profile:
    # The removal of ':' from the end of this path is quite necessary.
    # (A null element of PATH is equivalent to the current directory, '.')
    # The removal closes an otherwise bad security breach.
    PATH=`echo $PATH | sed -e 's/^://' -e 's/:$//' -e "s/:\.//g" -e "s/\.://g" -e "s/::/:/g"`
    # place some at beginning...
    for i in \
             `/bin/ls -d /usr/lib*/qt*/bin 2>/dev/null| tail -1` \
             $HOME/bin \
             $MYHOME/bin \
             $MYHOME/bin.`uname` \
             /usr/ucb \
             /usr/kerberos/bin \
             /usr/krb5/bin \
             /usr/local/bin \
             /usr/local/sbin \
             /opt/*/bin \
             /opt2/SUNWspro/bin \
             /opt2/sbin \
             $MYHOME/script \
             $MYHOME/.local/bin \
             ; do
        # Place : at beginning and end to enable exact path search (even at ends)
        if [ -d $i ];then
            #before=`expr :$PATH: : ":\(.*\):$i:"`
            before=`echo ":$PATH:" | sed -n -e "\|:$i:|{s|:$i:.*||;s/^://;p;}"`
            if [ "$before" ];then
                #aft=`expr :$PATH: : ".*:$i:\(.*\):"`
                aft=`echo ":$PATH:" | sed -e "s|.*:$i:||" -e 's/:$//'`
                PATH=$i:$before${aft:+:$aft}   # aft might be ""
            else
                PATH=$i:$PATH
            fi
        fi
    done
    # and place some at end
    for i in \
             /usr/bin \
             /bin \
             /usr/X11/bin \
             /usr/bin/X11 \
             /usr/lang \
             /etc \
             /usr/etc \
             /sbin \
             /usr/sbin \
             /usr/krb5/sbin \
             /usr/lbin \
             /usr/bsd \
             /usr/sccs \
             /usr/5bin \
             /usr/ccs/bin \
             /usr/openwin/bin \
             /usr/java/bin \
             /usr/products/bin \
             /usr/hosts \
             /usr/new \
             /usr/lib/nmh \
             /usr/lib/acct \
             /usr/xpg4/bin \
             ; do
        # Place : at beginning and end to enable exact path search (even at ends)
        # Note: I should do the same as for "beginning..." BUT /usr/ucb/expr
        # seems to have a limit of about 127 characters that can be returned via
        # \(.*\).
        # All systems /usr/bin/expr seem to work. I've wanted /usr/ucb first
        # because it's "-n" processing matches links /bin/echo whereas solaris
        # /bin/echo does not. BUT FreeBSD does not have /usr/bin/expr
        if [ `expr ":$PATH:" : ".*:$i:"` = 0 -a -d $i ];then PATH=$PATH:$i; fi
    done
    if [ -x /usr/src/linux/arch/i386/kernel/gdbstart ];then
        # special way to activate kgdb; this will help me remember it.
        # But should I use a shell function instead???
        PATH=$PATH:/usr/src/linux/arch/i386/kernel
    fi
    #PATH=$PATH:.    # NOTE: sh is not as sensity about the : as csh is. 2021-10-7 modern "find...-exec..." considers this an error (security risk).
    fix_path -s "$@"  # to help some versions of expr
    # From cron and sh -c ... even though PATH is an environmental variable,
    # these changes do not get "automatically exported"
    export PATH
}
test -n "$echo_ok" && set_path || set_path -s

#GREP_OPTIONS=-n; export GREP_OPTIONS # use grep(){ grep -n "@"; } in .bashrc

# now try to set PAGER to less if it isn't already
if   expr "${PAGER:-}" : '.*less'>/dev/null;then
    export LESS;  LESS="-iRX"   # i=case insensitive search; R=ANSI "color" escape sequences are output in "raw" form; X=Disables  sending  the termcap initialization and deinitialization strings to the terminal - avoid "alternate screen" switching.
    if [ $echo_ok ];then echo "PAGER already set to less" ; fi
elif hash less 2>/dev/null;then
    if [ "${PAGER:-}" != "" -a "$echo_ok" ];then
        echo "changing PAGER from $PAGER to less"
    fi
    export PAGER; PAGER=less
    export LESS;  LESS="-iRX"   # i=case insensitive search; R=ANSI "color" escape sequences are output in "raw" form; X=Disables  sending  the termcap initialization and deinitialization strings to the terminal - avoid "alternate screen" switching.
fi

# TRY GETTING OUT OF MANPATH BUSINESS UNLESS I WANT TO KNOW THE DEFAULTS WHICH
# WOULD REQUIRE READING THE MAN(1) MAN PAGE FOR EACH NEW SYSTEM
#if [ "${MANPATH:-}" ];then
#        MANPATH=$MANPATH:/usr/products/manpages
#else
#        # default MANPATH (if MANPATH isn't set) is /usr/catman:/usr/man
#        MANPATH=/usr/catman:/usr/man:/usr/products/manpages
#fi
case "`uname -s`" in
SunOS)
#    MANPATH=/usr/lang/man:$MANPATH
    FONTPATH=/usr/openwin/lib/fonts${FONTPATH:+:$FONTPATH}
    export MANPATH FONTPATH;;
IRIX)
    if [ $echo_ok ];then stty intr '^c' erase '^h' echoe swtch '^z'; fi;;
Linux)
    #MAKE="make -j 4";export MAKE # I have been burned (confused) by makefiles
                                  # that can not handle parallel makes too
                                  # many times
    if [ "${MANPATH-}" = '' ] && manpath=`man -w`;then
        export MANPATH; MANPATH=$manpath
    fi
    ;;
esac

#export TERM PATH
#export PS1="\h> "
#export PS1
ULISTPROC_ARCHIVES_UMASK=000; export ULISTPROC_ARCHIVES_UMASK

if [ "$0" = ksh -o "$0" = "-ksh" ];then
    set -o vi	# enable vi line editing mode (ESC-k goes up [back] in history)
fi

HISTCONTROL=ignoredups; export HISTCONTROL
test -n "$HISTIGNORE" && HISTIGNORE=`echo $HISTIGNORE | sed 's/:ls//'`
test -z "${RGANG_RSH-}" && \
{ RGANG_RSH='ssh -x -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oLogLevel=ERROR -oConnectTimeout=5 -oBatchMode=yes'
  export RGANG_RSH
}
VERSION_CONTROL=numbered; export VERSION_CONTROL # see man cp,mv,ln and patch

if [ "${BASHRC-}" -a "${ENVONLY:-}" != 1 ];then
    #echo "`date`: \$BASHRC=${BASHRC-} \$ENVONLY=${ENVONLY:-} \$0=$0" >>${HOME-/tmp}/.profile.log
    expr "$0" : '.*bash' >/dev/null && export -f fix_path set_path  # many system adjust the path in /etc/bashrc (called from .bashrc)
    #uname -v | egrep -i 'debian|ubuntu' >/dev/null || 
                                 # .bashrc currently re-executes set_path in this case
    . $BASHRC  # Note my "BASHRC" is mostly bourne shell (sh) compatible
    if   [ -f       ./SOURCEME ];then .       ./SOURCEME
    elif [ -f   $HOME/SOURCEME ];then .   $HOME/SOURCEME
    elif [ -f $MYHOME/SOURCEME ];then . $MYHOME/SOURCEME   # either same as $HOME or ~ron
    fi
else
    stty intr ^c
    cd .    # .bashrc does this
fi

test -f /proc/cpuinfo && { CETPKG_J=`grep ^processor /proc/cpuinfo|wc -l`;export CETPKG_J; }

# Teststand security -- timeout console session left at bash cmd prompt
# See man bash.   Also handle serial line "terminal" resize
if expr "`tty`" : '/dev/ttyS\{0,1\}[1-6]$' >/dev/null;then
    TMOUT=3600
    hash resize 2>/dev/null && eval `resize`
else
    unset TMOUT
fi


# check if coming from home
# See also sshd_config ClientAlive{CountMax,Interval} and ssh_config ServerAliveInterval
keepalive() { if [ "${1-}" ];then sleep=$1;else sleep=25;fi
    eval "while sleep $sleep;do echo -n '\000';done &"; 
    keepalive_active=1  # try to make sure to remember to cleanup
} # keep an interactive ssh connection alive/active
if [ ! "${keepalive_active-}" ];then
    # maybe I should be doing:
    # nslookup `echo $SSH_CLIENT | awk '{print $1;}'` | grep covad.net
    if    expr "${SSH_CLIENT-}" : '68.16[56]' >/dev/null \
       || expr "${SSH_CLIENT-}" : '66.16[7]' >/dev/null \
       || expr "${SSH_CLIENT-}" : '72.245' >/dev/null;then
        if [ $echo_ok ];then
            echo "starting \"keepalive\" login from $SSH_CLIENT"
        fi
        keepalive   # kill this in .bash_logout
        if [ ! "${KRB5CCNAME-}" ] && krbcc=`find /tmp -name 'krb*' -user ron`;then
            # weird outback "Kerberos v5 TGT forwarding failed"
            # Does not happend from fnapcf, but does happen from
            # home (both with or without vpn), but does not happen when at
            # work with laptop???
            # outback's kinit gives:
            #   Security policy violation, no passwords typed over the network!
            #   Perhaps the command 'new-portal-ticket' will be useful?
            # steal another sessions...
            xx=`/bin/ls -t $krbcc | head -1`
            yy=/tmp/krb5cc_`id -u`
            if [ $xx != $yy ];then cp -fp $xx $yy; fi
            if [ -f $yy ];then
                KRB5CCNAME=$yy
                export KRB5CCNAME
                echo setting KRB5CCNAME=$KRB5CCNAME
            fi
        fi
    fi
fi

# Ref. vncxterm.sh, vncssh.sh - avoid scripts/commands that can generate
# SIGHUP.  A SIGHUP while in .bashrc causes bash to exit.
# This is a bit strange as the behavior is different when vncssh.sh
# is typed in at the prompt. --- the process group is different.
# For commands from .bashrc -- the (to be) interactive bash is the
# start of the process group. From the command prompt, the vncssh.sh
# is in a new process group
# Test multiple commands:
#    cmd1='xx="hi      then";echo "$xx"' cmd2="echo 'there    now'"
#    CMD_STR=`echo "$cmd1";echo "$cmd2"` xterm -ls
# OR CMD_STR="suspend2ram_loop vncssh.sh novatest01.fnal.gov:61" xterm -ls &
# OR (echo echo hi;echo echo there) >|t.t; CMD_STR=`echo echo a;echo ':!t.t';echo echo b` xterm -ls
#hcmd() { history -s "$@";trap '' HUP;eval "$@";trap - HUP; }
#hcmd() { sig=""; test -n "$sig" && trap '' $sig;IFSsav=$IFS IFS='
#';for cmd_ in $1;do IFS=$IFSsav; history -s "$cmd_";eval "$cmd_";done
#test -n "$sig" && trap - $sig; }
# NOTE '^::' to signal "hist only" 
hcmd() { history -s "$@"; echo "$@"; eval "$@"; }
process_cmd_str()
{
    IFSsav=$IFS IFS='
';  for cmd_ in $1;do IFS=$IFSsav
        if   histonly=`expr "$cmd_" : '::\(.*\)'`;then
            history -s "$histonly"
        elif file=`expr "$cmd_" : ':!\(.*\)'`;then
            xx=`cat $file`
            process_cmd_str "$xx"  # recursive call
        else
            hcmd "$cmd_"
        fi
    done
}
if [ -n "${CMD_STR-}" ];then
    process_cmd_str "$CMD_STR"
    history -n # read all hist lines not already read from the hist file and append them to the list
    unset CMD_STR
fi
