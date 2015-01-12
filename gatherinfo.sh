#! /bin/sh

# Copyright (c) 2013 Slawomir Wojciech Wojtczak (vermaden)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that following conditions are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS 'AS IS' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

PATH=${PATH}:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
OUTFILE=gatherinfo.sh.$( hostname ).htm
ID=0
LC_ALL=C
LANG=C
UNAME=$( uname )

__command() {
  if [ ${#} -ne 0 ]
  then
    local PREFIX="${@} "
  fi
  echo ${I}
  OUT="$( eval ${I} 2> /dev/null )"
  if [ ${?} -ne 0 ]
  then
    return
  fi
  if [ "${OUT}" = "" ]
  then
    return
  fi
  ID=$(( ${ID} + 1 ))
  cat >> ${OUTFILE} << __EOF
    <a href='javascript:toggle(${ID})'>${PREFIX}# ${I}</a><br>
    <div class='off' id='id_${ID}'>
    <pre>
__EOF
  echo "${OUT}" | sed -e s/'&'/'\&amp;'/g -e s/'<'/'\&lt;'/g -e s/'>'/'\&gt;'/g >> ${OUTFILE} 2>&1
  cat >> ${OUTFILE} << __EOF
    </pre>
    <a href='javascript:toggle(${ID})'><b>COLLAPSE</b> ${PREFIX}# ${I}</a><br><br>
    </div>
__EOF
}

# main()

cat > ${OUTFILE} << __EOF
<html>
<head>
  <meta charset="utf-8">
  <style type="text/css">
    a          { text-decoration: none;  }
    div.on     { display:         block; }
    div.off    { display:         none;  }
  </style>
  <script type="text/javascript">
    <!--
    function show( item_id ) {
      document.getElementById( 'id_' + item_id ).className = 'on';
    }

    function hide( item_id ) {
      document.getElementById( 'id_' + item_id ).className = 'off';
    }

    function toggle( item_id ) {
      if( document.getElementById( 'id_' + item_id ).className == 'on') {
        hide( item_id );
      }
      else {
        show( item_id );
      }
    }

    function expand( max_id ) {
      for( id = 1; id < max_id; ++id ) {
        toggle( id );
      }
    }
    -->
  </script>
<body>
<tt>
<h1>$( hostname )</h1>
<h3>$( date +"%Y/%m/%d %T" )</h3>
<a href='javascript:expand(999)'><b>EXPAND</b></a><br>
__EOF

# PROCESSES -------------------------------------------------------------------
echo "<br><b>processes</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (Linux)
    for I in \
      "top -b -n 1" \
      "socklist"
    do __command; done
    ;;
  (FreeBSD)
    for I in \
      "top -d 1" \
      "top -d 1 -o res" \
      "sockstat"
    do __command; done
    ;;
esac
for I in \
  "ps ax" \
  "ps aux" \
  "ps auxwww" \
  "ps auxefw" \
  "pstree -A" \
  "pstree -A -a" \
  "lsof"
do __command; done

# SYSTEM ----------------------------------------------------------------------
echo "<br><b>system</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (AIX)
    for I in \
      "oslevel -g"
    do __command; done
    ;;
  (Linux)
    for I in \
      "hostid" \
      "lsmod" \
      "cat /etc/release" \
      "cat /etc/lsb-release" \
      "cat /etc/fedora-release" \
      "cat /etc/redhat-release" \
      "cat /etc/sysconfig/rhn/systemid" \
      "cat /etc/SuSE-brand" \
      "cat /etc/SuSE-release" \
      "cat /etc/debian_version" \
      "cat /etc/slackware-version" \
      "cat /root/anaconda-ks.cfg" \
      "cat /etc/modprobe.conf" \
      "cat /etc/modules.conf" \
      "tail -n 99999 depmod.d/*" \
      "cat /etc/sysconfig/selinux" \
      "cat /etc/sysconfig/hwconf" \
      "find / -type f -name core.[0-9]\* | xargs ls -lh" \
      "find / -type f -name core.[0-9]\* | xargs file"
    do __command; done
    ;;
  (FreeBSD)
    for I in \
      "cat /etc/hostid" \
      "cat /etc/freebsd-update.conf" \
      "grep enable /etc/rc.conf" \
      "kldstat" \
      "kldstat -v" \
      "jls"
    do __command; done
    ;;
esac
for I in \
  "vmstat 1 5" \
  "iostat -c 1 5" \
  "iostat -c 1 5 -x" \
  "cat /etc/motd" \
  "cat /etc/issue" \
  "cat /etc/security/limits.conf" \
  "cat /etc/ld.so.conf" \
  "tail -n 99999 /etc/ld.so.conf.*/*" \
  "cat /etc/make.conf" \
  "cat /etc/login.conf" \
  "cat /etc/rc.conf" \
  "cat /etc/sysctl.conf" \
  "cat /etc/ttys" \
  "cat /etc/devd.conf" \
  "cat /etc/devfs.conf" \
  "cat /etc/devfs.rules" \
  "cat /etc/wpa_supplicant.conf" \
  "cat /var/log/secure" \
  "tail -n 99999 /etc/env.d/*/*" \
  "cat /etc/X11/xorg.conf" \
  "cat /var/log/Xorg.0.log" \
  "xwininfo -root -children" \
  "cat /usr/local/etc/X11/xorg.conf" \
  "ls -ltr /var/log" \
  "ls -ltr /var/log/*/*" \
  "find /var/log -type f | xargs ls -ltr" \
  "find /var/log -type f | xargs du -smc | sort -n -r " \
  "find /var/run -type f | xargs tail -n 9999" \
  "uname -a " \
  "uptime" \
  "sysctl -a" \
  "locale -a" \
  "ls -l env.d/*"
do __command; done

# HISTORY ---------------------------------------------------------------------
echo "<br><b>history</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (*)
    :
    ;;
esac
for I in \
  "cat /.bash_history" \
  "cat /.history" \
  "cat /.zhistory" \
  "cat /root/.bash_history" \
  "cat /root/.history" \
  "cat /root/.zhistory" \
  "tail -n 99999 /home/*/.bash_history" \
  "tail -n 99999 /home/*/.history" \
  "tail -n 99999 /home/*/.zhistory" \
  "tail -n 99999 /var/mail/*"
do __command; done

# SHELLS ----------------------------------------------------------------------
echo "<br><b>shells</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (*)
    :
    ;;
esac
for I in \
  "stty -a" \
  "cat /etc/shells" \
  "cat /etc/bashrc" \
  "cat /etc/csh.cshrc" \
  "cat /etc/csh.env" \
  "cat /etc/csh.login" \
  "cat /etc/csh.logout" \
  "cat /etc/cshrc" \
  "cat /etc/profile" \
  "cat /etc/profile.env" \
  "cat /etc/zprofile" \
  "cat /etc/zshrc" \
  "cat /etc/zlogin" \
  "cat /etc/zlogout" \
  "cat /etc/zshenv" \
  "ulimit -a" \
  "limits" \
  "tail -n 99999 /.profile" \
  "tail -n 99999 /.bash_profile" \
  "tail -n 99999 /.bashrc" \
  "tail -n 99999 /.zshrc" \
  "tail -n 99999 /.zprofile" \
  "tail -n 99999 /.cshrc" \
  "tail -n 99999 /.tcshrc" \
  "tail -n 99999 /root/.profile" \
  "tail -n 99999 /root/.bash_profile" \
  "tail -n 99999 /root/.bash_logout" \
  "tail -n 99999 /root/.bashrc" \
  "tail -n 99999 /root/.zshrc" \
  "tail -n 99999 /root/.zprofile" \
  "tail -n 99999 /root/.cshrc" \
  "tail -n 99999 /root/.tcshrc" \
  "tail -n 99999 /home/*/.profile" \
  "tail -n 99999 /home/*/.bash_profile" \
  "tail -n 99999 /home/*/.bashrc" \
  "tail -n 99999 /home/*/.zshrc" \
  "tail -n 99999 /home/*/.zprofile" \
  "tail -n 99999 /home/*/.cshrc" \
  "tail -n 99999 /home/*/.tcshrc"
do __command; done

# NETWORK ---------------------------------------------------------------------
echo "<br><b>network</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (Linux)
    for I in \
      "ip neigh show" \
      "netstat -l -p -n" \
      "netstat -l -p" \
      "route -n" \
      "route" \
      "ip a" \
      "ip a | grep 'inet '" \
      "ip r" \
      "cat /proc/net/ip_conntrack" \
      "cat /etc/sysconfig/iptables" \
      "cat /etc/sysconfig/network" \
      "cat /etc/network/interfaces" \
      "tail -n 99999 /etc/sysconfig/network-scripts/ifcfg-*" \
      "iptables -L -n -v"
    do __command; done
    ;;
  (FreeBSD)
    for I in \
      "netstat -a" \
      "netstat -a -n" \
      "netstat -m" \
      "ifconfig wlan0 list scan" \
      "ipfw show" \
      "ipfw pipe list" \
      "tail -n 99999 /var/db/dhclient.leases.*" \
      "cat /etc/dhclient.conf"
    do __command; done
    ;;
esac
for I in \
  "arp -a" \
  "ifconfig -a" \
  "ifconfig -a | grep 'inet '" \
  "cat /etc/natd.conf" \
  "cat /etc/resolv.conf" \
  "cat /etc/resolvconf.conf" \
  "cat /etc/exports" \
  "cat /etc/zfs/exports" \
  "cat /etc/ppp/ppp.conf" \
  "tail -n 99999 /var/log/ppp.log" \
  "bzip2 -d /var/log/ppp.log.*.bz2 | tail -n 99999" \
  "tail -n 99999 /etc/auto.*" \
  "netstat -r -n" \
  "netstat -r" \
  "netstat -s" \
  "cat /etc/ssh/sshd_config" \
  "cat /etc/ssh/ssh_config" \
  "ntpq -p" \
  "cat /etc/aliases" \
  "cat /etc/mail/aliases" \
  "cat /etc/ntp.conf" \
  "cat /etc/hosts"
do __command; done

# JOBS ------------------------------------------------------------------------
echo "<br><b>jobs</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (*)
    :
    ;;
esac
for I in \
  "crontab -l" \
  "cat /etc/crontab" \
  "cat /etc/anacrontab" \
  "atq" \
  "tail -n 99999 /var/log/cron" \
  "bzip2 -d /var/log/cron.*.bz2 | tail -n 99999" \
  "cat /etc/logrotate.conf" \
  "cat /etc/newsyslog.conf" \
  "cat /etc/syslog.conf" \
  "tail -n 99999 /etc/logrotate.d/*" \
  "tail -n 99999 /etc/cron.*/*" \
  "tail -n 99999 /var/log/maillog" \
  "bzip2 -d /var/log/maillog.*.bz2 | tail -n 99999" \
  "tail -n 99999 /var/cron/tabs/*" \
  "tail -n 99999 /etc/periodic/*/*" \
  "cat /etc/periodic.conf"
do __command; done

# USERS -----------------------------------------------------------------------
echo "<br><b>users</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (*)
    :
    ;;
esac
for I in \
  "who" \
  "cat /etc/passwd" \
  "cat /etc/master.passwd" \
  "cat /etc/shadow" \
  "cat /etc/group" \
  "cat /etc/gshadow" \
  "cat /etc/sudoers" \
  "cat /usr/local/etc/sudoers" \
  "w" \
  "last"
do __command; done

# HARDWARE --------------------------------------------------------------------
echo "<br><b>hardware</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (Linux)
    for I in \
      "cat /proc/cpuinfo" \
      "grep -c proc /proc/cpuinfo" \
      "cat /proc/meminfo" \
      "cat /proc/swaps" \
      "cat /proc/partitions" \
      "cat /proc/interrupts" \
      "cat /proc/version" \
      "cat /proc/devices" \
      "cat /proc/scsi/scsi" \
      "cat /proc/scsi/sg/device_strs" \
      "cat /proc/scsi/IBMtape" \
      "cat /proc/scsi/IBMchanger" \
      "find /dev/lin_tape -ls" \
      "ethtool" \
      "free -m" \
      "lshw" \
      "lspci" \
      "lspci -tv" \
      "lsdev" \
      "lscpu" \
      "lshal" \
      "lsusb" \
      "lsusb -tv" \
      "cdrecord -scanbus"
    do __command; done
    ;;
  (FreeBSD)
    for I in \
      "swapinfo -m" \
      "swapinfo -h" \
      "pciconf -l" \
      "pciconf -l -v" \
      "usbconfig" \
      "usbdevs -v" \
      "cat /var/run/dmesg.boot"
    do __command; done
    ;;
esac
for I in \
  "dmesg" \
  "tail -n 99999 /var/log/messages" \
  "bzip2 -d /var/log/messages.*.bz2 | tail -n 99999" \
  "dmidecode"
do __command; done

# BOOT ------------------------------------------------------------------------
echo "<br><b>boot</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (Linux)
    for I in \
      "runlevel" \
      "chkconfig --list" \
      "cat /etc/sysconfig/grub" \
      "cat /etc/sysconfig/kernel" \
      "cat /etc/lilo.conf"
    do __command; done
    ;;
  (FreeBSD)
    for I in \
      "cat /boot/loader.conf" \
      "rcorder /etc/rc.d/*" \
      "rcorder /usr/local/etc/rc.d/* 2> /dev/null | tee" \
      "rcorder /etc/rc.d/* /usr/local/etc/rc.d/* 2> /dev/null | tee"
    do __command; done
    ;;
esac
for I in \
  "cat /etc/inittab" \
  "cat /etc/rc.sysinit" \
  "cat /etc/rc.local" \
  "cat /boot/grub/menu.lst" \
  "ls -l /etc/rc.d/*" \
  "ls -l /etc/rc1.d/*" \
  "ls -l /etc/rc2.d/*" \
  "ls -l /etc/rc3.d/*" \
  "ls -l /etc/rc4.d/*" \
  "ls -l /etc/rc5.d/*" \
  "ls -l /etc/rc6.d/*" \
  "tail -n 99999 /etc/init.d/*" \
  "tail -n 99999 /etc/rc.d/*" \
  "ls -l /usr/local/etc/rc.d/*" \
  "tail -n 99999 /usr/local/etc/rc.d/*"
do __command; done

# STORAGE ---------------------------------------------------------------------
echo "<br><b>storage</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (Linux)
    for I in \
      "find /dev/disk" \
      "find /dev/mapper" \
      "find /dev/mpath" \
      "find /dev/tape" \
      "find /dev/lin_tape" \
      "cat /etc/lin_taped.conf" \
      "find /dev/IBM*" \
      "find /dev/cciss" \
      "multipath -l" \
      "multipath -ll" \
      "cat /etc/hba.conf" \
      "cat /etc/multipath.conf"
    do __command; done
    ;;
  (FreeBSD)
    for I in \
      "camcontrol devlist" \
      "atacontrol list" \
      "gpart list" \
      "gpart show" \
      "beadm list" \
      "mount -p | column -t"
    do __command; done
    ;;
esac
for I in \
  "df -Pm | column -t" \
  "df -Pi | column -t" \
  "mount | column -t" \
  "cat /etc/fstab" \
  "cat /etc/mtab" \
  "cat /etc/xtab" \
  "cat /etc/lvm/lvm.conf" \
  "geli list" \
  "mdconfig -l" \
  "vgs" \
  "pvs" \
  "lvs" \
  "vgdisplay" \
  "vgdisplay -v" \
  "lvdisplay" \
  "pvdisplay" \
  "zfs list" \
  "zfs list -t all" \
  "zfs upgrade" \
  "zpool list" \
  "zpool status" \
  "zpool upgrade"
do __command; done

# SOFTWARE --------------------------------------------------------------------
echo "<br><b>software</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (Linux)
    for I in \
      "rpm -qa" \
      "yum list installed" \
      "tail -n 9999 /etc/yum.repos.d/*" \
      "eix -I" \
      "dpkg --list"
    do __command; done
    ;;
  (FreeBSD)
    for I in \
      "pkg_info" \
      "portaudit" \
      "pkg info" \
      "pkg audit"
    do __command; done
    ;;
  (SunOS)
    for I in \
      "pkginfo"
    do __command; done
    ;;
esac
for I in \
  "ls -l /opt" \
  "ls -l /opt/*"
do __command; done
for I in \
  "find / -type f -iname dsmserv.err | xargs tail -n 99999" \
  "find / -type f -iname dsmserv.opt | xargs tail -n 99999" \
  "find / -type f -iname volhist.dat | xargs tail -n 99999" \
  "find / -type f -iname devconf.dat | xargs tail -n 99999" \
  "find / -type f -iname logattr.chk | xargs tail -n 99999" \
  "find / -type f -iname dsm.sys | xargs tail -n 99999" \
  "find / -type f -iname dsm.opt | xargs tail -n 99999" \
  "find / -type f -iname Tivoli_Storage_Manager_InstallLog.log | xargs tail -n 99999" \
  "find / -type f -iname tsm.pwd"
do __command TSM; done

# PRINTING --------------------------------------------------------------------
echo "<br><b>printing</b><br>" >> ${OUTFILE}
case ${UNAME} in
  (*)
    :
    ;;
esac
for I in \
  "lpq" \
  "lpc status all"
do __command; done

cat >> ${OUTFILE} << __EOF
</body>
</html>
__EOF

# du -mxS / | sort -n | tail -5
# grep -i kill /var/log/messages |wc -l
# mpstat 2 10
# dstat --top-io --top-bio
# python -V
# perl -v
# httpd -v or apache2 -v
# java -version
# mysql --version

# https://github.com/BashtonLtd/whatswrong/blob/master/whatswrong
# http://bhami.com/rosetta.html
# http://www.unixporting.com/quickguide.html
# http://unixguide.net/cgi-bin/unixguide.cgi

# more /etc/release
#
#                           Oracle Solaris 11.1 SPARC
# Copyright (c) 1983, 2012, Oracle and/or its affiliates.  All rights reserved.
#                          Assembled 19 September 2012
#
# more /etc/cluster/release
#
#               Oracle Solaris Cluster 4.1 0.18.2 for Solaris 11 sparc
# Copyright (c) 2000, 2012, Oracle and/or its affiliates. All rights reserved.

# POSTFIX: postqueue -p
# POSTFIX: qshape ALL
# POSTFIX: qshape defer
# POSTFIX: qshape deferred

