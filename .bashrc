:
#  This file (.bashrc) was created by Ron Rechenmacher <ron@fnal.gov> in
#  1993. "TERMS AND CONDITIONS" governing this file are in the README
#  or COPYING file. If you do not have such a file, one can be obtained by
#  contacting Fermi Lab in Batavia IL, 60510, phone: 630-840-3000.
#   $RCSfile: .bashrc,v $
#   $Revision: 1.558 $
#   $Date: 2026/02/07 05:17:00 $

# for use w/: set | grep sourced_time_ | sed 's/=/ /' | sort -k2
if [ -z "${sourced_time_bashrc__frst-}" ];then
    sourced_time_bashrc__frst=`date +%Y-%m-%d_%H:%M:%S.%N_%Z`
    sourced_time_bashrc__last=$sourced_time_bashrc__frst
    sourced_time_bashrc__cnt=1
else
    sourced_time_bashrc__last=`date +%Y-%m-%d_%H:%M:%S.%N_%Z`
    sourced_time_bashrc__cnt=$((sourced_time_bashrc__cnt+1))
fi
#export TRACE_NAME='%~sourcecode~ %F|%^sourcecode'
# path should be setup (.profile adjust path) (except .profile is not invoked
# when rsh-ing
#if [ -d /opt/SUNWspro/bin ];then
if [ `expr ":$PATH:" : ".*:/usr/local/bin:"` = 0 -a -d /usr/local/bin ];then
    # needed to premake all for vx_tools rsh to fndaud
#    PATH=/opt/SUNWspro/bin:$PATH
    PATH=/usr/local/bin:$PATH
fi

#export TRACE_NAME=%3F
xx=$(which java 2>/dev/null) && export JAVA_HOME=`dirname $(dirname $(readlink -f $xx))`

### ONLY .bashrc (NOT .profile) GETS SOURCE DURING A 'rsh <command>' INVOCATION
echo_ok=""
if tty -s ; then echo_ok=t; fi	# could also use if [ -t ]...
if [ "$echo_ok" -a \( "${SHLVL-}" = "" -o "${SHLVL-}" = 1 \) ]; then
    stty dec # better than stty intr ^c
    #stty erase '^h'
    stty erase '^?'
    echo  ".bashrc:  >-<((('> <)[[[(><"
    if [ -f TODO ];then cat TODO;fi
    if [ -f $HOME/ron.dir/prayer.log ];then
        awk '/General prayer/,EOT' $HOME/ron.dir/prayer.log
    fi
    if [ -f $HOME/script/bible_books-intro.txt ];then
        book=`expr $RANDOM \* \( 72 + 1 \) / \( 32767 + 1 \)`
        book=`expr $book + 1`
        awk "/^$book$/,/^\./" $HOME/script/bible_books-intro.txt
        # to list books: awk '/^[0-9]/{getline;print}' bible_books-intro.txt
    fi
fi

#doesn't work on ultrix if [ "`/bin/basename $0 2>/dev/null`" != ".bashrc" ];then
if [ "`basename $0 2>/dev/null`" = ".bashrc" ];then
    # sh can only "return" from a function, not a sourced file.
    # can't do 'out="set -n"' - won't every execute commands again
#    out=exit
    echo "You should be sourcing this file."
#    $out
    exit
fi

#skip if not interactive shell
#just skip some stuff - this specificly allows 'rsh fndaub dicon somestring'
#from fndauq
interactive=0
#use line below #if [ \! "$USER" -o \! "$PS1" ]; then $out ; fi
#if [ \! "$USER" -o \! "$echo_ok" ];then $out ;fi
#if [ "${USER-}" -a "$echo_ok" ];then interactive=1;fi
if [   \(   "${USER-}" \
         -o "${DISPLAY-}" != "" \
         -o "${SHLVL-}" = 1 \) \
    -a "$echo_ok" ];then
    interactive=1
fi
#unset out

#icon and window name/title change - note xterm sequence messes up dterm, but
#a reset from the Commands menu fixes it
#I moved dicon functions for fndauq above the cutoff for interactive
dicon() { x="$*";echo "\033]2L;$x\033\\";unset x;}
dwin()  { x="$*";echo "\033]21;$x\033\\";unset x;}
xicon() { x="$*";echo "\033]1;$x\007";unset x;}
xwin()  { x="$*";echo "\033]2;$x\007";unset x;}
xwi()   { x="$*";echo "\033]1;$x\007\033]2;$x\007";unset x;}
fixcutandpaste()  {      printf "\e[?2004l"; }

## setup here is only for local cvs as initiated by a remote node
#CVSROOT=/home/t1/ron/work/rcvs/master_repos; export CVSROOT
##cvs() { /p/IRIX/rcvs/v0_6_4/bin/cvs "$@" ; }
#cvs() { /cvs/root/bin/cvs "$@" ; }
#PATH=:/p/IRIX/diff/v1_0/bin:$PATH ; export PATH
#RCSBIN=/p/IRIX/rcs/v5_6/bin; export RCSBIN
#ps -ef | grep $$ | grep -v 'ps -ef'>> logfile
case `uname -n` in
fnapcf*)
    cvs() { /p/cvs/v1_11_7/bin/cvs "$@"; }
    ;;
esac

UNALIAS_LIST="man tty ls lls la l. cp mv rm which keepalive man functions ps prod h hist rgrep rsync setup ssh vi"
for cmd in $UNALIAS_LIST;do # could do unalias -a ??
    if x=`type $cmd 2>&1 | grep alias`;then
        test -n "$echo_ok" && echo "UNALIASING (from /etc/profile.d/*.sh?) $x"
        unalias $cmd >/dev/null 2>&1
    fi
done

whichwithout() # $1=component(s) to drop $2 cmd
{   components=$1
    cmd=$2
    newpath=$PATH
    IFSsav=$IFS IFS=:
    for cc in $components;do
        newpath=`echo ":$newpath:" | sed -e "s|\(.*\):$cc:\(.*\)|\1:\2|;"'s/^://;s/:$//'`
    done
    IFS=$IFSsav
    #echo newpath=$newpath >&2  # without "" to see what IFS is
    PATH=$newpath sh -c "type $cmd" | sed -e 's/^[^/]*//;s/^(//;s/)$//'
}
GREP=`whichwithout $MYHOME/script grep`
EGREP="`whichwithout $MYHOME/script grep` -E"

# NOTE pfind and ppid are (or could be) used in the trailing part of .profile
# NOTE pfind and ppfind (pfind include parent pid) are the same in most cases
case `uname` in
Linux)
            # The following "default" does not work for FreeBSD as -L lists keywords...
            if ps -L H >/dev/null 2>&1;then thread_opt="-L ";else thread_opt='';fi
            pfind_opt=axwwouser,pid,lwp,nlwp,%cpu,%mem,vsz,rss,tname,stat,start_time,bsdtime,psr,comm,args
            ppfind() { if [ "$1" = "--ps_opt" ];then ps_opt=$2;shift 2;else ps_opt=;fi; ps ${thread_opt}alxww${ps_opt-} | ( (IFS=;read hdr;echo "$hdr");grep -E "$@"); }
            psaux() { ps axouser,pid,%cpu,%mem,vsz,rss,tname,stat,start_time,bsdtime,psr,args "$@"; }
            psp=`ps -p $$|tail -1` # no "-" (before option "p") needed for (modern) Linux distros EXCEPT GNU bash, version 5.3.0(1)-release (x86_64-redhat-linux-gnu) On Fedora 43 - See notes
            pst()       { pstree -lacGpu "$@"; }
            ppid() { test -n "${1-}" && pid=$1 || pid=$$; expr "`echo \`ps lp $pid\``" : ".*$pid  *\([0-9]*\)"; }
            man() { /usr/bin/man -a "$@"; };;

SunOS)      pfind_opt=auxww
            psfind(){ if [ "$1" = "--ps_opt" ];then ps_opt=$2;shift 2;else ps_opt=;fi;/bin/ps -e -o user,pid,ppid,lwp,nlwp,taskid,projid,project,pri,tty,time,args ${ps_opt-} | ( (IFS=;read hdr;echo "$hdr");grep -E "$@"); }
            ppfind() { if [ "$1" = "--ps_opt" ];then ps_opt=$2;shift 2;else ps_opt=;fi; ps alxww${ps_opt-} | ( (IFS=;read hdr;echo "$hdr");grep -E "$@"); }
            ppid() { test -n "${1-}" && pid=$1 || pid=$$; expr "`echo \`ps -l $pid\``" : ".*$pid  *\([0-9]*\)"; }
            psp=`/bin/ps -lp $$|tail -1`;
            man() { /usr/bin/man -a "$@"; };;

IRIX*|CYG*) pfind_opt=-ef
            ppfind() { if [ "$1" = "--ps_opt" ];then ps_opt=$2;shift 2;else ps_opt=;fi; ps -ef${ps_opt-} | ( (IFS=;read hdr;echo "$hdr");grep -E "$@"); }
	    ln() { /bin/ln -i "$@" ; }
            ppid() { test -n "${1-}" && pid=$1 || pid=$$; expr "`echo \`ps -lp $pid\``" : ".*$pid  *\([0-9]*\)"; }
            psp=`ps -p $$|tail -1`;;

OSF1)       pfind_opt=-ef
            ppfind() { if [ "$1" = "--ps_opt" ];then ps_opt=$2;shift 2;else ps_opt=;fi; ps -ef${ps_opt-} | ( (IFS=;read hdr;echo "$hdr");grep -E "$@"); }
            ppid() { test -n "${1-}" && pid=$1 || pid=$$; expr "`echo \`ps -lp $pid\``" : ".*$pid  *\([0-9]*\)"; }
            psp=`ps -p $$|tail -1`;;

AIX)	    pfind_opt=-Af
            ppfind() { if [ "$1" = "--ps_opt" ];then ps_opt=$2;shift 2;else ps_opt=;fi; ps -Af${ps_opt-} | ( (IFS=;read hdr;echo "$hdr");grep -E "$@"); }
            ppid() { test -n "${1-}" && pid=$1 || pid=$$; expr "`echo \`ps -lp $pid\``" : ".*$pid  *\([0-9]*\)"; }
            psp=`ps -p $$|tail -1`;;

FreeBSD)    pfind_opt=auxww thread_opt=H
            ppfind() { if [ "$1" = "--ps_opt" ];then ps_opt=$2;shift 2;else ps_opt=;fi; ps -alxww${ps_opt-} | ( (IFS=;read hdr;echo "$hdr");grep -E "$@"); }
            ppid()   { test -n "${1-}" && pid=$1 || pid=$$; expr "`echo \`ps -lp $pid\``" : ".*$pid  *\([0-9]*\)"; }
            psp=`ps -p $$|tail -1`;;

Darwin)	    pfind_opt=augxww
            ppfind() { if [ "$1" = "--ps_opt" ];then ps_opt=$2;shift 2;else ps_opt=;fi; ps -alxww${ps_opt-} | ( (IFS=;read hdr;echo "$hdr");grep -E "$@"); }
            ppid()   { test -n "${1-}" && pid=$1 || pid=$$; expr "`echo \`ps -lp $pid\``" : ".*$pid  *\([0-9]*\)"; }
            psp=`ps -p $$|tail -1`
            man() { /usr/bin/man -a "$@"; };;

*)	    pfind_opt=-augxww
            ppfind() { if [ "$1" = "--ps_opt" ];then ps_opt=$2;shift 2;else ps_opt=;fi; ps -algxww${ps_opt-} | ( (IFS=;read hdr;echo "$hdr");grep -E "$@"); }
            ppid()   { test -n "${1-}" && pid=$1 || pid=$$; expr "`echo \`ps -lp $pid\``" : ".*$pid  *\([0-9]*\)"; }
            psp=`ps -p $$|tail -1`;;
esac
pfind() {
  ps_opt= do_header=1
  while expr "$1" : - >/dev/null;do
    case "$1" in --ps_opt) ps_opt=$2; shift;; -h) do_header=;; esac; shift
  done
  ps ${thread_opt-}$pfind_opt$ps_opt \
  | { ( IFS=;read hdr; test -n "$do_header" && echo "$hdr" ); grep -E "$@"; }
}

psmemused()
{   used=`ps auxh | awk '{print \$6;}' \
     | (tot=0;while read rss;do tot=\`expr \$tot + \$rss\`;done;echo \$tot)`
    printf "            ps   used = %7d KB\n" $used
    free_used=`free | awk '/buffers.cache/{print $3;}'`
    printf "            free used = %7d KB\n" $free_used
    perl -e "printf \"                      ps is %7.3f %% of the free value\n\", 100*$used/$free_used;"
    delta=`expr $free_used - $used`
    printf "delta from free value = %7d KB\n" $delta
    perl -e "printf \"                   delta is %7.3f %% of the free value\n\", 100*$delta/$free_used;"
}

# Before the next "interactive if block" can be executed, I must either
#    a) unalias commands that I will be making functions out of. I must do
#       this to avoid syntax error near unexpected token `(' errors as the
#       whole if block gets parsed before any lines within get executed.
# OR b) shield the functions inside: eval ""
# Note: aliases are setup in /etc/bashrc, so if I want to unalias after
#       /etc/bashrc below, I might as well do b) now to avoid double unalias.
# To force interactive, just set the env var INTERACTIVE to non-null
if [ $interactive = 1 -o "${INTERACTIVE-}" ];then

    if [ "${USER-}" = "" ];then
        echo setting USER env var for interactive session
        USER=`whoami`;export USER
    fi
    if [ "${RONUSER-}" = "" ];then
        RONUSER=ron; export RONUSER
        if hash finger 2>/dev/null;then
          ronuser=`finger $USER 2>/dev/null |awk 'BEGIN{IGNORECASE=1}/login.*rechenmacher/{print$2;exit}'`
          if [ "$ronuser" -a "$ronuser" != ron ];then
            RONUSER=$ronuser
            echo "bashrc: setting RONUSER=$ronuser"
          fi
        fi
    fi

    # Note: the "expr...bash" is the same test in .profile to qualify the bash
    # bash-specific "export -f" of set_path (used below)
    if expr "$0" : '.*bash' >/dev/null && [ -f /etc/bashrc ];then
        pre_etc_bashrc_path=$PATH
        expr "$-" : '.*u' >/dev/null && set +u && setu=1 || setu=
        . /etc/bashrc
        test -n "$setu" && set -u; unset setu
        if [ $PATH != $pre_etc_bashrc_path ];then
            echo 'PATH changed in /etc/bashrc; rerunning set_path'
            set_path
        fi
    fi

    for cmd in $UNALIAS_LIST;do # could do unalias -a ??
        if x=`type $cmd 2>&1 | grep alias`;then
            echo "UNALIASING (after /etc/bashrc) $x"
            unalias $cmd >/dev/null 2>&1
        fi
    done

    # make undefined vars behave as in csh
    #set -u  # this is best for scripts, but less so for interactive sessions

    # next is not needed with null passphrase
    # SHOULD THIS BE IN .PROFILE???
    #if hash ssh-agent 2>/dev/null;then
    #    eval `ssh-agent -s`
    #fi

    # I am interactive, and .bash_profile has run
    # I might be here thru 'xterm' -- fermi.shrc resets path (blowing away any
    # products I've setup, so I might as well remove env vars.
    #if [ \! \( "$0" = "bash" -o "$0" = "-bash" -o "$0" = "sh" \) ];then
    #    unset `set | $GREP '^[A-Z_]*_DIR=' | sed -e '/UPS_DIR=.*/d' -e 's/=.*//'`
    #    # wasn't sourced (or .'ed)
    #else
    #    echo ".bashrc sourced by interactive user"
    #fi
    #       Fairly useful - used below
    NODE=`hostname|sed s/'\..*'//`
    export NODE

    case $NODE in
        *clued0) MYHOME=/home/ron;;  # garbage gets output that messes up xterm
        *)      MYHOME=`echo ~ron` 
		test "$MYHOME" = '~ron' && MYHOME=`/bin/csh -fc "echo ~$RONUSER" 2>/dev/null`
            test \( "$MYHOME" = "" -o ! -d "$MYHOME" \) -a -d /home/$RONUSER && MYHOME=/home/$RONUSER
            eval "test \( \"$MYHOME\" = '' -o ! -d \"$MYHOME\" \) -a -d ~$RONUSER && MYHOME=~$RONUSER"
            ;;
    esac
    if [ "$MYHOME" = "" ];then MYHOME=$HOME; fi
    #if [ ! -f $MYHOME/.nofermi -a $interactive = 1 ];then
    # a .fermi file of size 0 disables for all OR grep .fermi for specific node
    if    [ $interactive = 1 ] \
        && (   [ ! -f $MYHOME/.nofermi ] \
        || [ -s $MYHOME/.nofermi \
        -a "`grep ^$NODE$ $MYHOME/.nofermi`" = "" ] );then
        for fuefile in /p/setup\
            /products/setup\
            /usr/local/etc/sdssfue.sh\
            /usr/local/etc/fermi.shrc\
            /usr/local/etc/setups.sh\
            /fnal/ups/etc/setups.sh\
            /D0/ups/etc/setups.sh\
            /cdf/onln/code/products/lnx/setups/setups.sh\
            /usr/local/ILCTA/ups/etc/setups.sh\
            $HOME/p/setup\
            $MYHOME/p/setup; do
          if [ -f $fuefile ];then
              #unset `set|$GREP '^[A-Z_]*_DIR='|sed -e '/UPS_DIR=.*/d' -e 's/=.*//'`
              if type setup 2>&1 | grep 'ups setup' >/dev/null && hash ups 2>/dev/null;then
                  echo ups setup function already exists - skipping the sourcing of $fuefile
                  xx=`dirname $fuefile`
                  echo ":$PRODUCTS:" | grep ":$xx:" >/dev/null || PRODUCTS="$PRODUCTS:$xx"
              else
                  echo sourcing $fuefile for ups setup
                # Note: unsetting SETUP_UPS is safe (as far as not worrying
                #   about error during unsetup) but no unsetup means I have to
                #   manually clean up the path
                # Note: I know I want to unset PRODUCTS and SETUP_UPS, but do I
                #   really need to unset UPS_DIR? The 1st imperical tests
                #   indicate: no, I do not need to unset UPS_DIR. BUT, more
                #   testing reveals that if UPS_DIR is set, ups tries to use
                #   $UPS_DIR/bin/dropit (unsure why). There seems to be no
                #   problems with just unsetting UPS_DIR.
                  unset PRODUCTS SETUP_UPS UPS_DIR
                  expr "$-" : '.*u' >/dev/null && set +u && setu=1 || setu=	# bad programmers
                  . $fuefile
                  test -n "$setu" && set -u; unset setu
                  if type unsetup_all 2>&1 | grep function >/dev/null;then :;else
                      # This should be a part of ups or in fermi.ups.sh
                      unsetup_all() 
                      { 
                          for pp in `printenv | sed -ne '/^SETUP_/{s/SETUP_//;s/=.*//;p}'`;do
                              test $pp = UPS && continue;
                              prod=`echo $pp | tr 'A-Z' 'a-z'`;
                              echo "unsetup -j $prod";
                              eval "tmp=\${SETUP_$pp-}";
                              test -z "$tmp" && echo already unsetup && continue;
                              unsetup -j $prod;
                          done
                      }
                  fi
                  unsetup_dev() # $1 optional dropit; examples: unsetup_dev $PWD; unsetup_dev `dirname $PWD`
                  {
                      unsetup_all
                      for vv in MRB_TOP OLD_MRB_BUILDDIR;do
                          eval dd=\"\${$vv-}\"
                          test -z "$dd" && continue
                          if echo "$SETUP_UPS" | grep "$dd" >/dev/null;then
                              eval good_db=`ups list -KPROD_DIR_PREFIX ups -c | grep -v "$dd" | head -1`
                              test -z "$good_db" && { echo not dropping $dd; continue; }
                              echo setting up ups from -z \"$good_db\"
                              unset SETUP_UPS; : otherwise, for some reason, the next line does nothing
                              setup ups -z "$good_db"
                              : type ups dropit
                          fi
                          echo dropit $vv=$dd
                          PATH=`dropit "$dd"` PRODUCTS=`dropit -d : -p "${PRODUCTS-}" "$dd"`
                          unset $vv
                      done
                      IFSsav=$IFS;IFS=:;for dd in $PRODUCTS;do
                          test -d "$dd" || PRODUCTS=`dropit -e -d : -p "${PRODUCTS-}" "$dd"`
                      done; IFS=$IFSsav
                      cetpkg_j_sav=${CETPKG_J-}
                      vars="LD_LIBRARY_PATH DYLD_LIBRARY_PATH ROOT_INCLUDE_PATH PERL5LIB \
                          FHICL_FILE_PATH MRB_ CETPKG_ DAQINTERFACE_ ARTDAQDEMO_ ARTDAQ_ DAQ_INDATA_PATH"
                      vars=`echo "$vars" | sed 's/  */|/g'`
                      vars=`printenv | grep -E -o "^($vars)[^=]*" | sort`
                      for vv in $vars;do
                          echo unsetting $vv; unset $vv
                      done
                      test -n "$cetpkg_j_sav" && export CETPKG_J=$cetpkg_j_sav
                      unset dd vv cetpkg_j_sav vars
                      if [ -n "$1" ];then
                          droppath=`cd $1 2>/dev/null;pwd`; PATH=`dropit $droppath`
                          PRODUCTS=`dropit -p "${PRODUCTS-}" $droppath`
                      else
                          echo NOTE: PRODUCTS=$PRODUCTS
                      fi
                  }
                  # mrb_patch_local_setup - patches localProducts_*/setup files to allow
                  # easy qualifier changes -- adds qual to build_dir path name
                  # After mrb_patch_local_setup, mrb z; unsetup_dev; export MRB_QUALS=<quals>; . setupARTDAQDEMO
                  #                        e.g.: mrb z; envreset; export MRB_QUALS=e19:s97:prof; . setupARTDAQDEMO
                  # Probably also:
                  #   mv localProducts_artdaq_demo_v3_03_02_e15_s64_prof localProducts_artdaq_demo_v3_03_02_e15_s65_prof
                  #   sed -i s/e15_s64/e15_s65/   setupARTDAQDEMO localProducts_artdaq_demo_v3_03_02_e15_s65_prof/setup 
                  #   sed -i s/e15:s64:/e15:s65:/ setupARTDAQDEMO localProducts_artdaq_demo_v3_03_02_e15_s65_prof/setup 
                  mrb_patch_local_setup() {
                      if [ -n "$MRB_TOP" ];then
                          sfiles=`echo $MRB_TOP/local*/setup`
                      elif ss=`/bin/ls local*/setup 2>/dev/null`;then
                          sfiles=$ss
                      else
                          echo no setup files; return
                      fi
                      echo "setup file(s):" $sfiles
                      sed -i -e "/\"build_\${flav}\"/{s#{flav}#{flav}_\$(echo \${MRB_QUALS}|sed 's/:/-/g')#;a\
test -d \"\${MRB_TOP}/\${buildDirName}\" || mkdir \"\${MRB_TOP}/\${buildDirName}\"
}"  $sfiles
                      : sed -n -e "/^setenv MRB_QUALS/{s#setenv#tnotnull MRB_QUALS || setenv#;p}"  $sfiles
                        sed -i -e "/^setenv MRB_QUALS/{s#setenv#tnotnull MRB_QUALS || setenv#}"  $sfiles
                  }
              fi
              if [ \! -f $MYHOME/.noupsproducts ]; then
                  test -f $MYHOME/fermi.ups.sh && . $MYHOME/fermi.ups.sh
              fi
              #break # don't break of multiple PRODUCTS areas is desired
          fi
        done
        # envreset -- keeps you at your CWD. pretty much everything else is gone.
        # Should I add ${SSH_AGENT_PID:+SSH_AGENT_PID=$SSH_AGENT_PID} ${SSH_AUTH_SOCK:+SSH_AUTH_SOCK=$SSH_AUTH_SOCK}
        # Adding "$@" allows for: envreset CMD_STR='echo hi'
        # Thinking about env.var. var=val list building from list of env.vars.
        # 10 or 11 vars: SHELL, TERM, DISPLAY, XAUTHORITY, LOGNAME, USER,
        #                KRB5CCNAME, SSH_{AGENT_PID,AUTH_SOCK,USER_AUTH} [PATH]
        envreset() {
            exec /bin/env     -i HOME=~ SHELL=$SHELL TERM=$TERM DISPLAY="$DISPLAY"\
                 LOGNAME=$USER USER=$USER\
                 ${XAUTHORITY+XAUTHORITY=$XAUTHORITY}\
                 ${KRB5CCNAME+KRB5CCNAME="$KRB5CCNAME"}\
                 ${SSH_AGENT_PID+SSH_AGENT_PID=$SSH_AGENT_PID}\
                 ${SSH_AUTH_SOCK+SSH_AUTH_SOCK=$SSH_AUTH_SOCK}\
                 ${SSH_USER_AUTH+SSH_USER_AUTH=$SSH_USER_AUTH}\
                 ${SSH_ASKPASS+SSH_ASKPASS=$SSH_ASKPASS}\
                 ${SSH_CONNECTION+SSH_CONNECTION="$SSH_CONNECTION"}\
                 ${SSH_CLIENT+SSH_CLIENT="$SSH_CLIENT"}\
                 ${SSH_TTY+SSH_TTY=$SSH_TTY}\
                 ${DBUS_SESSION_BUS_ADDRESS+DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS}\
                 ${DESKTOP_SESSION+DESKTOP_SESSION=$DESKTOP_SESSION}\
                 ${GDMSESSION+GDMSESSION=$GDMSESSION}\
                 ${GNOME_SETUP_DISPLAY+GNOME_SETUP_DISPLAY=$GNOME_SETUP_DISPLAY}\
                 ${MEMORY_PRESSURE_WATCH+MEMORY_PRESSURE_WATCH=$MEMORY_PRESSURE_WATCH}\
                 ${QT_IM_MODULES+QT_IM_MODULES=$QT_IM_MODULES}\
                 ${TERMINATOR_DBUS_NAME+TERMINATOR_DBUS_NAME=$TERMINATOR_DBUS_NAME}\
                 ${TERMINATOR_DBUS_PATH+TERMINATOR_DBUS_PATH=$TERMINATOR_DBUS_PATH}\
                 ${WAYLAND_DISPLAY+WAYLAND_DISPLAY=$WAYLAND_DISPLAY}\
                 ${XDG_ACTIVATION_TOKEN+XDG_ACTIVATION_TOKEN=$XDG_ACTIVATION_TOKEN}\
                 ${XDG_CURRENT_DESKTOP+XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP}\
                 ${XDG_DATA_DIRS+XDG_DATA_DIRS=$XDG_DATA_DIRS}\
                 ${XDG_MENU_PREFIX+XDG_MENU_PREFIX=$XDG_MENU_PREFIX}\
                 ${XDG_RUNTIME_DIR+XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR}\
                 ${XDG_SESSION_CLASS+XDG_SESSION_CLASS=$XDG_SESSION_CLASS}\
                 ${XDG_SESSION_DESKTOP+XDG_SESSION_DESKTOP=$XDG_SESSION_DESKTOP}\
                 ${XDG_SESSION_TYPE+XDG_SESSION_TYPE=$XDG_SESSION_TYPE}\
                 "$@" $SHELL -l; } # pwd remains; w/ -l this should be cshell compatible
        envbare() {
            if [ $# -eq 0 ];then
              exec env -i HOME=~ SHELL=$SHELL TERM=$TERM DISPLAY="$DISPLAY"\
                 LOGNAME=$USER USER=$USER PATH=/usr/bin:/bin\
                 ${XAUTHORITY+XAUTHORITY=$XAUTHORITY}\
                 ${XDG_ACTIVATION_TOKEN+XDG_ACTIVATION_TOKEN=$XDG_ACTIVATION_TOKEN}\
                 ${XDG_CURRENT_DESKTOP+XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP}\
                 ${XDG_DATA_DIRS+XDG_DATA_DIRS=$XDG_DATA_DIRS}\
                 ${XDG_MENU_PREFIX+XDG_MENU_PREFIX=$XDG_MENU_PREFIX}\
                 ${XDG_RUNTIME_DIR+XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR}\
                 ${XDG_SESSION_CLASS+XDG_SESSION_CLASS=$XDG_SESSION_CLASS}\
                 ${XDG_SESSION_DESKTOP+XDG_SESSION_DESKTOP=$XDG_SESSION_DESKTOP}\
                 ${XDG_SESSION_TYPE+XDG_SESSION_TYPE=$XDG_SESSION_TYPE}\
                 $SHELL --norc  # doing . ~ron/.profile does not equal above (prompt is different)
            else
              # parameter is a command or script (a test could be "printenv")
              env      -i HOME=~ SHELL=$SHELL TERM=$TERM DISPLAY="$DISPLAY"\
                 LOGNAME=$USER USER=$USER PATH=/usr/bin:/bin\
                 ${XAUTHORITY+XAUTHORITY=$XAUTHORITY}\
                 ${XDG_ACTIVATION_TOKEN+XDG_ACTIVATION_TOKEN=$XDG_ACTIVATION_TOKEN}\
                 ${XDG_CURRENT_DESKTOP+XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP}\
                 ${XDG_DATA_DIRS+XDG_DATA_DIRS=$XDG_DATA_DIRS}\
                 ${XDG_MENU_PREFIX+XDG_MENU_PREFIX=$XDG_MENU_PREFIX}\
                 ${XDG_RUNTIME_DIR+XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR}\
                 ${XDG_SESSION_CLASS+XDG_SESSION_CLASS=$XDG_SESSION_CLASS}\
                 ${XDG_SESSION_DESKTOP+XDG_SESSION_DESKTOP=$XDG_SESSION_DESKTOP}\
                 ${XDG_SESSION_TYPE+XDG_SESSION_TYPE=$XDG_SESSION_TYPE}\
                 "$@"
            fi
        }
        envresetarch() {
            echo "consider --uname-2.6"
            exec env     -i HOME=~ SHELL=$SHELL TERM=$TERM DISPLAY="$DISPLAY" XAUTHORITY=$XAUTHORITY setarch x86_64 "$@" $SHELL -l
        }
    fi

    setupr()   # p1 could be path
    {
        USAGE="setupr <path-to-prod-root> <prod_name>"
        if [ ! "${2-}" ];then
            echo "$USAGE"; return 1;
        fi
        prod_root=$1
        prod_name=$2

        # attempt to find product *name*
        #  - 4 possibilites:
        #         /sdfs/dfsd/prod/OSFlavor/version
        #         /sdfs/dfsd/OSFlavor/prod/version
        #         /sdfs/dfsd/prod/version  # could be devel or cut version
        #         /sdfs/dfsd/prod          # devel version - must have ups subdir

        # look for standard version formats

        Path=
        Ldpath=
        if [ -d "$prod_root/bin" ];then
            Path="$Path
            pathPrepend( PATH, \"\${UPS_PROD_DIR}/bin\" )"
        fi
        if [ ! -d /tmp/ups ];then mkdir /tmp/ups;fi
        if [ ! -f /tmp/ups/$prod_name.table ];then
            cat >/tmp/ups/$prod_name.table <<EOF

FILE = TABLE
PRODUCT=$prod_name
FLAVOR = ANY
QUALIFIERS = ""
    ACTION=SETUP
        proddir()
        setupEnv()
        $Path

EOF

        fi

        setup -r $prod_root -M /tmp/ups -m $prod_name.table $prod_name

    }

    setup_r()
    {   i=1 p=
        while expr $i \<= $# >/dev/null;do
        eval x=\$$i
        if p=`expr "$x" : '\([^-].*\)'`;then break; fi
        i=`expr $i + 1`
        done
        if [ ! "${p-}" ];then p=`basename $PWD`; set -- "$@" $p; fi
        if [ -f ups/$p.table ];then
            # Note: version files have keywords TABLE_DIR and TABLE_FILE
            #       So, use -M to override DIR and -m to take care of the FILE
            #       BUT, YOU DO NOT NEED "-M DIR" IF YOU DO NOT SPECIFY A VERSION
            #       BUT ... THIS IS INCONSISTANCE IF THERE IS A *CURRENT* VERSION
            #       SPECIFIED IN THE DATABASE, so it seems a little safer just to
            #       use the -M.
            # Note: if -M dir is relative, it is relative to -r <prod_dir>
            echo "using: setup -r \$PWD -M ups -m $p.table $@"
            setup              -r  $PWD -M ups -m $p.table "$@"
        else
            setup -r $PWD "$@"
        fi
    }

    # some bash excellent interactive aids.
    ignoreeof=10  # bash v3 or newer documents this as UPPERCASE but the lowcase seems to still work
    history_control=ignoredups
    command_oriented_history=
    noclobber=
    set -o noclobber # (same as -C) bash 2 doesn't recogn. plain shell var.
    HISTTIMEFORMAT="%a %m/%d %H:%M:%S  " # try writing timestamps to HISTFILE
    HISTFILESIZE=3000 # 3x dflt HISTSIZE=1000. 3 sessions worth.

    # Doesn't work on ultirx if [ "`/bin/basename $0 2>/dev/null`" = "bash" -o "$0" = "-bash" ];then
    # In the VSCode remote ssh environment -- "...bash --init-file ..." is used.
    if    expr "$psp" : '.*bash[ )]*$'    >/dev/null \
        || expr "$psp" : '.*bash -*login$' >/dev/null \
        || expr "$psp" : '.*bash --init-file' >/dev/null \
        || expr "$psp" : '.*bash.* -l$'      >/dev/null;then # assumes -l is last (note bash necessitats that long option are before short)
        #-o `expr "$SHELL" : '.*/bin/bash'` != 0 \
        #-o "`basename $0 2>/dev/null`" = "bash" \
        #-o "$0" = "-bash" \
        #-o \( "$0" = "-su" -a "${SHELL-}" = /bin/bash \)

        do_bash=1

        # enable is a bash builtin
        #enable -n echo    # echo '\053' just simply does not work (at least in bash version 1.14.6)
        if [ "`echo '\053'`" != "+" ]; then
            if [ "`builtin echo -e '\053' 2>/dev/null`" = "+" ]; then
                echo() { builtin echo -e "$@"; }
            elif [ -x /usr/5bin/echo ]; then
                echo() { /usr/5bin/echo "$@"; }
            else
                echo() { /bin/echo -e "$@"; }
            fi
        fi
        cdspell=t	# available in bash version 2.x
    else
        do_bash=
    fi

    in_container() {  # optional -q for quiet
        #[ "$(ps -p 1 -o comm=)" != "systemd" ] && echo "Probably in a container"
        #[ -f /.dockerenv ] || [ -f /run/.containerenv ] && echo "In a container" || echo "Not in a container"
        if [ -f /.dockerenv ] || [ -f /run/.containerenv ] \
               || grep -Eq 'docker|kubepods|libpod' /proc/1/cgroup \
               || [ "$(ps -p 1 -o comm=)" != "systemd" ]; then
            test $# -ne 1 && echo "In a container"   # -q option no given
            return 0
        else
            test $# -ne 1 && echo "Not in a container"
            return 1
        fi
    }
    # try C-f for bash forward search instead of readline forward char, BUT not in vscode devcontainer
    in_container -q || bind '"\C-f": forward-search-history'
    if   [ "`whoami`" = $RONUSER  ]; then
        prmpt=":^)"
    elif [ "`whoami`" = root -o "`id -u`" = 0 ]; then
        prmpt=':^|'
    else
        prmpt='$'
    fi
    prmpt1chr=`expr "$prmpt" : '.*\(.\)$'`  # for the shortest prompts

    if [ "$TERM" = "emacs" -o "`echo '\053'`" != "+" ] \
       || expr "$psp" : '.*bash -i$'   >/dev/null; then  # "bash -i" for emacs "shell" (and clstcon)
        p_intense=''
        p_color=''
        p_normal=''
    else
        Green="`echo '\033'`[32m"
        Magenta="`echo '\033'`[35m"
        p_intense="`echo '\033'`[1m"
        test -n "${PROMPT_COLOR-}" && \
            p_color="`echo '\033'`[${PROMPT_COLOR}m" || \
                p_color="$Green"
        in_container -q && p_color="$Magenta"
        p_normal="`echo '\033'`[0m"
    fi
    prompt_cmd() { :; }
    if [ ! "${default_PS1+isdefined}"            ];then default_PS1=${PS1-};fi
    if [ ! "${default_PROMPT_COMMAND+isdefined}"\
        -a -n "${PROMPT_COMMAND+isdefined}"         ];then
        default_PROMPT_COMMAND=$PROMPT_COMMAND
    fi
    p0()
    {   # PS1 will have a default, but PROMPT_COMMAND might not have been set
        if [ "$default_PS1" ];then PS1=$default_PS1;else unset PS1;fi
        if [ "${default_PROMPT_COMMAND+isdefined}" ];then PROMPT_COMMAND=$default_PROMPT_COMMAND;
        else                                              unset PROMPT_COMMAND; fi
    }
    p1()
    {   : recall -- multiline PS1 causes trouble with cmdline recall of lines which wrap
        PS1="${p_intense}\${PWD}$p_normal
${NODE}${p_intense} $prmpt$p_normal "
    }

    if [ "$TERM" = "dumb" ];then  # This allows emacs "tramp" (remote file open via ssh) to work.
        p0
    elif [ -n "$do_bash" ];then
        p2()
        {   unset PROMPT_COMMAND
            prompt_cmd() 
            {   PS1=`echo "${p_intense}\`pwd\`$p_normal\n${NODE}${p_intense} $prmpt$p_normal "`  # do not want \n in PS1 just real newline.
            }                                                                              # (just as an aside) sh can handle real newlines in PS1
            cd .
        }
        p3()
        {   unset PROMPT_COMMAND
            prompt_cmd() { PS1="${NODE}:`pwd`$p_intense$prmpt1chr$p_normal "; }; cd .
        }
        p4()
        {   unset PROMPT_COMMAND
            prompt_cmd()
            {
                ppwwdd=`pwd`
                cnt=`expr $ppwwdd : '.*'`
                if [ `expr $cnt \> 30` = 1 ];then
                    # first part will be 10, last will be the last 20.
                    # so include 1-10 and then the 20th position from the end
                    # (cnt-20) thru the end
                    last=`expr $cnt - 20`
        #           ppww=`echo $ppwwdd | cut -c1-10`
                    ppwwdd=`echo $ppwwdd | cut -c1-10`-`echo $ppwwdd | cut -c$last-`
        #           ppww=`echo "$ppww-"`
        #           ppwwdd=`echo $ppwwdd | cut -c$last-`
        #           ppwwdd=`echo $ppww$ppwwdd`
                fi
                PS1="${NODE}:${ppwwdd}$p_intense$prmpt1chr$p_normal "
            }
            cd .
        }
        p5()
        {   PS1="${NODE} $prmpt "
            PROMPT_COMMAND="builtin echo \"${p_intense}\$PWD$p_normal\${LD_PRELOAD:+*}\" >&2"
            prompt_cmd() { :; }
            cd .
        }
        p6()
        {   unset PROMPT_COMMAND
            prompt_cmd() 
            {   PS1="\[${p_intense}\]\w\[$p_normal\]\n\h\[${p_intense}\] $prmpt\[$p_normal\] "
            }                                                                              # (just as an aside) sh can handle real newlines in PS1
            cd .
        }
        # Add date/time for terminal which are left open for a long time.
        p7()
        {   PS1="\D{%m/%d %H:%M} ${NODE} $prmpt "
            PROMPT_COMMAND="builtin echo \"${p_intense}\$PWD$p_normal\${LD_PRELOAD:+*}\" >&2"
            prompt_cmd() { :; }
            cd .
        }
        p8()   # some versions of bash do not know \D
        {   PS1="\d \t ${NODE} $prmpt "
            PROMPT_COMMAND="builtin echo \"${p_intense}\$PWD$p_normal\${LD_PRELOAD:+*}\" >&2"
            prompt_cmd() { :; }
            cd .
        }
        # move date to before directory so it is one line closer to command
        # completion. Then when cut/paste command into a file:
        #      $ echo hi
        #      hi
        #      mm/dd hh:mm directory/path
        # I can just know that the last line is the begining of the next prompt
        p9()
        {   PS1="${NODE} $prmpt "
            PROMPT_COMMAND="builtin echo \"${p_intense}\`date +'%m/%d %H:%M'\` \$PWD$p_normal\${LD_PRELOAD:+*}\" >&2"
            prompt_cmd() { :; }
            cd .
        }
        p10()    # a 3 line prompt
        {   PS1="${NODE} $prmpt "
            PROMPT_COMMAND="builtin echo \"${p_intense}--\`date +'%m/%d_%H:%M:%S'\`--\";builtin echo \"\$PWD\${LD_PRELOAD:+*}$p_normal\" >&2"
            prompt_cmd() { :; }
            cd .
        }
        # This next prompt makes the prompt a comment command and allows
        # cut/paste from history of the prompt and command.
        p10c()    # a 3 line prompt
        {   PS1=": ${NODE} '$prmpt'; "
            PROMPT_COMMAND="builtin echo \"${p_intense}--\`date +'%m/%d_%H:%M:%S'\`--\";builtin echo \"\$PWD\${LD_PRELOAD:+*}$p_normal\" >&2"
            prompt_cmd() { :; }
            cd .
        }
        p11()    # a 3 line prompt - full date info (add year)
        {   PS1="${NODE} $prmpt "
            PROMPT_COMMAND="builtin echo \"${p_intense}--\`date +'%Y-%m-%d_%H:%M:%S'\`--\";builtin echo \"\$PWD\${LD_PRELOAD:+*}$p_normal\" >&2"
            prompt_cmd() { :; }
            cd .
        }
        p12()    # a 3 line prompt w/ $USER@
        {   PS1="$USER@${NODE} $prmpt "
            PROMPT_COMMAND="builtin echo \"${p_intense}--\`date +'%Y-%m-%d_%H:%M:%S'\`--\";builtin echo \"\$PWD\${LD_PRELOAD:+*}$p_normal\" >&2"
            prompt_cmd() { :; }
            cd .
        }
        p13() {  # a 3 line prompt w/ $USER@ and TZ
            PS1="$USER@${NODE} $prmpt "
            PROMPT_COMMAND="builtin echo \"${p_intense}\`date +'--%Y-%m-%d_%H:%M:%S_%Z--'\`\";builtin echo \"\$PWD\${LD_PRELOAD:+*}$p_normal\" >&2"
            prompt_cmd() { :; }
            cd .
        }
        p14() {  # a 3 line prompt w/ $USER@ and TZ and tty
            PS1="$USER@${NODE} `tty | sed 's|/dev/||'` $prmpt "
            PROMPT_COMMAND="builtin echo \"${p_intense}\`date +'--%Y-%m-%d_%H:%M:%S_%Z--'\`\";builtin echo \"\$PWD\${LD_PRELOAD:+*}$p_normal\" >&2"
            prompt_cmd() { :; }
            cd .
        }
        p15() {  # a 3 line prompt w/ $USER@ and TZ and tty
            PS1="`tty | sed 's|/dev/||'` $USER@${NODE} $prmpt "
            #PS1="\e[${PROMPT_COLOR}m`tty | sed 's|/dev/||'` $USER@${NODE} $prmpt\e[0m "
            #PROMPT_COMMAND="builtin echo \"${p_intense}\`date +'--%Y-%m-%d_%H:%M:%S_%Z--'\`\";builtin echo \"\$PWD\${LD_PRELOAD:+*}$p_normal\" >&2"
            PROMPT_COMMAND="builtin echo \"${p_intense}${p_color}\`date +'--%Y-%m-%d_%H:%M:%S_%Z--'\`\";builtin echo \"\$PWD\${LD_PRELOAD:+*}$p_normal\" >&2"
            prompt_cmd() { :; }
            cd .
        }
        p16() {  # a 3 line prompt w/ $USER@ and TZ and tty
            if type get_k8s_context >/dev/null 2>&1;then
                # Question: can I change my k8s_context?
                PS1="`tty | sed 's|/dev/||'` $USER@${NODE} [`get_k8s_context`] $prmpt "
            else
                PS1="`tty | sed 's|/dev/||'` $USER@${NODE} $prmpt "
            fi
            #PS1="\e[${PROMPT_COLOR}m`tty | sed 's|/dev/||'` $USER@${NODE} $prmpt\e[0m "
            #PROMPT_COMMAND="builtin echo \"${p_intense}\`date +'--%Y-%m-%d_%H:%M:%S_%Z--'\`\";builtin echo \"\$PWD\${LD_PRELOAD:+*}$p_normal\" >&2"
            PROMPT_COMMAND="builtin echo \"${p_intense}${p_color}\`date +'--%Y-%m-%d_%H:%M:%S_%Z--'\`\";builtin echo \"\$PWD\${LD_PRELOAD:+*}$p_normal\" >&2"
            prompt_cmd() { :; }
            #cd .
            test $PWD \!= $HOME && echo $PWD|grep -q ${HOME}\$ && cd
        }

        #olddir="" olddir1="" olddir2="" olddir3=""
        # "alias cd='cd_flags=$-;set -u;xcd'" and having "xcd()" do "set +u" doesnt
        # work b/c the shell bombs at the point where the unbounded variable is
        # detected and would never get to the "set +u"

        # this is b/c pushd supports ~ = $HOME, so I use this below to change
        # FULLHOME to HOME  (NOTE: must use same method here and where FULLHOME
        # is used. I.e. on some systems, bash builtin cd works with automounter
        # differently than csh -fc 'pwd;...' does. Also sh -c 'pwd;...' behaves
        # differently on different platforms -- on IRIX, it seems to know about
        # the automounter.   csh -fc seems the way to go if seeing all sym links
        # is desired
        export FULLHOME; FULLHOME=`builtin cd;/bin/pwd`

        # NOTE: if CDPATH is not set, still, as $1 must be rel (cd does expr x$1 : x/
        #       before calling cdpath), try "."
        cdpath()
        {   x=$1 # changing $1 below b/c w/globbing, $d/$x expand to several
             # parameters and that would mess up the "if [ -d "$d/$x" ..."
            for dd_ in `echo ${CDPATH-.} | sed -e 's/:/ /g'`;do
                set $dd_/$x   # This function supports globbing while builtin cd does
                        # not. An example is cd scr* when ../script exists
                # the next line will never have the additional CDPATH echo
                # b/c $1 is now (changed by "set" above) absolute (CDPATH
                # resolved)
                #if to_dir=`builtin cd "$*" 2>/dev/null && /bin/pwd | sed -e 's:^/tmp_mnt/:/:' -e "s:^$FULLHOME:$HOME:"`;then
                if to_dir=`builtin cd "$*" 2>/dev/null && pwd`;then
                    # NOTE: builtin cd/CDPATH functionality echos to stdout when
                    # CDPATH is used.
                    if [ $dd_ != . ];then echo "$*"; fi
                    return 0
                fi
            done
            return 1
        }    
        prod()
        {
            xx_re='[^~/0-9.][^/]*'
            pp=`expr "$1" : "\($xx_re\)" | tr '[a-z]' '[A-Z]'`
            if [ "$pp" ];then
                pp2='' # set to null incase of "bad substitution"
                # the function can abort if there is a "bad substitution" such
                # as trying pp2=${.._DIR:-}. I've tried to filter out invalid
                # substitutions (variable names) in the expr and if above.
                eval "pp2=\`echo \${${pp}_DIR:-}\`" 2>/dev/null
                if [ "$pp2" ];then
                    rest=`expr "$1" : "$xx_re\(.*\)"`;    # /subdir
                    if to_dir=`builtin cd "$pp2$rest" >/dev/null 2>&1 && pwd`; then
                        echo "\$${pp}_DIR$rest" >&2
                        return 0
                    fi
                fi
            fi
            return 1
        }
        in_dirs()
        {   # ~ resolution is done at the same level as globbing. Can not have it
            # in to_dir as builtin pushd doe not like it (passed in variable where
            # no "globbing" happens to resolve it).
            re=`echo "$1" | sed 's/\./\\\./g'`
            if x=`dirs | sed -e "s|~|$HOME|" | $GREP "$re"`;then
                # this should work even if multi matches -- should get 1st one
                x=`echo "$x" | head -1`
                to_dir=`expr "$x" : '[0-9]* \(.*\)'`
                return 0
            fi
            return 1
        }
        cd()
        {
            cd_opt=
            test "x${1-}" = x-P && cd_opt=-P && shift
            if [ "${1:-}" ];then
                # Watch out for links when debugging "cd ../dir"
                # It is interesting that bash builtin pwd will report
                # pwd=/home/ron/tmp when tmp is a link to /tmp; bash file complete
                # function (tab key) will then complete "ls ../scr" to
                # "ls ../script" but ls will say "No such file or directory"
                # To aviod this confusion, I will, when changing directories to
                # a link, resolve the link and pushd to, in this case, /tmp. This
                # is done by using /bin/pwd instead of pwd in the cdpath function
                # where the most of this cd'ing will be resolved (I may have to
                # change the other functions to also use /bin/pwd (somehow) but
                # then again, having no substition on an absolute path could
                # be considered a feature???)

                cd_num_sub=
                if [ "$1" = - ];then
                    to_dir=$OLDPWD  # should be the same as 1
                elif expr "x$1" : 'x/' >/dev/null;then # expr "/" ... gives Syntax error
                    #echo abs
                    # could be HOME?
                    to_dir=`builtin cd $cd_opt "$1" && pwd`
                elif cd_num_sub=`expr "$1" : '[0-9][0-9]*\(.*\)' | $EGREP '^$|^/'` \
                    && num=`expr "$1" : '\([0-9][0-9]*\)'` \
                    && expr "$num" \< 100 >/dev/null ;then
                    # allowing cd # (which is a dir #) is higher priority than
                    # cd # (which happens to be a directory)
                    # can always use ./[0-9]* if # dir wanted (instead of "dirs" #)
                    to_dir=$num
                #elif [ -d "`pwd`/$1" ];then # let pushd check -x
                #elif [ -d "$1" ];then # let pushd check -x
                #    #echo rel
                #    # do rel before cdpath so we do not print out ./dir. FIXED IN CDPATH BELOW
                #    to_dir=`builtin cd $cd_opt "$1";pwd | sed 's:^/tmp_mnt/:/:'`
                elif cdpath "$1";then
                    #echo cdpath
                    :
                elif prod "$1";then
                    #echo prod
                    :
                elif in_dirs "$1";then    # must do this now, as I do not want any
                                    # fooling around when I get below
                    echo "from dirs list" >&2
                    to_dir=`builtin cd $cd_opt "$to_dir";pwd`
                else
                    #echo error
                    to_dir=$1 # let pushd print the error
                fi
            else
                to_dir=$HOME
            fi
            cd_status=$?

            # whether to_dir is a number or a path, if its on the stack, pop first --
            # then pushd to a dir (never a number) so that pushd (no arg) always gets us back to
            # the last dir
            # most common case should be a dir (not a number) (could check if its a number 1st?)
            to_dir_re=`echo "$to_dir" | sed 's/\./\\\./g'`
            if [ $cd_status -ne 0 ];then
                : error path
            # else check if to_dir is in the list (anchoring at end-of-path via $)
            elif t=`expr "\`dirs | sed -e \"s|~|$HOME|\" | $GREP \" $to_dir_re$\"\`" : '\([0-9]* \)'`; then
                if [ $t = 0 ];then  # if 
                    builtin cd $cd_opt "$to_dir"
                    cd_status=$?
                    prompt_cmd # pushd func. does prompt_cmd; emulate it.
                    cd_num_sub=
                else
                    popd +$t      >/dev/null 2>&1; pushd "$to_dir" >/dev/null
                    cd_status=$?
                fi
            # check for number
            elif t=`expr "\`dirs | sed -e \"s|~|$HOME|\" | $GREP \"^$to_dir_re \"\`" : '[0-9]* \(.*\)'`; then
                popd +$to_dir >/dev/null 2>&1; pushd "$t"      >/dev/null
                cd_status=$?
            else
                pushd "$to_dir" >/dev/null;
                cd_status=$?
                cd_num_sub=
            fi;

            _to_dir=`csh -fc 'pwd' 2>/dev/null`     # cygwin does not supply csh
            if [ "$_to_dir" -a "`pwd`" != "$_to_dir" ];then
                echo "links resolved: $_to_dir" >&2
            fi

            if [ "$cd_num_sub" ];then
                cd `expr "$cd_num_sub" : '/\(.*\)'`
            fi

            #prompt_cmd -- prompt_cmd is done in pushd and popd
            return $cd_status
        }
        dirs()
        {
            builtin dirs -p | awk 'BEGIN {i=0}{printf "%d %s\n",i++,$0}'
            #builtin dirs | awk '{x=split($0,a," ");for(i= 0;i<x;)printf "%d %s\n",i,a[++i]}'
            #x=0
            #for d in `builtin dirs`;do
            #    echo "$x $d"
            #    x=`expr $x + 1`
            #done
        }
        pushd()
        {
            if expr "${1-}x" : '[0-9]*' >/dev/null;then	# IRIX expr can not handle expr "/" ...
                builtin pushd +"$@"
            else
                builtin pushd "$@"
            fi
            pushd_status=$?
            prompt_cmd
            return $pushd_status
        }
        pushd1() { pushd +1; }
        pushd2() { pushd +2; }
        pushd3() { pushd +3; }
        pushd4() { pushd +4; }
        # to "purge" dirs list (to 40) use: while popd +40 >/dev/null;do true; done
        popd() { builtin popd $*; popd_status=$?; prompt_cmd; return $popd_status; }
        popd1() { echo "use pushd"; }
        popd2() { echo "use pushd"; }
        popd3() { echo "use pushd"; }
        popd4() { echo "use pushd"; }

        # BASH_VERSION="3.1.17(1)-release"
        # BASH_VERSION='2.05b.0(1)-release'   # will have to ignore "b" :(
        # set | grep BASH
        if ! bv0=`expr "${BASH_VERSINFO[0]}" : '\([0-9]*\)'`;then bv0=0;fi
        if ! bv1=`expr "${BASH_VERSINFO[1]}" : '\([0-9]*\)'`;then bv1=0;fi
        if ! bv2=`expr "${BASH_VERSINFO[2]}" : '\([0-9]*\)'`;then bv2=0;fi
        bvv=`printf "%d%02d%02d" $bv0 $bv1 $bv2`
        test $bvv -ge 40229 && shopt -s direxpand
        if   [ $bvv -gt 30000 ];then
            eval "cd..() { cd ..; }"  # cd.. is not a valid name for sh. From nova.fnal.gov sh man page: A name is a sequence of ASCII letters, digits, or underscores, beginning with a letter or an underscore.
            p16  #p7      # this does a cd .
        elif [ $bvv -gt 30000 ];then
            p16  #p7      # this does a cd .
        elif [ $bvv -gt 20500 ];then
            # 2009.12.01 - bash v3 doesn't like cd.., cd..x does work.
            # 2010.08.05 - SunOS bash 2.05.0(1)-release (sparc-sun-solaris2.9)
            # does not know \D
            eval "cd..() { cd ..; }"  # cd.. is not a valid identifier for sh
            p7      # this does a cd .
        else
            # version 20500 and below
            eval "cd..() { cd ..; }"  # cd.. is not a valid identifier for sh
            p9  # this does a cd .
        fi

        eval  "l.() { /bin/ls -d .*; }" # l. is not a valid sh identifier
        eval  "type() { builtin type \"\$@\";builtin type -ap \"\$@\"; }" # eval
              # this so ksh will be able to at least parse the "if"
              # NOTE: type -a give all the places, but doesn't tell if any
              # are "hash" like type (without -a) does
        alias 132='echo "\033[?3h"'
        alias 80='echo "\033[?3l"'
        alias 80x='x=9;while x=`expr $x - 1`;do echo -n $x;y=10;while y=`expr $y - 1`;do echo -n $y;done;done;echo;x=49;while x=`expr $x - 1`;do echo $x;done'
        if [ -d $MYHOME/.bash_completion.d ];then
            for ff in $MYHOME/.bash_completion.d/*;do
                . $ff
            done
        fi
    else
        p1
    fi      # if [ "$do_bash" ];then ...  else
    unset psp # comment out for debugging

    if [ "`whoami`" = root ]; then
        lo() { exit; }
        unset HISTFILE    # avoid touching root login area
    else
        lo() { logout; }
        stopshutdown() { telinit 2; }
    fi

    askinit() { echo "try the command: runlevel"; who -r; }		#irix only
    bc() { BC_ENV_ARGS=$MYHOME/.bcrc env bc -l; }  # always define math
    burndisks() {
        test $# -eq 0 && { echo '"burndisks X [Y]..." e.g. burndisks sd{b,c}'; return; }
        sudo sh -c '
    pids=
    trap "echo trap SIGINT;test -n \"\$pids\" && kill \$pids" SIGINT
    while [ $# -gt 0 ];do
       dsk=$1; shift
       blks=`awk "/ $dsk\$/{print\\$3;}" /proc/partitions`;: 1K blks
       cnt=`expr $blks / 10000`
       test $cnt -gt 10000 && cnt=10000;: limit amount of data
       dd if=/dev/$dsk of=/dev/null bs=10M count=$cnt &
       pids="$pids $!"
    done
    wait' /bin/sh $*       # recall 1st arg to -c <cmdstr> goes to arg0
    }
    # tab completion -- "complete" is a bash shell builtin.
    # Ref. /etc/bash_completion.d/ -- which is include in, i.e., RHEL
    for cmd in cd git;do
        complete -r $cmd 2>/dev/null
    done
    # not needed: complete -r throt.sh  # remove any previous specification for throt.sh
#    comp_throt()
#    {   tot_list=`throt.sh | sed -n '/^    .*)/{s/^ *//;s/).*//;s/|/\n/;s/\*//;p}'`
#        cur_word=${COMP_WORDS[$COMP_CWORD]}
#        ret_list=`echo "$tot_list" | $GREP "^$cur_word"`
#        COMPREPLY=($ret_list);
#    }
#    complete -F comp_throt throt.sh
    # To get ("print") a list of all active completion specifications: complete -p
    # node need to print: complete -p throt.sh  # print completion specification for cmd
    if ls /etc/minirc.* >/dev/null 2>&1;then
        complete -W "`echo /etc/minirc.* | sed 's|/etc/minirc.||g'`" minicom
    fi
    # I should do a function to grab targets from [Mm]akefile
    # can't tell the difference between "-o plusdirs" and "-A directory"
    complete -o plusdirs -W "all bzImage clean install modules modules_install tbin" make
    chroot_nbd_USAGE="\
   usage: \$FUNCNAME <vdi_file> <part> <mp> [user [args]]
examples: \$FUNCNAME /mnt/md/ron/SLF7x.vdi nbd0p3 /mnt/vdi
          \$FUNCNAME /mnt/md/ron/SLF7x.vdi nbd0p3 /mnt/vdi ron bash -c 'echo \\\"hi     there\\\"'
"
    chroot_nbd() {
        : chroot qemu Network Block Device server
        test $# -lt 3 -o "${1-}" = "-h" && { eval "echo \"$chroot_nbd_USAGE\""; return; }
        vdi=$1 part=$2 mp=$3; shift 3
        test $# -ge 1 && { user=$1; shift; } || user=`whoami`
        test -f $vdi || { echo vdi file not found; return; }
        test -d $mp  || { echo mount point does not exist; return; }
        sudo modprobe nbd
        sudo qemu-nbd -c /dev/nbd0 "$vdi"
        sudo mount /dev/$part $mp
        :; sudo ~/script/chroot.sh $mp $user ${1+-c "$@"}
        sudo umount /dev/$part
        sudo qemu-nbd --disconnect /dev/nbd0
    }

    disksmart() {
        test "$1" = '-h' -o $# -eq 0 && { echo 'usage: disksmart `disks`'; return; }
        for dd in $*;do
            expr "$dd" : '/dev/' >/dev/null && disk=$dd || disk=/dev/$dd
            echo disk=$disk
            smartctl -A $disk | grep -E 'Pre-fail  *Always|Error|Warn|Crit' | grep -Ev ' (0x0|)0$|Spin_Up_Time'
        done
    }
    docker-image-ls() { # may need to change - to _ in function name. This function does ls (list source) for a given image name
        # to see functions with -, use: set | grep '^[a-zA-Z0-9_]*-[-a-zA-Z0-9_]* ()'
        image=$1; : example ubuntu:22.04; shift
        digest=$(docker image inspect $image | jq -r '.[0].RootFS.Layers[0]' | sed 's|sha256:||')
        cacheid=$(sudo cat /var/lib/docker/image/overlay2/layerdb/sha256/$digest/cache-id)
        sudo $ls_cmd /var/lib/docker/overlay2/$cacheid/diff/"$@"
    }
    
    # used the following:
: <<'EOF'
xxx() {
    do_recipe '
    # doing stuff
    echo hi; echo there \
    then
    '
}
xxx
# the output would look like (NOTE: continuation (\) and the space before it are part of the line read in):
executing: # doing stuff
executing: echo hi; echo there
hi
there then
EOF
    do_recipe() {
        recipe=$1 recipe_sts=0
        lines_total=`echo "$recipe"|wc -l` lines_read=0 multi_line= ml_expr_re='\(.*[^\]\)\\$'
        while read -r line;do # -r is "don't do escape nl (or any other escape blah) processing"
            lines_read=`expr $lines_read + 1`
            echo "$line" | grep -q '^ *$'&& continue
            ll=`expr "$line" : "$ml_expr_re"` \
                && { multi_line="${multi_line}$ll"; continue; } \
                || multi_line="${multi_line}$line"
            history -s "$multi_line"; echo "executing: $multi_line"; eval "$multi_line"; recipe_sts=$?
            if [ $recipe_sts -ne 0 ];then
                echo non-zero status. Remaining lines:
                echo "$recipe"| tail -n+`expr $lines_read + 1`
                return $recipe_sts
            fi
            multi_line=
        done <<EOF
$recipe
EOF
    }

    duats()
    {   echo "duats.gtefsd.com: access code is 10195583 pw:3p1ki (dtc's os 00131362) 800-767-9989 (dtc's 800-245-3828)"
        echo "xlats to duat2.wtp.GTEFSD.COM:131.131.7.106 or duat1.wtp.GTEFSD.COM:131.131.7.105"
        telnet duats.gtefsd.com
    }
    #functions() { set | awk '/\=\(\)/,/}/' - ; }
    functions() { set | awk '/\(\)/,/}/' - ; }
    #variables() { set | sed -e "/^[^a-z]/d" -e "/=()/d" ; }
    variables() { set | sed -e "/^[^a-z]/d" -e "/()/d" ; }
    cols() { resize|sed -n -e '/^COL/{s/.*=//;s/;//;p;}';}
    cons() { for i in "$@";do rsh fndaui -l olsadmin "csh -fc \"setenv DISPLAY $DISPLAY;setenv PATH /usr/farm/bin:$PATH;cons $i >& /usr/tmp/cons.out.\$$ &\""; done; }
    qcdcons() { for i in "$@";do ssh qcdcon1 "sh -c \"DISPLAY=$DISPLAY;export DISPLAY;PATH=/usr/farm/bin:$PATH;cons $i >/usr/tmp/cons.out.\$$ 2>&1 &\""; done; }
    cpiocp() # src dst directory copy
    { src=$1 dst=$2; shift 2
      test -d "$dst" || { echo attempt mkdir $dst >&2; mkdir -p "$dst"; echo check ownership and permissions on $dst >&2; ls -ld "$src" "$dst" >&2; }
      ( cd "$src"; find . -depth -print0 | cpio -0 -o ) | ( cd "$dst"; cpio -i --sparse -dm )
    }
    cre() { cat > "$@" ; }
    # IRIX 6.2 bash ver. 2.00 complained when semi-colon missing ------------------v
    roncvs()
    {
        if [ $# -eq 0 ];then
            echo "example co: roncvs co -d . ron/.bashrc        # may not work (use next example)"
            echo "         OR roncvs co ron/.bashrc;mv ron/{CVS,.bashrc} .; rmdir ron; cvs update .profile"
            echo "            roncvs -l co bd_vax               # do \"local\""
            echo "root should kinit ron"
            return
        elif [ "x$1" = "x-l" ];then
            shift
            cvs -d /autofs0/disk1/cvs                                              "$@"
        else
            CVS_RSH=ssh                    cvs -d ron@fnapcf.fnal.gov:/autofs0/disk1/cvs                          "$@"
        fi
    }
    rontestworkcvs() { CVS_RSH=ssh            cvs -d :ext:p-rontest@cdcvs.fnal.gov:/cvs/projects/rontest-work          "$@"; }
    bdcvs()     {                                 cvs -d ron@nova.fnal.gov:/export/cvs/micro_projects                    "$@"; }
    btevcvs()   {                                 cvs -d ron@fnsimu1.fnal.gov:/home/btev1/bphyscvs/cvs                   "$@"; } # rocket
    cdcvs()     { CVS_RSH=ssh                     cvs -d cvsuser@cdcvs.fnal.gov:/cvs/cd                                  "$@"; }
    # note: for the following, I use cvsuser where I should be using cdwebcvs
    cdwebcvs()  { CVS_RSH=ssh                     cvs -d cvsuser@cdcvs.fnal.gov:/cvs/cdweb                               "$@"; }
    cdfcvs()    {                                 cvs -d cvs@b0dau30.fnal.gov:/cdf/code/cvs                              "$@"; }
    cdf2cvs()   {                                 cvs -d cvs@b0dap72.fnal.gov:/cdf/code-IRIX-6.5/cvs                     "$@"; }
    cnscvs()    {                                 cvs -d :pserver:ron@clxsrv.fnal.gov:/export/cvs/cns                    "$@"; }
    cmscvs()    { CVS_RSH=ssh                     cvs -d ron@cmscvs.cern.ch:/cvs_server/repositories/CMSSW                   "$@"; }
    dcachecvs() { CVS_RSH=ssh                     cvs -d ron@cvs-dcache.desy.de:/home/cvs/cvs-root                       "$@"; }
    d0cvs()     { CVS_RSH=ssh                     cvs -d d0cvs@cdcvs.fnal.gov:/cvs/d0cvs                                 "$@"; }
    #d0cvs()     { CVS_RSH=ssh                     cvs -d cvsuser@d0cvs.fnal.gov:/cvsroot/d0cvs                          "$@"; }
    #dcdcvs()    {                                 cvs -d :ext:dcdcvs@dcdcvs.fnal.gov:/cvs/dcd                           "$@"; }
    dcdcvs()    {                                 cvs -d cvsuser@cdcvs.fnal.gov:/cvs/dcd                                 "$@"; }
    globuscvs()   {                                 cvs -d :pserver:anonymous@cvs.globus.org:/home/globdev/CVS/globus-packages "$@"; }
    hppccvs()   {                                 cvs -d hppccvs@cdcvs.fnal.gov:/cvs/hppc                                "$@"; }
    javacvs()   {                                 cvs -d :pserver:ron@nova.fnal.gov:/export/cvs/java                     "$@"; }
    lrepcvs()   { CVS_RSH=ssh                     cvs -d :ext:cvs@lrep.fnal.gov:/www/devel/cvsroot                       "$@"; }
    mozillacvs(){                                 cvs -d :pserver:anonymous@cvs-mirror.mozilla.org:/cvsroot              "$@"; }
    mu2ecvs()   { CVS_RSH=ssh                     cvs -d mu2ecvs@cdcvs.fnal.gov:/cvs/mu2e                                "$@"; }
    novacvs()   { CVS_RSH=ssh                     cvs -d novacvs@cdcvs.fnal.gov:/cvs/nova                                "$@"; }
    #sdss wants only ssh v1
    sdsscvs()   { CVS_RSH=/p/ssh/v1_2_27g/bin/ssh cvs -d cvsuser@sdss.fnal.gov:/cvs/sdss                                 "$@"; }
    sdss2cvs()  { CVS_RSH=ssh                     cvs -d cvsuser@sdss.fnal.gov:/cvs/sdss                                 "$@"; }
    smtfcvs()   { CVS_RSH=ssh                     cvs -d smtfcvs@cdcvs.fnal.gov:/cvs/smtfcvs                             "$@"; }
    cvs_mv()    {
        test $# -eq 2 || { echo 'usage: cvs_mv <f1> <f2>'; return; }
        mv $1 $2; test -f CVS/Entries && sed -i "s|/$1/|/$2/|" CVS/Entries;
    }
    tracecvs()  { CVS_RSH=ssh                     cvs -d :ext:p-trace@cdcvs.fnal.gov:/cvs/projects/trace                 "$@"; }
    tracesvn()  { svn co svn+ssh://p-trace@cdcvs.fnal.gov/cvs/projects/trace-svn/trunk trace; }
    tracesvn_export()  { svn export https://cdcvs.fnal.gov/subversion/trace-svn/trunk trace; }
    gitron() { : "use from root (access to ~ron/.ssh/id_rsa); May need -Jron@outback.fnal.gov (and kinit ron) when on accelerator network."
               GIT_SSH_COMMAND="ssh -oIdentityFile=~ron/.ssh/id_rsa" git "$@";}
    tracegit()  { git clone ssh://git@github.com/art-daq/trace.git; }
    trace-combined() { git clone ssh://git@github.com/art-daq/trace.git trace-combined
                       cd trace-combined
                       rm -rf * .gitignore .clang-format
                       svn co svn+ssh://p-trace@cdcvs.fnal.gov/cvs/projects/trace-svn/trunk .
                     }
    tfcvs()     { CVS_RSH=ssh                     cvs -d :ext:tfcvs@maxwell.phys.ufl.edu:/maxwell/user4/tfcvs/Repository "$@"; }
    doocscvs()  { CVS_RSH=ssh                     cvs -d :ext:ron@mvplab1.desy.de:/doocs/doocssvr1/cvsroot          "$@"; }
    fnapcfRlycvs(){ CVS_RSH=ssh-relay.sh          cvs "$@"; }
    smtfdoocscvs(){ RELAYRMTRSH=ssh CVS_RSH=ssh-relay.sh cvs -d :ext:ron@mvplab1.desy.de:/doocs/doocssvr1/cvsroot   "$@"; }
    homcvs()    { CVS_RSH=ssh                     cvs -d ttflinac@ttfsvr5.desy.de:/home/ttflinac/HOM/HOM_CVS_Repository "$@"; }
    wrscvs()    {                                 cvs -d wrscvs@cdcvs.fnal.gov:/cvs/wrs                                  "$@"; }
    cvsups()    { CVS_RSH=ssh                     cvs -d cvsuser@cdcvs.fnal.gov:/cvs/cd             "$@"; }
    # the forwarding of ticket DOES seem to be needed for check-ins!
    cvsMainDiff()
    {   if [ ! "$1" ];then
            echo 'usage: cvsMainDif file [options]'
            echo '       example: for i in *.c;do cvsMainDiff $i -r bp_sdss;done'
            echo 'This function is obsolete. There is a "HEAD" tag that can be'
            echo 'used instead: cvs diff -rHEAD [file...]'
            return
        fi
        file=$1;shift
        cvs -q diff -r `cvs -q log -h $file | sed -e 's/^head: //p' -e d` $@ $file
    }
    datedir() { date +'AD%Y-%m-%d'; }
    dateutc() { echo Here is UTC$(expr `date +%H` - `TZ=UTC date +%H`); TZ=UTC date +'AD%Y-%m-%d_%H:%M:%S_%Z--'; }
    disks() { grep -E -o '[hs]d[a-z]$|nvme[0-9]n[0-9]$' /proc/partitions; }
    diskstat()
    {   disks=`disks`
        for dd_ in $disks;do sudo hdparm -C /dev/$dd_; done
    }
    disp()
    {
        t=
        i="${1:-}"
        # := sets in sh, but not in bash
        if [ "${DISPLAY:=}" = "" ];then DISPLAY=;export DISPLAY
        else echo "current DISPLAY=$DISPLAY"; fi
        while [ "$t" = "" ]; do
            if [ "$i" = "" ];then
                echo ""
                echo "DISPLAY MENU"
                echo "	<ret>		\$DISPLAY      (\$DISPLAY=$DISPLAY)"
                echo "	[a-z]		fndax[a-z].fnal.gov:0"
                echo "	[a-z][a-z]	fnda[a-z][a-z].fnal.gov:0"
                echo "	[0-9]		t-s-modem:200[0-9]"
                echo "	[0-9][0-9]	t-s-modem:20[0-9][0-9]"
                echo "	[0-9]*		t-s-modem:[0-9]*"
                echo "	*:*		*:*"
                echo "	*		*:0"
                echo "enter selection: \c"
                read i
            fi
            case $i in
            "")         t=$DISPLAY;;
            [a-z])      t=fndax$i.fnal.gov:0;;
            [a-z][a-z]) t=fnda$i.fnal.gov:0;;
            [0-9])      t=t-s-modem:200$i;;
            [0-9][0-9]) t=t-s-modem:20$i;;
            *:*)        t=$i;;
            [0-9]*)     t=t-s-modem:$i;;
            *)          t=$i:0;;
            esac
        done
    
        DISPLAY=$t
        echo ""
        echo "export DISPLAY;DISPLAY=$DISPLAY"
        echo ""

        unset i t
    }
    # I think that it's really the X server that needs to be negatively niced
    #   - actually, disper needs to be fixed (made more aware of the xserver
    #     communications protocol)
    dispDFP0() { nice -n-20 /p/disper/v0_2_3/bin/disper --single; }
    dispDFP1() {  nice -n-20 /p/disper/v0_2_3/bin/disper --displays=DFP-0,DFP-1 --extend --direction=top; }
    dispDFP2()
    { echo 'backend: nvidia
      associated displays: DFP-0, DFP-1
      metamode: DFP-0: 1920x1200 @1920x1200 +0+1200, DFP-1: 1920x1080 @1920x1200 +0+0
      scaling: stretched, stretched'\
      | nice -n-20 /p/disper/v0_2_3/bin/disper -i
    }
    dispCRT0() { nice -n-20 /p/disper/v0_2_3/bin/disper --displays=DFP-0,CRT-0 --clone; }
    dist() { : can quote multiple files in $1; file=$1;shift;for i in $*;do rcp $file $i:; done; }
    df-h() { df -hT "$@" | grep -E "File|^/dev" | # | grep -v boot
             awk '/^File/{print;size_idx=index($0,"Size");next}
{for(i=0;i<3;++i){
  mult=substr($(3+i),length($(3+i)),1)
  switch(mult){
  case "T": tot[i]+=$(3+i)*1000.0;break
  case "M": tot[i]+=$(3+i)/1000.0;break
  case "G": tot[i]+=$(3+i)*1;     break
  default:  tot[i]+=$(3+i)/1000000.0
  }
 }
 print
}
END{printf("%*stots: %4.0fG %4.0fG %4.0fG %3.0f%% \n",size_idx-8,"",tot[0],tot[1],tot[2],tot[1]/tot[0]*100)}
'
           }
    disk-by-id() {
        : 'optional "disk" (e.g. sda$ OR mmcblk.$)'
        test -n "$1" && disk_re=$1 || disk_re='(sd[a-z]|nvme[0-9]n[0-9]|mmcblk[0-9])'
        /bin/ls -FlhG /dev/disk/by-id | grep -E "$disk_re" | sort -k10
    }
    # NAME        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS FSUSE% FSTYPE            LABEL         UUID
    # nvme1n1     259:8    0 476.9G  0 disk                                                        
    # ├─nvme1n1p1 259:10   0   320G  0 part  /home          80% ext4                            f9bf91c0-e3cc-4a6b-8881-b6b95c435bc1
    # │                                      /mnt/disk1                                            
    # └─nvme1n1p2 259:11   0 156.9G  0 part                     linux_raid_member ronlap77:0    6069000a-ed0e-19bf-e717-1f645810af8d
    #   └─md0       9:0    0 313.6G  0 raid0 /mnt/md        94% xfs                             e8b4d08f-f18e-499b-91b7-74cf6171ccc6
    lsblk-o() {
        if [ -z "${lsblk_cols-}" ];then
            ere='^ *(FSUSE%)'   # ID-LINK uses "shortest" name; this is not what I want :(
            lsblk_cols=`lsblk --list-columns 2>/dev/null|grep -Eo "$ere" || lsblk --help|grep -Eo "$ere"`
            lsblk_cols=`echo $lsblk_cols|tr ' ' ,`
            lsblk_cols="${lsblk_cols:+$lsblk_cols,}FSTYPE,LABEL"   # ",UUID" UUID make lines too long
        fi
        # what if lsblk_cols=' ' ????
        lsblk -o+$lsblk_cols "$@" |
            awk '/^NAME/{print;size_idx=index($0,"SIZE");next}
{if(index($0,":") && index($0," /")){ # lines with mounted disks
  majmin=gensub(/^.* ([0-9]*:[0-9]*) .*/,"\\1",1)
  if(! (majmin in devices)){
   sz=gensub(/^.* ([0-9.]*[0-9][GMT]) .*/,"\\1",1)
   mult=substr(sz,length(sz),1)
   switch(mult){
    case "T": tot+=sz*1000.0;break
    case "M": tot+=sz/1000.0;break
    default:  tot+=sz*1
   }
   devices[majmin]
  }
 }
 print
}
END{printf("%*s %4.0fG\n",size_idx-3,"mounted disk total:",tot)}
'
              }
    # python version does it in 3 fewer lines.  Uses "match" statement which is new in version 3.10.
    lsblk2() {
        if [ -z "${lsblk_cols-}" ];then
            ere='^ *(FSUSE%)'   # ID-LINK uses "shortest" name; this is not what I want :(
            lsblk_cols=`lsblk --list-columns 2>/dev/null|grep -Eo "$ere" || lsblk --help|grep -Eo "$ere"`
            lsblk_cols=`echo $lsblk_cols|tr ' ' ,`
        fi
        lsblk -o+${lsblk_cols:+$lsblk_cols,}FSTYPE,LABEL,UUID "$@" |
            python3 -c '
import sys
tot=0; raids=[]
for line in sys.stdin:
    print(line,end="")
    if   line.find("NAME")==0: size_idx=line.find("SIZE"); maj_idx=line.find("MAJ")
    else:
        words=line[maj_idx:].split()  # skip past potentially confusing "NAME" with first word "|" (Note: split will work with whitespace at beginning)
        if len(words) >= 6 and words[5][0] == "/" and (words[4][:4]!="raid" or words[0] not in raids): # lines with mounted disks
            if words[4][:4] == "raid": raids.append(words[0]) # the MAJ:MIN of the particular md* device
            match words[2][-1]:
                case "T": tot+=float(words[2][:-1])*1000.0
                case "M": tot+=float(words[2][:-1])/1000.0
                case   _: tot+=float(words[2][:-1])  # assume "G"
print("%*s %4.0fG"%(size_idx-2,"mounted disk total:",tot))
'
        }
    dman() { termsave=$TERM TERM=dumb ; man "$@" ; TERM=$termsave; unset termsave ; }
    # echo new lines b/c xterm don't save cleared screen data like dxterms do
    ede() { x="\012\012\012\012"; y=$x$x; echo $y$y$y$y$y$y$y$x; emacs -u $RONUSER -nw "$@"; }
    setinfo()
    {
        case $node in
        [0-9]*)
            node=`nslookup $node | sed -e '/Name.*/ !d' -e 's/Name: *//'`;;
        esac
        info=`echo "set q=hinfo\n\$node" | nslookup 2>/dev/null | \
            sed -e '/CPU/ !d' -e 's/.*CPU *= *//' -e 's/[ 	]*OS.*//'`
        dbinfo=`xrdb -symbols`	# different OS xrdb behave differently --
        dbinfo=`echo $dbinfo`	# make sure it is all one line
        vendor=`expr "$dbinfo" : '.*-DVENDOR=\("[^"]*"\)'`
        class=`expr "$dbinfo" : '.*-DCLASS=\([^ 	]*\)'`

        case $class in
        *Color*)
            echo -n "color emacs on "
            ;;
        *)
            echo -n "black and white emacs on "
            color=;;
        esac

        case $vendor in
        *Sun*)
            echo SUN.
            info=SUN;;
        *"Network Computing Devices Inc"*)
            if xmodmap -pm | grep -E 'Control_R \(0x58\)|Control_L \(0x14\)' >/dev/null;then
                echo NCD - AT style.
                info=NCD-AT
            else
                echo NCD.
                info=NCD
            fi;;
        *"Silicon Graphics"*)
            echo SGI.
	    # the 4d35 does not have EXT_GLX set and a CRIMSON does
            info=SGI`expr "$dbinfo" : '.*-D\(EXT_GLX\)'`;;
        *"Tektronix, Inc."*)
            echo $vendor
            info=TEK;;
        *"The XFree86 Project, Inc"*|*"The X.Org Foundation"*)
            approxKeys=`echo \`xmodmap -pk | sed -e '/^ *[0-9]*[ 	]*$/d' -e '/^ *[a-zA-Z]/d' | wc -l\``
            info=PC-$approxKeys
            echo Linux on an XFree $info;;
        *"Xi Graphics"*)
            echo Linux on a PC running Xi Graphics
            info=PC-Xi;;
        *DECWINDOWS*UNIX*)
            echo DECWINDOWS on a PC?
            approxKeys=`echo \`xmodmap -pk | sed -e '/^ *[0-9]*[ 	]*$/d' -e '/^ *[a-zA-Z]/d' | wc -l\``
            info=PC-$approxKeys;;
        *)
            echo "don't know. vendor string is \"$vendor\""
            echo "Warning: don't know display machine (keyboard) type";;
        esac
    }
    edew()
    {
        echo "on ronlapProMax: EMACS=emacs-gtk+x11 edew -fn 'Source Code Pro:style=Regular' ${1-[file]}"
        # how to tell what type of keyboard -- home, work{sun,sgi,ncd}
        # how to work with DISPLAY var of form host:x.y when x or y are not 0
        # info=`xset q`
        # nslookup on SUN is different than SGI - not supprisingly

        color="-fg yellow -bg black -cr red -ms red"
        case "${DISPLAY:-}" in
        "")
            echo DISPLAY: Undefined variable.
            return;;
        :0 | :0.0)
            node=`hostname`
            #DISPLAY=$node$DISPLAY	# only needed if rsh'ing; leave to "localhost"
            # for laptop for when node/host name can change.
            setinfo;;
        fnstar.* | sdssmth.*)
            info=SGI;;
        marmot.apo.nmsu.edu:0.0)
            info=SUN;;
        *:0 | *:0.0)
            node=`expr "$DISPLAY" : '\(.*\):.*'`
            setinfo;;
        *:*[1-9]*)
            #echo assuming NCD
            #color=""
            #info=NCD
            node=`hostname`
            setinfo
            ;;
        wayland-[0-9]*)
            DISPLAY=:`expr "${DISPLAY:-}" : 'wayland-\(.*\)'`;;
        *)
            echo DISPLAY = $DISPLAY, format not expected
            return;;
        esac
        if [ "$info" = "" ];then
            #return
            #echo assuming NCD for $DISPLAY
            #info=NCD
            #color=""
            info=
        fi

        case "$info" in
        NCD-AT)
            xmodmap -e 'clear Mod4' \
                -e 'keycode 0x76 = KP_F1'
    #   	-e 'keycode 100  = apLineDel' \
    #   	-e 'keycode 102  = Delete'
            ;;
        NCD)
            # keycode 38 = 3 sterling on some ncd's, which is bogus
            xmodmap -e 'keycode 0x9 = quoteleft asciitilde' \
                -e 'keycode 38  = 3 numbersign' \
                -e 'keycode 0xe = Escape asciitilde' \
                -e 'keycode 0x41 = comma less' \
                -e 'keycode 0x49 = period greater';;
        SUN)
            echo "warning: haven't determined my keys for $info yet";;
        SGI*)
            # switch F1 and Num_Lock around ... emacs doesn't see NumLock??
            # a "switch" needs to happen so that future invocation do not bomb on the remove command
            # use xmodmap -pm to print the modifier map
            echo "making F1 NumLock and NumLock F1 and removing ScrollLock"
            xmodmap -e 'remove Mod2 = Num_Lock' \
                -e 'remove Mod3 = Scroll_Lock' \
                -e 'keycode 94 = Num_Lock' \
                -e 'keycode 114 = F1' \
                -e 'add mod2 = Num_Lock';;
        PC-114)
            # laptop keycode - prntscrn=111 numlk=77 pause=110
            # F1-F10=67-76, respectively, F11=95 F12=96
            # when make the .tpu*-keys file:
            # FP1/gold=Numlk FP2/help=Fn/ FP3/find=Fn* FP4/DelLn=Fn-
            # KPDelChr=ShftFn+ KPEnter=ShftEnter
            # F13/DelPrvW=F3 F14/Ovr=F4 Help=PF2=Fn/  Command=Pause  F17=F5
            xmodmap -e 'remove mod2 = Num_Lock' \
                -e 'keycode 77 = KP_F1' \
                -e 'keycode 67 = Num_Lock' \
                -e 'add mod2 = Num_Lock'
            ;;
        PC-111)
            echo "PC-111"
            echo "making F1 NumLock and NumLock KP_F1 - make sure NumLock light is off"
            # also need to reassign the "above the cursor keys del key" b/c
            # it is the same as the "above the Enter key delete key"
            xmodmap -e 'remove Mod4 = Num_Lock' \
                -e 'keycode 118 = KP_F1' \
                -e 'keycode 9 = Num_Lock' \
                -e 'add mod4 = Num_Lock' \
                -e 'keycode 39 = F7' \
                -e 'keycode 47 = F8' \
                -e 'keycode 55 = F9' \
                -e 'keycode 63 = F10' \
                -e 'keycode 71 = F11' \
                -e 'keycode 79 = F12' \
                -e 'keycode 86 = F13' \
                -e 'keycode 94 = F14' 
        	# -e 'keycode 22 = Delete'  # does not effect .tpu-gnu-keys,
                                            # but nice to have anyway.
            ;;
        PC-105)
            echo "$info i.e. beams division PC in Sharon Lackey's office"
            xmodmap -e 'keycode 77 = KP_F1'
            ;;
        PC-10[1234])
            echo "$info"
            info=PC-103;  # make sure we get the right file
            echo "making F1 NumLock and NumLock KP_F1 - make sure NumLock light is off"
            # also need to reassign the "above the cursor keys del key" b/c
            # it is the same as the "above the Enter key delete key"
            #xmodmap -e 'remove Mod2 = Num_Lock' \
            #	-e 'keycode 77 = KP_F1' \
            #	-e 'keycode 67 = Num_Lock'  # move to F1
            #xmodmap -e 'add mod2 = Num_Lock' \
            #	-e 'keycode 107 = apLineDel' # "Delete" above cursor keys
            #xmodmap -e 'keycode 111 = Help' # Print Scrn (above insert above cursor keys
            #xmodmap -e 'keycode 78 = Menu' # Scroll Lock
            #xmodmap -e 'keycode 71 = F7' # F5
            #xmodmap -e 'keycode 72 = F8' # F6
            #xmodmap -e 'keycode 73 = F9' # F7
            #xmodmap -e 'keycode 74 = F10' # F8
            #xmodmap -e 'keycode 75 = F11' # F9
            #xmodmap -e 'keycode 76 = F12' # F10
            #xmodmap -e 'keycode 95 = F13' # F11
            #xmodmap -e 'keycode 96 = F14' # F12
    	    #xmodmap -e 'keycode 22 = Delete'  # "<-- Backspace or BackSpace"
            ;;
        PC-106)    # macbook pro
            xmodmap -e 'keycode 59 = Delete'
            ;;
        PC-Xi)
            echo "making Pause/Break NumLock and NumLock KP_F1 - make sure NumLock light is off"
            echo "There currently is a problem here in that in non-numlock mode the arrow"
            echo "keys and the keys above them get are the same as the keys on the keypad"
            echo "i.e. 4=Left, 6=Right, 8=Up, and 2=Down, etc."
            echo "I have not figured out the best solution -- leaning toward needed to"
            echo "use shift with the keypad, but for now....  PUNT! (sorry)."
            return
            xmodmap -e 'remove Mod2 = Num_Lock' \
                -e 'keycode 77 = KP_F1' \
                -e 'keycode 127 = Num_Lock'
            ;;
        TEK)
            # Num_Lock (keycode 126) is not in the modifier map, so I do not
            # have to do a 'remove Mod...'   Just change it to KP_F1.
	    # The function keys, F5-F12 are mapped to F7-F14
            xmodmap -e 'keycode 126 = KP_F1' \
                -e 'keycode 47 = F7' \
                -e 'keycode 55 = F8' \
                -e 'keycode 63 = F9' \
                -e 'keycode 71 = F10' \
                -e 'keycode 79 = F11' \
                -e 'keycode 87 = F12' \
                -e 'keycode 94 = F13' \
                -e 'keycode 102 = F14'
            ;;
        *)
	    # I should get here - ln will probably error?
            echo "don't know this system $info yet";;
        esac
        if [ -f $MYHOME/.tpu-gnu-keys.$info ];then
            /bin/cp -p $MYHOME/.tpu-gnu-keys.$info $HOME/.tpu-keys
            /bin/cp -p $MYHOME/.tpu-gnu-keys.$info $HOME/.tpu-gnu-keys
            /bin/cp -p $MYHOME/.tpu-gnu-keys.$info $HOME/.tpu-lucid-keys
            # if ln were used, chmod would chmod for both files (at least on SGI)
            chmod 666 $HOME/.tpu-keys $HOME/.tpu-gnu-keys $HOME/.tpu-lucid-keys
        else
            echo "file $MYHOME/.tpu-gnu-keys.$info not found."
            if [ -f $HOME/.tpu-keys -o -f $HOME/.tpu-gnu-keys -o -f $HOME/.tpu-lucid-keys ];then
                echo "the files:" $HOME/.tpu*-keys "exist. But which one is used depends on which emacs..."
                echo -n "do you want me to try to remove them (R) or let them be? "; read ans
                if [ "$ans" = R ];then rm -f $HOME/.tpu*-keys; fi
            else
                echo "no $HOME/.tpu*-keys exists, expect to create."
            fi
        fi

        # rsh-ing will get rid of the vt-toggle affecting the screen from which
        # emacs was invoked, but you loose your (compile) environment
        #    rsh `hostname` "csh -fc 'setenv DISPLAY $DISPLAY; sh -c \
        #	\"PATH=/usr/local/bin:\$PATH; . /usr/local/etc/setups.sh; setup emacs; \
        #	cd `pwd`; emacs -font fixed $color $@ &\"  >&/tmp/edew.out '"
        # start emacs - redirect output to avoid xterm window 80/132 change
        # add -display so it is visible in ps output
        # At home, "$@" shows ups as '' (seen when set -x) and emacs complains:
        # "Option `' is ambiguous" and then aborts. So I use "${@:+$@}"
        if [ -n "${EMACS-}" ];then     : EMACS=$EMACS
        elif hash emacs 2>/dev/null;then EMACS=emacs
        else                             EMACS=xemacs; fi
        LD_LIBRARY_PATH= $EMACS -display $DISPLAY -name emacs:$USER@`hostname` -u $RONUSER -font fixed\
            $color "${@:+$@}" >/dev/null &
        # -iconic $color "${@:+$@}" >/dev/null &
    }
    edewf() { : f is for font; edew -fn 'Source Code Pro:style=Regular' "$@"; }
    edewr() { edew -u $RONUSER -f read-only-emacs "$@"; }
    edex() { xemacs "$@" & }
    efind() { printenv | grep -E "$@" ; }

    if type pstree >/dev/null 2>&1;then
        descendants()
        {   xx=`pstree -lp $1`
            echo "$xx" | sed -n 's/[^()]*(\([0-9]*\))/\1\
/g;H; ${ x; s/^\n*//;s/\n*$//;s/\n\n/\n/g;p;}'
        }
    elif type ptree >/dev/null 2>&1;then
        descendants()
        {   pid=$1
            xx=`ptree $1`
            echo "$xx" | sed -n "/^ *$pid / { s/^ *//; s/ .*//; p
            }
            : rest
            /$pid/,$ { n; s/^ *//; s/ .*//; p; b rest
                     }"
        }
    else
        echo "warning: cannot determine descendants" 2>&1
        descendants() { echo $1; }
    fi

    ether2ifmod() {
        test "$1" = '-h' && { echo "usage: ${FUNCNAME[0]} [pcidev]..."; return; }
        test $# -gt 0 && pcidevs=$* \
                || pcidevs=`lspci | grep -i ethernet | awk '{print$1}'`
	echo "View: \"PCI Bus\" (lspci | grep -i ethernet | awk '{print\$1}')"
	fmt="%14s %14s %9s %19s\n"
	printf "$fmt" PCI_ID netif driver "____IP(s)____"
        for pci in $pcidevs;do
		# dpdk uses vfio-pci driver. ../vfio-dev does not exist in most systems
            netif=`/bin/ls -l /sys/class/{net,vfio-dev} 2>/dev/null |grep $pci |awk '{print$9}'`
            if expr "$netif" : 'vfio[0-9]' >/dev/null;then
                module=`lspci -k -s $pci | awk '/driver/{print$NF}'`
                #module=`basename $(readlink /sys/class/vfio-dev/$netif/device/driver)`
                ips=
            else
                module=`ethtool -i $netif | awk '/driver/{print$2}'`
                ips=`ip addr show $netif | awk '/inet /{print$2}'`
            fi
            printf "$fmt" $pci $netif $module $ips
        done
	echo; echo View: /sys/class/net/
	fmt="%14s %14s %9s %9s %14s %9s %9s\n"
	printf     "$fmt"  inf   device   dev_id   dev_port    ifalias   speed  module
	for inf in `/bin/ls /sys/class/net/`;do
	    device=`readlink /sys/class/net/$inf/device`
	    test -n "$device" && device=$(basename $device)
	    dev_id=`cat /sys/class/net/$inf/dev_id`
	    dev_port=`cat /sys/class/net/$inf/dev_port`
	    ifalias=`cat /sys/class/net/$inf/ifalias`
	    speed=`cat /sys/class/net/$inf/speed 2>/dev/null`
	    module=`readlink /sys/class/net/$inf/device/driver/module 2>/dev/null`
	    test -n "$module" && module=$(basename $module)
	    printf "$fmt" $inf "$device" $dev_id "$dev_port" "$ifalias" $speed "$module"
	done
    }

    ifconfig_() { ifconfig |grep -Ei "^[^ ]|inet|$ETHERMAC_ERE"; }
    ipaddr()    { ip addr  |grep -Ei "^[^ ]|inet|$ETHERMAC_ERE"; }

    joblist_()
    {
        ps=`/bin/ps`
        ps=`echo "$ps" | grep -E -v "^ *($$|PID) | ps$"`
        if [ "$ps" ];then echo "$ps"
        else              return 1; fi
    }
    joblist()
    {
        if [ "${active_active-}" ];then
            jl=`joblist_` # can not run in pipeline :(
            if active_job=`echo "$jl" | $GREP "while sleep.*echo -n '"`;then
                pid=`expr "$active_job" : '\[[0-9]*\]. *\([0-9]*\)'`
                echo "killing \"active\" job pid=$pid"
                builtin kill `descendants $pid`
                sleep 1;echo
            fi
        fi
        while joblist_;do
            echo -n 'kill ?(pid): ';read ans
            if [ "$ans" ];then
                # kill %$ans or eval kill %$ans for some reason does not work.
                kill `descendants $ans`
                sleep 1
            else
                echo breaking
                break
            fi
        done
    }

    # b/c I can not abort a builtin exit in .bash_logout, I have to move all that here:
    uname -v | grep -i debian >/dev/null || eval 'exit() { if joblist;then builtin exit;fi; }'
    logout() { if . joblist.sh;then builtin logout;fi; }
    faketty() { script -qfec "$(printf "%q " "$@")" | cat; }  # faketty ls --color=auto | head # NOTE: cat helps buffer all script/command output so script isn't killed before it gets tty back in good state.
    findfun() { if [ ! "${1-}" ];then echo "findfun <func_re>"; else find . -iname '*.[ch]' -o -iname '*.[ch][px][px]' | xargs plgrep -mn "(^|[^a-zA-Z_])$1\s*\([^;&>+]*$" | less; fi; }
    findsource() # ex: find_source DCMApplication | xargs grep 'include.*Eve'
    {   name=
        name="$name           '*.c' -o -iname '*.cc' -o -iname '*.cpp' -o -iname '*.cxx'"
        name="$name -o -iname '*.h' -o -iname '*.hh' -o -iname '*.hpp' -o -iname '*.hxx'"
        name="$name -o -iname '*.cu' -o -iname '*.cuh'"
        name="$name -o -iname '*.py' -o -iname '*.ipynb'"
        aft_opts=
        filt="$GREP -v /CVS/"
        while expr "${1-}" : - >/dev/null;do
            case "${1-}" in
                --no-test)  filt="grep -E -v 'test/|/CVS/'";     shift;;
                --no-unit*) filt="$filt | $GREP -v '/unit'";shift;;
                --test)     filt="$filt | grep -E test/";        shift;;
                --cc)       name="'*.cc'";                     shift;;
                -print0)    filt=cat aft_opts=-print0;         shift;;
                    *)      break;;
            esac
        done
        eval "find $* \\( -iname $name \\) $aft_opts" | eval $filt
        unset name
    }
    fermi() { mv -f $MYHOME/.nofermi $MYHOME/.nofermi~; . .profile; }
    firefox()
    {   : MOZ_PLUGIN_PATH can be used specify additional places to look for plugins
        : ff v1.5 would need the "-P" option in addition to MOZ_NO_REMOTE
        : java web-start via config app of .jnlp files = /p/java/v5_02/jdk/bin/javaws
        if [ `uname -m` = x86_64 ];then
            MOZ_NO_REMOTE=1     setarch i386 firefox "$@" >|/tmp/firefox.out 2>&1 &
        else
            env MOZ_NO_REMOTE=1              firefox "$@" >|/tmp/firefox.out 2>&1 &
        fi
        sleep 1
        mv /tmp/firefox.out /tmp/firefox.${!}.out
    }
    firefox64()  # allows 64bit java plugin "icedtea"
    {   env MOZ_NO_REMOTE=1              firefox "$@" >|/tmp/firefox.out 2>&1 &
        sleep 1
        mv /tmp/firefox.out /tmp/firefox.${!}.out
    }
    firefox_profiles()
    {   case `uname` in
        Darwin) profiles_dir="Library/Application Support/Firefox";;
        Linux)  profiles_dir=".mozilla/firefox";;
        *) echo uname=`uname` not configured;return;;
        esac
        sed -n -e '/^Name=/{s/^Name=//;p;}' "$HOME/$profiles_dir"/profiles.ini
    }
    firefox_complete() { local IFS=$'\n'; COMPREPLY=($(compgen -W "$(firefox_profiles)" -- ${COMP_WORDS[$COMP_CWORD]})); }
    complete -F firefox_complete firefox
    # foreach_lst $PRODUCTS 'ls -d $ll/D*'
    foreach_lst() { lst=$1;shift;for ll in `echo $lst|tr : ' '`;do eval "$@";done; }
    gittags() { git log --tags --pretty=format:'%ai %h %d %s' --date-order | grep 'tag: '; }
    gitlog() { git log --graph --decorate --abbrev-commit --color "$@"; }  # add --color to keep color when: gitlog | head
    gitlogall() { git log --graph --decorate --abbrev-commit --all "$@"; }
    gitlogbranch() { git log develop..`git status | awk '/^On branch/{print$3}'` --no-merges; }
    gitstatus() { test "$1" = -h && { echo 'example: gitstatus artdaq*'; return; }
                  test $# -eq 0 && dirs=`find .    -maxdepth 5 -type d -name .git -exec dirname \{} \;` \
                                || dirs=`find "$@" -maxdepth 5 -type d -name .git -exec dirname \{} \;`
        for dd in $dirs;do
            cd $dd >/dev/null; gitout=`git status 2>&1`
            echo "$gitout" | grep -q 'not a git repository' && { cd -; continue; }
            echo "$gitout" | grep -q 'On branch develop' && echo "$gitout" | grep -q 'working tree clean' && { cd -; continue; }
            echo === $dd ===; echo "$gitout"
            cd -
        done | grep -E 'On branch|modified:|^===' -C1000
    }
    gitbranch() { test "$1" = -h && { echo 'example: gitbranch artdaq*'; return; }
        test $# -eq 0 && dirs=`find . -maxdepth 3 -type d -name .git -exec dirname \{} \;` || dirs="$@"
        test -z "$dirs" && dirs=.
        for dd in $dirs;do
            cd $dd >/dev/null; gitout=`git branch -a 2>&1`
            echo "$gitout" | grep -q 'not a git repository' && { cd -; continue; }
            echo === $dd ===; echo "$gitout"
            cd -
        done | grep -E 'On branch|modified:|^===' -C1000
    }
    gitcmd() { test "$1" = -h -o $# -eq 0 && { echo 'example: gitcmd branch -a \| grep db_integ'; return; }
        dirs=`find . -maxdepth 3 -type d -name .git -exec dirname \{} \;`
        for dd in $dirs;do
            cd $dd >/dev/null; gitout=`git status 2>&1`
            echo "$gitout" | grep -q 'not a git repository' && { cd -; continue; }
            echo === $dd ===
            eval "git $@"
            cd -
        done
    }
    uups() { if [ -r /usr/local/etc/setups.sh ];then . /usr/local/etc/setups.sh; . $MYHOME/fermi.ups.sh; fi; }
    upslist() { ups list -aK+:PROD_DIR_PREFIX "$@" | sort -V; }
    flags() { echo $- ; }
    rgrep() { pgrep "$@" `/bin/ls -1 ../src/*.c ../include/*.h|$GREP -v "$@"` ; }   # search for References of, i.e., dscLine in files (except dscLine.[ch])
    sgrep() { pgrep "$@" ../src/*.c ../src/dsc.msg ../include/*.h ../etc/*.tcl ../bin/iccConf*[^~] ../../run[01] ../../run[01]-*[^~]; } # search Source files
    tgrep()  { if [ "${ASTRODA_DIR:-}" ];then awk '/trace philosophy/,/traceInit/' $ASTRODA_DIR/bin/iccConfig;fi; echo "levels used - "; grep TRACE "$@" | sed -e 's/.*TRACE[0P]* *( *//' -e 's/,.*//' | sort -nu; }; : display Trace levels used
    tgrepc() { if [ "${ASTRODA_DIR:-}" ];then awk '/trace philosophy/,/traceInit/' $ASTRODA_DIR/bin/iccConfig;fi; echo "levels used - "; grep TRACE "$@" | sed -e 's/.*TRACE/TRACE/' | sort -n +1; }; : display Traces used w/ Context
    hh()	# needs to be function b/c it is recursive and has state
    {   #  example: search for where stdin is declared:
        #      hh stdin this.c
        #
        unset hh_verbose
        if [ "$1" = "-v" ];then hh_verbose="-v"; shift; fi
        if [ "$1" = "-I" ];then
            inc_dir=$2;shift 2
        else
            if [ ! "${inc_dir-}" ];then inc_dir=/usr/include; fi
        fi

        grep "$1" "$2" /dev/null
        if [ $? = 1 -a "${hh_verbose-}" = "-v" ];then echo searched $2;fi

        if [ ! "${3-}" ];then	# check recursive arg to see if first time
            files=" $2 "
        else
            files="$files $2 "	# this gaurds against cycles in headers
        fi

        for f in `$GREP '^#[ 	]*include' "$2" | sed -e 's/^[^"<]*["<]//' -e 's/[">].*$//'`;do
            for i in $inc_dir;do
                if echo "$files" | grep " $i/$f ">/dev/null;then
                    continue 2		# skip if already searched
                fi
            done
            file=
            for i in $inc_dir;do
                if [ -f $i/$f ];then
                    file=$i/$f
                    break
                fi
            done
            if [ ! "$file" ];then continue; fi
            hh ${hh_verbose-} "$1" $file 1	# recursive -- add 3rd param
        done
    }
    h()    { HISTTIMEFORMAT="%a %m/%d %H:%M:%S  " history "$@"; } # NOTE: history get defined to this if "h" is an alias, make sure to UNALIAS h
    hist() { HISTTIMEFORMAT="%a %m/%d %H:%M:%S  " history "$@"; }
    hfind() { history | grep -E "$@"; }
    histclear() { tmp=$HISTSIZE; HISTSIZE=0; HISTSIZE=$tmp; }
    histwrite() { history -w; }
    histjump()
    {   HISTTIMEFORMAT="%a %m/%d %H:%M:%S  " history | perl -ne 'use Time::Local;
if (/^( *\d+ +\S+ +)(\d+)\/(\d+) +(\d+):(\d+):(\d+)(.*)/)
{ $pre=$1;
  $month=$2;
  $day=$3;
  $hour=$4;
  $minute=$5;
  $second=$6;
  $rest=$7;
  $year=0;
  $time_then = timegm(($seconds,$minute,$hour,$day,$month,$year,0,0,0));
  if ($time_then < $prev_time)
  { print "-----  TIME JUMP  ----------\n";
  }
  $prev_time = $time_then;
  print "$pre$month/$day $hour:$minute:$second$rest\n";
}
else
{ print;
}' | less
    }
    # printing - a2ps has gone through revisions
    a2ps()      { env a2ps -o- -MLetter                  "$@"; }
    a2pscolor() { : --chars-per-line=80; env a2ps -o- -MLetter --prologue=color "$@"; }
    fl8()  { flpr -h fnprt -q WH8E_HP4SI -l "`whoami`" "$@" ; }
    fl82() { (echo "statusdict begin true setduplexmode end";cat "$@") | flpr -h fnprt -q wh8e_lj4si -l "`whoami`"; }
    fl8land() { a2ps -1 -l "$@" | flpr -h fnprt -q WH8E_HP4SI -l "`whoami`"; }
    # no such thing as color-duplex??
    #flcolor() { flpr -q wh8e_tek550 -l "`whoami`" "$@" ; }
    flcolor() { flpr -q wh8e_tek350 -l "`whoami`" "$@" ; }
    flduplex() { flpr -q wh9w_hp4700_d -l "`whoami`" "$@" ; }
    lzfl8ps()  { a2ps -d -l100 -nc -2 "$@" | flpr -q WH8E_HP4SI -l ron; }
    lzfl8()  { lptops -FCourier -P4.44bp -M3 -T0.5in -B0.5in -L0.5in -R0.5in -H -O -U "$@" | flpr -q WH8E_HP4SI -l "`whoami`"; }
    lz2fl8() { (echo "statusdict begin true setduplexmode end";lptops -FCourier -P4.44bp -M2 -T0.5in -B0.5in -L0.5in -R0.5in -H -O -U "$@") | flpr -h fnprt -q WH8E_HP4SI -l "`whoami`"; }
    interrupts() { awk '/'"$1"'/{for(nn=1;nn<=NF;++nn)printf"%2s ",$nn;print""}' /proc/interrupts; }
    cpuinfo() { grep -m1 'model name' /proc/cpuinfo
                sed -n -e '/physical id/{s/$/   /;h};/siblings/{s/$/   /;H};/cpu cores/{H;x;s/\n//g;p}' /proc/cpuinfo | sort -u; echo "See also: numactl -H"; }
    numa_cpulist() { grep . /sys/devices/system/node/node*/cpulist; }
    environ()
    { test $# -ne 1 && { echo one arg - pid; return; }
      pid=$1
      (cat /proc/${pid}/environ ; echo) | tr '\000' '\n'
    }
    keyapp() { echo "\033="; }  # "application" keypad
    keynum() { echo "\033>"; }  # "numeric" keypad
    widle() { w | who-idle-sort.pl; }
    wrapoff() { echo "\033[?7l"; }
    wrapon() { echo "\033[?7h"; }
    mail() { Mail "$@"; }
    finwait() { netstat | grep -F -i FIN_WAIT; }

    ifconfigv4() { : ipv4; ifconfig "$@" | grep -E '^[a-z]|inet |ether'; }
    inf_affinity()
    { inf=$1
      xx=1 irqs=$(awk "BEGIN{FS=\":\"} /$inf/{print\$1;}" /proc/interrupts)
      for netirq in $irqs;do
          grep . /proc/irq/$netirq/smp_affinity_list /dev/null
      done
    }
    inf_module() { inf=$1; ls /sys/class/net/$inf/device/driver; }
    inf_proc_int()
    { inf=$1
      for ii in `seq $(grep ^processor /proc/cpuinfo | wc -l)`;do : cannot use nproc in isolcpus kernel cmdline environment
          core=`expr $ii - 1`
          col=`expr $ii + 1`
          awk "/$inf/{ ints+=\$$col; } END{printf\"cpu$core=%d\\n\",ints;}" /proc/interrupts
      done | grep -v =0
    }
    inf_cycle()
    { inf=$1
      mm=`inf_module $inf | sed "s/.* -> //"`; mm=`basename $mm`
      rmmod $mm; modprobe $mm; ifup $inf
    }
    inf_mtu()
    { inf=$1 mtu=$2
      mm=`ifconfig $inf | sed -n '/mtu/{s/.*mtu //;p}'`
      test -n "$mtu" -a ${mtu:-0} -ne $mm && { echo setting mtu $mtu; ifconfig $inf mtu $mtu; } || echo mtu $mm
    }
    iptablesL()
    { ls /proc/net/ip_tables* >/dev/null 2>&1; sts=$?
      test $sts -eq 0 && echo "firewall active" || echo "firewall inactive"
      for tbl in `cat /proc/net/ip_tables_names`;do
       echo ==== $tbl ====; iptables -t $tbl -n -L --line-numbers -v;echo
      done
      return $sts
    }

    # status when renew period expired is 1; when network down is 1
    # stderr messages include:
    #   kinit: Cannot resolve KDC for requested realm renewing tgt
    #   kinit: Ticket expired renewing tgt
    kinitR1()
    {   kxx=6;
        while true;do    # no do while :(
            until netstat -rn | grep -E 'default|0\.0\.0\.0' >/dev/null;do sleep 60;done
            kinit_out=`env kinit -R 2>/tmp/$$.err`; kinit_status=$?
            kinit_err=`cat /tmp/$$.err`; /bin/rm -f /tmp/$$.err
            echo "o=${kinit_out}e=$kinit_err"
            echo "`date` kinit_status=$kinit_status kxx=$kxx"
            if   [ $kinit_status = 0 ];then rsts=0;break
            elif expr "$kinit_err" : '.*expired' >/dev/null;then rsts=1;break
            elif ! kxx=`expr $kxx - 1`;then rsts=1;break;fi
            sleep 6
        done
        return $rsts
    }
    kinitR()
    {   kyy_init=40; kyy=$kyy_init;
        while true;do
            t0=`date +%s`;\
                until expr `date +%s` - $t0 \> 3600 \* 8 >/dev/null;do sleep 120;done
            while true;do
                if kinitR1              ;then kyy=$kyy_init;break;fi
                if ! kyy=`expr $kyy - 1`;then echo done trying; break 2;fi
                echo "try again in an hour kyy=$kyy"
                sleep 3600
            done
        done &
    }
    kinit()
    {   : $* "--force" kinit \(to renew "renew until" date\);: $1 for non-default principal. Need to add afs aklog?
        if [ "$1" = '--force' ];then
            shift
            if env kinit -h 2>&1 | grep -E -- "-A.*not*.* address" >/dev/null;then
                env kinit -r 7d -f -A ${*-}
            else  env kinit -r 7d -f -n ${*-}; fi
        elif klist -s;then
            echo "ticket OK;" `klist | grep -om1 'renew until.*'` >&2; env kinit -R
        else
            : determine which version - use "-A" if help has -A for "no addresses" or "not include"
            : note: -h is an invalid option which causes the option list to be printed
            echo  "need to (re)kinit" >&2
            if env kinit -h 2>&1 | grep -E -- "-A.*not*.* address" >/dev/null;then
                env kinit -r 7d -f -A ${*-}
            else  env kinit -r 7d -f -n ${*-}; fi
        fi
    }
    kca()
    {   kx509
        kxlist -p
        file=/tmp/x509up_u`id -u`
        ls $file
        openssl pkcs12 -export -passout pass:"" \
            -in $file \
            -out $file.p12 -name "Fermilab"
        ls $file.p12 
        echo import $file.p12
    }

    #unalias ls >/dev/null 2>&1 .... take care of in .profile b/c ???
    # At home, "$@" shows ups as '' (seen when set -x) and ls complains:
    # "/bin/ls: : No such file or directory". So I use "${@:+$@}"
    if [ -x /usr/5bin/ls ]; then
        la_cmd="/usr/5bin/ls -Fla"
        ls_cmd="/usr/5bin/ls -Fog"
        lls_cmd="/usr/5bin/ls -Fl"
        eval 'cp() { /bin/cp -ip "$@" ; }'
    elif [ `uname` = Linux -a `uname -m` = ppc ];then # ppc busybox hack
        la_cmd="/bin/ls -Fla"
        ls_cmd="/bin/ls -Flg"
        lls_cmd="/bin/ls -Fl"
        eval 'cp() { /bin/cp -ip "$@" ; }'
    elif [ `uname` = Linux ];then
        la_cmd="/bin/ls -Fla"
        ls_cmd="/bin/ls -FlhG"
        lls_cmd="/bin/ls -Fl"
        #eval 'cp() { /bin/cp -ip --preserve=all "$@" ; }'  # NOT ALL distro support --preserve
        eval 'cp() { /bin/cp -ip "$@" ; }'  # 2018-10-25 --preserve... is turning out to be interesting in light of selinux
    elif [ `uname` = FreeBSD ];then
        la_cmd="/bin/ls -Fla"
        ls_cmd="/bin/ls -Fl"
        lls_cmd="/bin/ls -Fl"
        eval 'cp() { /bin/cp -ip "$@" ; }'
    elif [ `uname` = Darwin ];then
        la_cmd="/bin/ls -Fla"
        ls_cmd="/bin/ls -Fo"
        lls_cmd="/bin/ls -Fl"
        eval 'cp() { /bin/cp -ip "$@" ; }'
    else
        la_cmd="/bin/ls -Fla"
        ls_cmd="/bin/ls -Fog"
        lls_cmd="/bin/ls -Fl"
        eval 'cp() { /bin/cp -ip "$@" ; }'
    fi
    eval 'la() { $la_cmd "${@:+$@}" ; }'
    eval 'ls()
    {
        if [ "${1-}" ];then
            if expr "x$*" : ".*/\$" >/dev/null;then # if last char is "/"
                # Note: some systems "expr: syntax error" for "expr "/" : '.*/'"
                # Assume there is one arg.
                # This is all because, with symbolic links, without the "/." and
                # with "-l" ls lists the link in "foo -> bar" form. It is nice
                # to be able to add (just a) "/" and get a list of the target
                # file/directory.
                $ls_cmd "${@:+$@}."
            else
                $ls_cmd "${@:+$@}"
            fi
        else
            $ls_cmd "${@:+$@}" | grep -E -v "\.~[0-9.]*~|\.bak"
        fi
    }'
    lls()
    {
        if [ "${1-}" ];then
            $lls_cmd "${@:+$@}";
        else
            $lls_cmd "${@:+$@}" | grep -E -v '\.~[0-9.]*~|\.bak'
        fi
    }
    lsx() { for i in "$@";do
                echo -n modify:;/bin/ls -Fld "$i";
                echo -n change:;/bin/ls -Fldc "$i";
                echo -n access:;/bin/ls -Fldu "$i";
                echo "Context (use chcon --reference=$@ <fileToChange> ):"
                /bin/ls -FldZ "$i";lsattr -d "$i";getcap "$i";
            done ; }
    lsdir() { find . -type d \! -name . -prune | cut -c3- | xargs ls -Fld; }
    lsd()
    {   lsout=`ls -lU "$@"`
        if tot=`echo "$lsout" | grep '^total '`;then echo $tot;fi
        echo "$lsout" | $GREP '^d'     | sort -k 8
        echo "$lsout" | $GREP '^[^dt]' | sort -k 8
    }
    #dls() { /bin/ls -FC1 $* | grep '/$'; } # this doesn't list "." dirs
    MacBookPro_vbox_date()  # alternateIP
    {   test -n "${1-}" && ip=$1 || ip=192.168.56.101
        if [ `uname` = Darwin ];then
            servers="10.0.2.2 `netstat -rn | awk '/default/{print$2;exit;}'` time.apple.com"
            ssh root@$ip "service ntpd stop; for ss in $servers;do ntpdate \$ss && break;done; service ntpd start"
        fi
    }
    MacBookPro_sleep()  # alternateIP
    {   test -n "${1-}" && ip=$1 || ip=192.168.56.101
        if [ `uname` = Darwin ];then
           if ping -c1 -t1 $ip >/dev/null;then
               killall Chicken 2>/dev/null
               ssh root@$ip "killall vncviewer rdesktop"
               sleep 2; : in case I want to see things disappear
               VBoxManage controlvm FirstVM pause
               sleep 2
           else
               echo "ping failed - Vbox VM does not appear to be running"
           fi
           echo `date`: Just before '"pmset sleepnow"'
           pmset sleepnow
           echo `date`: 'Well, OK, hopefully within 10 seconds'
           xx=4; while xx=`expr $xx - 1`;do detect_sleep.pl 30 && break || echo no sleep detected $xx;done
           echo `date`: 'Continuing (waking up?)...'
           VBoxManage controlvm FirstVM resume
           xx=11; while xx=`expr $xx - 1`;do
               echo `date`: Ping count down $xx...
               ping -c2 -t3 $ip >/dev/null && { sleep 3; MacBookPro_vbox_date $ip; } && break \
               || echo "`date`: ping failed"
               sleep 3
           done
       fi
    }
    manp() { man "$@" |awk "{ x = NR; while(x>66) x-=66; if((x>3)&&(x<64)) print }"  |pr -e -t | roff_dvi | flpr -h fnprt -q WH8E_HP4SI -l "`whoami`" ; }
    mandvi() { man "$@" |awk "{ x = NR; while(x>66) x-=66; if((x>3)&&(x<64)) print }"  |pr -e -t | roff_dvi -b -r ; }
    mute() { amixer set Capture nocap; }
    unmute() { amixer set Capture cap; }
    ncdwm()
    {
        if [ "$DISPLAY:-}" = "" ];then
            echo "DISPLAY variable not set"
            return
        fi
        cat .Xdefaults default.DECterm | xrdb -merge
        rsh `expr "$DISPLAY" : '\(.*\):.*'` wm
    }
    node()
    {   test -d /usr/lib/node_modules -a -z "${NODE_PATH-}" && { NODE_PATH=/usr/lib/node_modules; export NODE_PATH; }
        test $# -eq 0 -a -f ~/node_modules/repl.history/bin/repl.history \
            && ~/node_modules/repl.history/bin/repl.history "$@" \
            || env node "$@"
    }
    nodeLocate() 
    {   mac=$1;
        hname=`echo $mac | sed 's/:/%3A/g'`
        ofile=/tmp/t.html
        wget -q -O$ofile "http://mrtg.fnal.gov/cgi/mrtg-search.cgi?hname=$hname&mac=mac"
        grep 'connected to.*on port' $ofile
        rm -f $ofile
    }
    patch() { /usr/bin/env patch -b "$@"; }
    path() { echo $PATH ; }
    python()
    {
        if [ "${1-}" ];then
            /usr/bin/env python "$@"
        else
            /usr/bin/env PYTHONSTARTUP=$HOME/.pystartup python;
            # -ic "\
            #import readline,rlcompleter,sys;readline.parse_and_bind(\"tab:complete\");\
            #print \"Python\",sys.version,\"on\",sys.platform,\"\\n\",sys.copyright"
        fi
    }
    quick-mrb-start() {
        kinit; test -n "$MRB_QUALS" && { echo need to redo; envreset; }; \
            test -d run_records && rm -fr [a-qs-z]* run_[di]*; \
            ln -s ../quick-mrb-start.sh . && ./quick-mrb-start.sh -w --develop --debug "$@"
    }
    ronpullemacs() { ssh work.fnal.gov 'tar cf - `find . -maxdepth 1 -type f -name ".emacs*" -o -name ".tpu-*"`' | tar xf -; }
    ronpush() {
        USAGE="ronpush [--tunnel=node] <node>"
        op1arg='rest=`expr "$op" : "[^-]\(.*\)"`; test -n "$rest" && set -- "$rest"  "$@"'
        reqarg="$op1arg;"'test -z "${1+1}" &&echo opt -$op requires arg. &&echo "$USAGE" &&exit'
        args= tunnel=
        while [ -n "${1-}" ];do
            if expr "x${1-}" : 'x-' >/dev/null;then
                op=`expr "x$1" : 'x-\(.*\)'`; shift   # done with $1
                leq=`expr "x$op" : 'x-[^=]*\(=\)'` lev=`expr "x$op" : 'x-[^=]*=\(.*\)'`
                test -n "$leq"&&eval "set -- \"\$lev\" \"\$@\""&&op=`expr "x$op" : 'x\([^=]*\)'`
                case "$op" in
                    t*|-tunnel) eval $reqarg; tunnel=$1;shift;;
                    *) echo unkown option -$op; return;;
                esac
            else
                aa=`echo "$1" | sed -e "s/'/'\"'\"'/g"` args="$args '$aa'"; shift
            fi
        done
        eval "set -- $args \"\$@\""; unset args aa
        if [ ! "${1-}" ];then
            echo "usage: pushron <node>"
            echo "The function attempts to pushd the basic \"ron\" environment to"
            echo "the node specified.  The \"ron\" env. is things from ~ like"
            echo ".bashrc, .profile, script/ edit/, etc."
            return
        fi
        test -z "$tunnel" && node1=$1 || { node1=$tunnel tunnel="ssh $1"; }
        (cd ~; tar cBf - .profile .bashrc .emacs* .tpu* edit script) | ssh $node1 "$tunnel tar xBf -"
        unset args tunnel USAGE node1
    }
    reset1() { stty 526:5:bf:3b:3:1c:7f:15:4:0:0:1a:0:0:0:0:0:0:0:16:17:12:f:13:11:0:0:0:0:0:0:0:0:0:0:1 ; }
    reset2() { stty 526:5:bd:3b:3:1c:7f:15:4:0:0:1a:11:13:1a:19:12:f:17:16:17:12:f:13:11:0:0:1 ; }
    clearsaved() { echo '\033[3J'; }  # can use: clear;clearsaved;clear

    # netstat -s | grep -E ' segments retrans|[a-zA-Z_]Retransmit: |[a-zA-Z_] retransmits|[0-9] retransmits |[a-zA-Z_]Retrans[a-zA-Z_]|[a-zA-Z_]Retrans: [0-9]'
    retrans() 
    {
        netstat -s | perl -e '
    $rt_general = 0; $rt_specific = 0;
    while (<>)
    {   if    (/(\d+) segments retrans/)
        {   $rt_general += $1;
        }
        elsif (/(\S+)Retransmit: (\d+)/)
        {   $rt_specific += $2;
            $retrans{$1} = $2;
        }
        elsif (/(\d+) (\S+) retransmits/)
        {   $rt_specific += $1;
            $retrans{$2} = $1;
        }
        elsif (/(\d+) retransmits (.*)/)
        {   $rt_specific += $1;
            $k=$2; $k=~s/ /_/g;  # helps STDERR header line
            $retrans{$k} = $1;
        }
        elsif (/(\S+)Retrans(\S+): (\d+)/)
        {   $rt_specific += $3;
            $retrans{$1.$2} = $3;
        }
        elsif (/(\S+)Retrans: (\d+)/)
        {   $rt_specific += $2;
            $retrans{$1} = $2;
        }
    }
    # DO NOT HAVE SPACES AT BEGINNING OF OUTPUT -- IT WILL MESS UP DELTA.
    if ($rt_specific ne 0)
    {   $ostr="";
        printf STDERR " %10s %10s", "general", "gen-spec";
        foreach $key (sort keys %retrans)
        {   printf STDERR " %10s", substr($key,-10);
            $ostr = $ostr . sprintf " %10d", $retrans{$key};
        }
        printf STDERR "\n";
        printf " %10d %10d%s\n", $rt_general, $rt_general-$rt_specific, $ostr;
    }
    else
    {   printf "%d\n", $rt_general;
    }'
    }
    retransMark() 
    { 
        retrans0=`retrans`
        echo "$retrans0"
    }
    retransDelta() 
    { 
        retrans1=`retrans 2>/dev/null`;
        perl -e '
    @retrans0 = split " ","'"$retrans0"'"; # tricky shell quoting
    @retrans1 = split " ","'"$retrans1"'"; # tricky shell quoting
    foreach $ii (0..$#retrans0)
    {   printf " %10d", $retrans1[$ii] - $retrans0[$ii];
    }
    printf "\n";'
        retrans0=$retrans1
    }
    trace-cmd-record() { trace-cmd record -q -b 10000 -C global --date -esyscalls -esched -enet "$@"; }
    # old trace-cmd report assumes pid fits within 5 digits (when 6 digits is modern)
    trace-cmd-report() {
        
        trace-cmd report -q "$@" \
            | perl -e 'while(<>){$_=~/^(.{16})-([0-9]*) *(\[[0-9]*]) *(.*)/o && printf("%s-%-6s %s %s\n",$1,$2,$3,$4)}'
    }

    rgang_fermi_install() { sudo dnf install fermilab-util_rgang "$@"; }

    # NOTE: In July 2023, I seemed to determine that, of rsync,tar,cpio, rsync is best.
    rsync_opts="--archive"   # should be the same as -rlptgoD (--recursive --links --perms --times --group --owner --devices --specials)
    rsync_opts="$rsync_opts --hard-links" # -H (no -A/--acls -X/-xattrs which is OK because the destination file system should take care of those)
    rsync_opts="$rsync_opts --sparse --exclude=lost+found --one-file-system"
    rsync_opts="$rsync_opts --stats"
    #rsync_opts="$rsync_opts -v"  # comment out to let users add -v
    rsync_opts="$rsync_opts --rsh=ssh"
    #rsync_opts="$rsync_opts --delete"   # one can always add --delete in "$@"
    #rsync_opts="$rsync_opts --specials -h --human-readable" #newer (dest) versions
    #test `whoami` = root -a `uname` = Linux && rsync_opts="$rsync_opts --xattrs"    # 2018-10-27 let dst FS control xttrs ( user can add if needed)
    rsync() {
        echo "rsync_opts='$rsync_opts'; /usr/bin/time rsync \$rsync_opts $@" >&2
        /usr/bin/time                                 rsync  $rsync_opts "$@"
    }
    rrsync()  # remote rsync (where src or dst has [USER@]HOST:...), use ssh
    {
        /usr/bin/env rsync\
            --archive --hard-links --exclude=lost+found/\
            --one-file-system --recursive \
            --update\
            --rsh=ssh\
            --compress --partial\
            -v --progress --stats "$@"
    #        --delete\
    #        --rsync-path=/p/rsync/v2_4_6/bin/rsync\
    #        --delete-cnewer=last_sync.timestamp\
    #        --create-cnewer=last_sync.timestamp\
    #        --dry-run\
    #
    }
    rsync_skip_newer() {
        echo "rsync_opts='$rsync_opts'; /usr/bin/time rsync \$rsync_opts -u $@" >&2
        /usr/bin/time                                 rsync  $rsync_opts -u "$@"
    }
    rsync_status() { rrsync $HOME/work/status/status fnapcf:$HOME/work/status/; }
    mv_backup() { # $1 is file to mv
        if [ -f "$1.~1~" ];then
            # NOTE: this does not strictly require ~N~, just ~N
            last=`/bin/ls "$1.~"[1-9]* | tail -1`
            nextn=`expr "$last" : '.*\.~\([0-9]*\)' + 1`    # compound string and numeric
        else
            nextn=1
        fi
        mv "$1" "$1".~$nextn~
    }
    # Note: backup_laptop will create an initial backup0 dir, but additional
    #       directories will need to be created manually.
    # Note: No filtering of output to log file as in backup.rsync.sh
    # Note: Uses $rsync_opts set above
    # Note: Currently, if doing parallel backups, MUST start them at least a minute apart!
    backup_laptop() {
        case "$1" in
        -h|-\?|--help)
            echo 'usage: backup_laptop [backup_mp]  # default backup_mp=/mnt/backup'
            echo "Another option would be /mnt/ronbackup or maybe /mnt/backup2t; /mnt/backupb3 is currently ntfs"
            echo 'Could do: rsync_opts="$rsync_opts --del" backup_laptop /mnt/backup2t'
            echo '      or: rsync_opts="$rsync_opts --dry-run" backup_laptop /run/media/ron/RONBACKUP'
            echo "See: grep -i backup /etc/fstab"
            echo "     find /mnt -maxdepth 1 -iname \*backup\*"
            echo "     lsblk -o+FSUSE%,FSTYPE,LABEL"
            return;;
        "")  backup_mp=/mnt/backup;;
        *) backup_mp=$1;;
        esac
        start=`date +%s`
        date=`date -d@$start +%Y.%m.%d.%H.%M`
        echo "`date`: backup_mp=$backup_mp"                                                  | tee    /tmp/backup_laptop.$date
        mount | grep ${backup_mp} || mount ${backup_mp}
        last=`/bin/ls -t ${backup_mp}/backup_laptop.* | head -1`
        if [ -z "$last" ];then
            NN=0
        else
            backupN=`grep "${backup_mp}/backup[0-9]*" $last`
            test -z "$backupN" \
                && NN=0 \
                || { NN=`expr "$backupN" : ".*${backup_mp}/backup\([0-9]*\)"`; NN=`expr $NN + 1`; }
            test $NN -ge `/bin/ls -d ${backup_mp}/backup[0-9]* | wc -l` && NN=0
        fi
        sd=`mount | grep "${backup_mp} "`; sd=`expr "$sd" : '/dev/\(sd.\)'`
        test -z "$sd" && { echo 'backup not mounted; See backup_laptop -h'; return; }
        echo last=$last NN=$NN dstat -dD`mount | sed -n '/\/mnt\/disk1/{s|/dev/||;s/ .*//;p}'`,$sd 10
        df -h ${backup_mp}                                                                   | tee -a /tmp/backup_laptop.$date
        for dd in disk1 extra old_home;do
            date                                                                             | tee -a /tmp/backup_laptop.$date
            df -h /mnt/$dd                                                                   | tee -a /tmp/backup_laptop.$date
            if mount | grep /mnt/$dd;then
                echo rsync $rsync_opts --info=progress2 /mnt/$dd ${backup_mp}/backup$NN      | tee -a /tmp/backup_laptop.$date
                sudo rsync $rsync_opts --info=progress2 /mnt/$dd ${backup_mp}/backup$NN 2>&1|rsync_progress_filt.gawk| tee -a /tmp/backup_laptop.$date
            else
                echo WARNING - nothing mounted at /mnt/$dd                                   | tee -a /tmp/backup_laptop.$date
            fi
        done
        date                                                                                 | tee -a /tmp/backup_laptop.$date
        echo rsync $rsync_opts --info=progress2 /etc ${backup_mp}/backup$NN/root             | tee -a /tmp/backup_laptop.$date
        sudo rsync $rsync_opts --info=progress2 /etc ${backup_mp}/backup$NN/root 2>&1|rsync_progress_filt.gawk| tee -a /tmp/backup_laptop.$date
        date                                                                                 | tee -a /tmp/backup_laptop.$date
        df -h ${backup_mp}                                                                   | tee -a /tmp/backup_laptop.$date
        end=`date +%s`
        etime=`awk "BEGIN{t=$end-$start;printf\"%02d:%02d\n\",int(t/60),int(t%60);exit}"`
        echo elapsed time: ${etime}s                                                         | tee -a /tmp/backup_laptop.$date
        sudo cp -p /tmp/backup_laptop.$date ${backup_mp}
        ls -t ${backup_mp}
        echo Now you can umount and stop_dev_sd.sh via:
        echo " sudo umount ${backup_mp}"
        echo " sudo ~ron/script/stop_dev_sd.sh $sd"
    }
    tar_opts="--exclude lost+found --totals"
    if [ `uname` = Linux ];then
        tar_opts="$tar_opts --one-file-system --sparse"
        test `whoami` = root && tar_opts="$tar_opts --xattrs"
    fi
    tar(){
        p1=$1 p2=${2-}; shift 2
        echo "tar_opts='$tar_opts' 1='$p1' 2='$p2'; time tar \$1 \$2 \$tar_opts $@" >&2
        time                                  `/usr/bin/which tar`  $p1  $p2  $tar_opts "$@"
    }

    tcpdump_() { tcpdump -s78 "$@"; }
    tshark_() { : 'usage: tshark_ -r<file>'
        tshark "$@" -n -T fields\
 -e frame.number -e frame.time -e tcp.analysis.bytes_in_flight -e ip.src\
 -e ip.dst -e col.Protocol -e frame.len -e col.Info\
 | expand
    }
    tshark-() { : 'usage: tshark_ -r<file> | filter | tdelta -i -d 3 # good w/ less -S 14-RightArrow'
        tshark "$@" -n -T fields\
 -e frame.time -e frame.number -e tcp.analysis.bytes_in_flight\
 -e frame.len -e col.Info\
 | expand
    }
    tshark__() { : 'usage: tshark_ -r<file>'
        tshark "$@" -n -T fields\
 -e frame.number -e frame.time -e tcp.analysis.bytes_in_flight -e ip.src\
 -e ip.dst -e _ws.col.Protocol -e frame.len -e _ws.col.Info\
 | expand
    }
    tshark_retrans() { file=$1
        tshark -r $file -nn tcp.analysis.retransmission
    }

    tlvl_used() { file=$1
      grep -E -o '(TLOG|TRACE)\( *[0-9]*' $file | grep -o '[0-9]*' | sort -nu
    }
    tlvl_largest() { file=$1
      tlvl_used $file | tail -1
    }
    tlvl_upshift() { lvllo=$1 lvlhi=$2 file=$3
      test $lvllo -gt $lvlhi && x=$lvllo lvllo=$lvlhi lvlhi=$x
      for lvl in `seq $lvlhi -1 $lvllo`;do
        from=$lvl to=`expr $lvl + 1`
        sed -i '/\(TRACE(\|TLOG(\) *'$from'/{s/\(TRACE(\|TLOG(\) *'$from'/\1'$to'/}' $file
      done
    }

    slocal()
    {   # Ref. google: slocal MyIncTmp
        # slocal call mh "inc" command
        date
        mkdir `mhpath +MyIncTmp` 2>/dev/null
        env inc +MyIncTmp -nochangecur
        xx=1;for file in `mhpath +MyIncTmp all`; do
            echo -n "$xx: "
            cat $file | env slocal -maildelivery $HOME/.maildelivery -verbose \
                | grep folder
            test $? -eq 0 && /bin/rm $file
            xx=`expr $xx + 1`
        done | grep -E 'to folder "(:ron|ilc|ctrlx|department|cppm_reg_sysadmins)"'
        #rmdir `mhpath +MyIncTmp` 2>/dev/null
    }
    inc() { echo "Use \"slocal\" function:"; type slocal; }

    scisoft()
    {   : $1 is package or "" for pkg list
        test $1 = '-m' && { shift; do_m=1; } || do_m=0
        pkg=$1; : NOTE: pkg can have OPTIONAL /version, i.e. cetbuildtools/v5_06_00
        test $# -eq 2 && pkg=$pkg/$2
        if [ $do_m -eq 1 ];then
            baseurl=https://scisoft.fnal.gov/scisoft/manifest
            url=`echo $baseurl/$pkg | sed 's|/$||'`
            urlregex=`echo $url | sed 's|/manifests|/[./]*manifests|;s|/|\\\\/|g'`
            echo "url=$url urlregex=$urlregex" >&2
            lynx -dump $url | sed -n "/$urlregex\/[^/]/{s|/\./|/|;s|^.* $url/|$url/|;s|/$||;p;}"; : for pkg="", not https://scisoft.fnal.gov/scisoft/./packages//../..
        else
            baseurl=https://scisoft.fnal.gov/scisoft/packages
            url=`echo $baseurl/$pkg | sed 's|/$||'`
            urlregex=`echo $url | sed 's|/packages|/[./]*packages|;s|/|\\\\/|g'`
            echo "url=$url urlregex=$urlregex" >&2
            lynx -dump $url | sed -n "/$urlregex\/[^/]/{s|/\./|/|;s|^.* $url/|$url/|;s|/$||;p;}"; : for pkg="", not https://scisoft.fnal.gov/scisoft/./packages//../..
        fi
    }

    sshVNCtunnel() # port
    { echo 'wait a minute and then C-z and bg  (have to live with the "have to force ssh disconnect - BUT, disconnecting leaves the sleep - fix this"'
        ssh -n -T -L 5961:localhost:5961 outback ssh -n -T -L 5961:localhost:5961 smartcon1 sleep 99999999 >ssh.out 2>&1
    }
    scp()
    {
        defroute=`netstat -rn | grep -E '^(default|0\.0\.0\.0)[ 	]+[0-9]+\.'\
            | awk '{print $2;exit;}'`
        opt_id= opt_F=
        eval ronhome=~$RONUSER
        if [ -d $ronhome ];then homes=$ronhome;else homes=$HOME;fi
        if [ $HOME != $homes ];then homes="$homes $HOME";fi
        #for ff in identity id_rsa id_dsa;do
        for ff in identity* id_rsa* id_dsa*;do
            for home in $homes;do
                for fff in $home/.ssh/$ff;do
                    expr "$fff" : '.*\.ssh.*\.' >/dev/null && continue
                    if [ -f $fff ];then
                        opt_id="$opt_id -oIdentityFile=$fff"
                    fi
                done
            done
        done
        conf=config-$defroute-
        while conf=`expr "$conf" : '\(.*\)[-.]'`;do
            for home in $homes;do
                if [ -f $home/.ssh/$conf ];then
                    echo using $home/.ssh/$conf >&2;  opt_F="-F $home/.ssh/$conf"; break 2
                fi
            done
        done
        env scp -p $opt_id $opt_F "$@"
    }
    #ssh() { SSH_CONFIG_OPTS="--ssh `which ssh`" ssh_config.sh "$@"; }
    ssh()
    {
        if [ -z "$SSH_AGENT_PID" ];then
            psout=`ps h -u $USER -o pid,tty,time,comm`
            if ssh_agent=`echo "$psout" | grep ssh-agent`;then
                export SSH_AGENT_PID=`echo "$ssh_agent" | awk '{print$1;exit}'`
                sock_id=`expr $SSH_AGENT_PID - 1`
                export SSH_AUTH_SOCK=`echo /tmp/ssh-*/agent.$sock_id`
            else
                eval `ssh-agent`
                ssh-add
            fi
        fi
        ls /tmp/krb5cc_`id -u`* >/dev/null 2>&1 && kinit >&2
        ere=`printf '^(default|0\.0\.0\.0)[ \011]+[0-9]+\.'`
        defroute=`netstat -rn | grep -E "$ere"\
            | awk '{print $2;exit;}'`
        eval ronhome=~$RONUSER
        if [ -d $ronhome ];then homes=$ronhome;else homes=$HOME;fi
        if [ $HOME != $homes ];then homes="$homes $HOME";fi
        opt_id= opt_F=
        for ff in identity* id_rsa* id_dsa*;do
            for home in $homes;do
                for fff in $home/.ssh/$ff; do
                    expr "$fff" : '.*\.ssh.*\.' >/dev/null && continue;: skip, i.e., *.pub
                    if [ -f $fff ];then
                        opt_id="$opt_id -oIdentityFile=$fff"
                    fi
                done
            done
        done
        conf=config-$defroute-
        while conf=`expr "$conf" : '\(.*\)[-.]'`;do
            for home in $homes;do
                if [ -f $home/.ssh/$conf ];then
                    echo using $home/.ssh/$conf >&2;  opt_F="-F $home/.ssh/$conf"; break 2
                fi
            done
        done
        # Protocol=1,2 for nova (it likes protocol 1 and never gets around to trying it if 2 is first
        local_tty=`tty|sed 's|/dev/||'` # to tell "from host term"; SSH_* tells "from host"
        # remote sys /etc/bashrc PROMPT_COMMAND can overwrite window title -
        # - e.g (from daq.fnal.gov AL9):
        # printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"
        if    tty -s <&1 && type xt_title.sh >/dev/null 2>&1 \
            && title_sav=`xt_title.sh`;then
            # OK if title_save strlen 0
            xwin "$local_tty $title_sav -> $1"
            env ssh $opt_id $opt_F "$@"
            sshsts=$?
            xwin "$title_sav" # when "", xwin() likely comes up with $1=/bin/bash
        else
            env ssh $opt_id $opt_F "$@"
            sshsts=$?
        fi
        date >&2 # print out disconnect/exit time
        return $sshsts
    }
    suspend2ram_loop()    # needs window manager support so windows (if applicable)
    {   suspend2ram_loops=0 suspend2ram_countdown=10 t0=`date +%s` quick_cnt=0
        deltaT() { expr `date +%s` - $t0; t0=`date +%s`; }
        while suspend2ram_loops=`expr $suspend2ram_loops + 1`;do
            echo "`deltaT` - check route loop number $suspend2ram_loops $suspend2ram_countdown"
            t0=`date +%s`
            suspend2ram_countdown=`expr $suspend2ram_countdown - 1`
            if netstat -rn | grep -E 'default|0\.0\.0\.0';then
                echo "execute  \"${1-} ...\" at `date`"
                "$@"
                echo "finished \"${1-} ...\" at `date`"
                suspend2ram_countdown=10 t0=`date +%s`
            fi
            test `deltaT` -le 1 && quick_cnt=`expr $quick_cnt + 1` || quick_cnt=0
            test $quick_cnt -gt 10 && return
            sleep 2
            echo "`deltaT` - sleep again - quick_cnt=$quick_cnt"; sleep 2
        done
    }

    spack_setup() {
        if [ -n "$SPACK_ROOT" ];then
            echo "SPACK_ROOT=$SPACK_ROOT"
        else
            case $hostname in
                np04*)  first=`/bin/ls /cvmfs/dunedaq.opensciencegrid.org/spack/releases/current/spack-*/spack-*/share/spack/setup-env.sh|head -1`
                        test -z "$first" && { 
                            echo "Strange - no spack setup-env.sh to source :("
                            return
                        }
                        echo source $first
                        . $first
                        ;;
                *) type ups >/dev/null 2>&1 && setup spack || echo Do not know how to setup spack environment;;
            esac
        fi
        echo -n "Current running spack arch(platform-platform_os-target): "
        spack arch
    }
    
    tgif2p() { tgif -geometry 1711x1207+0-23 "$@"; } # good geom/position for tiled (portrait) 2x1
    tgif1p() { tgif -geometry 900x1207+0-23 "$@"; }
    tgif1l()
    {   echo "you have to change the page orientation manually :(";
        tgif -geometry 1140x970+0-23 "$@";
    }
    # insert commas into large numbers  --- arg is min width
    # Currently ignore hex numbers -- probably could (optionally) add loop to group hex number by 4's or 8's,
    # but that would be "thousands" :)
    thousands() { test -n "$1" && width=$1 || width=10;
      perl -e 'while(<>){
        while ($_ =~ /(^|[^xX0-9])([0-9]{'"$width"',})($|[^0-9])/) {
          $orig=$2;
          $new = reverse $orig;
          $new =~ s/([0-9]{3})/\1,/g;
          if ($new =~ /,$/){chop($new);}
          $new = reverse $new;
          $_ =~ s/$orig/$new/;
        }
        print $_;
      }'
    }
    tmuxnew()
    {   echo "\
"'
    "tmux" defaults:
C-b d     detach from "session"     "tmux a" will re-attach
C-b "     split horizontal - e.g. a single pane window into a 2 pane window, top and bottom
C-b %     Split the current pane into two, left and right.
C-b x     kill current pane
C-b &     kill current window  (could end session if session has single window)
C-b o     Select the next pane in the current window.
C-b ;     move to previously active pane
C-b down  Change to pane below (will roll-over)
C-b up    Change to pane above (will roll-over)
C-b !     Break the current pane out of the window. convert pane to window (cannot rejoin)
C-b c     create new window
C-b [     Enter copy mode to copy text or view the history. (Can use just Up/Down arrow.)

tmux new\; set prefix2 C-x\; set -g mouse on   # mouse will select pane, but copy/pastse only with tmux

C-x :set -g mouse off        copy/paste, then
C-x :set -g mouse on         to get intra-tmux mouse working again

tmux ls   to list (running/existing) sessions
'
echo nl="'"'
'"'"
echo 'tmux new\; set prefix2 C-x\; bind M set -g mouse on\; bind m set -g mouse off\; split-window\; setb "# C-x M/m for mouse on/off$nl"\; pasteb

multiple people attached --
tmux a -r\; resizew -A      # -r = readonly
C-b : resizew -a
C-b : set-option window-size smallest
C-b : show -w -g      then
'
        read -p'Press enter to continue... ' ans
        nl='
'
       tmux new\; set prefix2 C-x\; bind M set -g mouse on\; bind m set -g mouse off\; split-window\; setb "# C-x M/m for mouse on/off$nl"\; pasteb\; "$@"
    }

    # note: an alternative way (seen in an /bin/grep -E script) would be:
    #   ${1+"$@"}
    rcp() { /usr/bin/env rcp -p "$@"; }
    eval 'mv() { /bin/mv -i  "$@" ; }'
    eval 'rm() { /bin/rm -i  "$@" ; }'
    unlink()
    {
        for f in $*;do
            /bin/cp -p $f $f.$$; rm -f $f; mv $f.$$ $f; chmod +w $f
        done
    }
    pirate() { unlink "$@"; }
    spkr()
    {
        if lsmod | grep pcspkr;then
            rmmod pcspkr
        else
            insmod /lib/modules/`uname -r`/kernel/drivers/input/misc/pcspkr.ko
        fi
    }
    ssaver()
    {   if [ "${1-}" = -l ];then
            wireless_=`iwconfig 2>/dev/null | grep -E 'IEEE|ESSID'`
            if echo "$wireless_" | grep tsunami;then
                echo 'at home - screensaver inhibitted'
            elif [ `whoami` = root ];then
                su ron -c 'gnome-screensaver-command -l'
                sleep 1
            else
                gnome-screensaver-command -l
                sleep 1
            fi
        fi
        sleep 2;
        xset s activate;
        xset dpms force off;
    }

    tz() { : $1 = awk program
        test "$1" = -h && {
            echo '   usage: tz [awkPrg]'
            echo "examples: tz '/.*/'"
            echo "          tz /C[DS]T/"
            echo "          tz /-0[56]00/"
            echo "          tz /Eur/"
            echo "          tz '\$2==\"+0000\"'"
            echo "          tz '\$2==\"+0100\"'"
            echo "          tz /TZ=CET/"
            echo "Note: the TZ= column show valid values for TZ"
            return
        }
        test $# -gt 0 && awkPrg="$@" || awkPrg='$2=="-0600"'
        echo "awkPrg='$awkPrg'"
        for tz in `timedatectl list-timezones`;do
            echo -e "`TZ=$tz date +'%Z %z'`\tTZ=$tz"
        done | awk "$awkPrg"
    }

    # I do not like when vi clear stuff off the screen
    eval 'vi() { test -n "${LINES-}" && lines=$LINES || lines=30; for ii in `seq $lines`;do echo;done;: env vi "$@"; vim "$@"; }'

    vtune-gui() { . /opt/intel/oneapi/vtune/latest/env/vars.sh; env vtune-gui "$@"; }
    vtune()     { . /opt/intel/oneapi/vtune/latest/env/vars.sh; env vtune     "$@"; }

else    # non-interactive (i.e ssh node command)
    # to, e.g., adjust environment
    if   [ -f       ./SOURCERC ];then .       ./SOURCERC
    elif [ -f   $HOME/SOURCERC ];then .   $HOME/SOURCERC
    elif [ -f $MYHOME/SOURCERC ];then . $MYHOME/SOURCERC   # either same as $HOME or ~ron
    fi
fi	# $interactive = 1
