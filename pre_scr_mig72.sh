#!/usr/bin/ksh
# Sasi Chand
# @ eyetnz@gmail.com

logname=/stage/`hostname`/pre_scr_mig72.log
savedir=/stage/`hostname`/save_nim_mig72

#------------------------------------------------
main()
{
mkdir -p $savedir

echo "####### Save ssh keys"
cd /etc/ssh ; tar cvf $savedir/ssh_keys.tar .

echo "####### Save ssl config"
cd /var ; tar cvf $savedir/var_ssl.tar /var/ssl
echo "####### Save banner"
cp /etc/motd $savedir

echo "####### Save sendmail.cf"
cp /etc/mail/sendmail.cf $savedir

echo "####### Save sudo configs"
cd /etc ; tar cvf $savedir/sudo_configs.tar /etc/sudoers /etc/sudoers.d

echo "####### Save Network and hosts config"
ifconfig -a
echo "-----------------------------------------------"
echo
netstat -rn
echo "-----------------------------------------------"
echo
cp /etc/resolv.conf $savedir

echo "####### Save System config"
cp /etc/environment $savedir
cp /etc/ntp.conf $savedir
cp /etc/netsvc.conf  $savedir
cp /etc/exports $savedir
cp /etc/hosts $savedir
cp /etc/filesystems $savedir
cp /etc/mount.map $savedir
cp /etc/auto_master $savedir
cp /etc/inittab $savedir

echo "####### Run the pre migration checks and review the outputs"
/cdrom/usr/lpp/bos/pre_migration

echo "####### Backup up the system via mksysb to a remote filesystems"
mksysb -i $savedir/`hostname`.pre_migration.mksysb

echo "####### Backup the NIM database"
/usr/lpp/bos.sysmgt/nim/methods/m_backup_db '/stage/kapnim/nimmast.nim.db.backup'

echo "####### Lets create a clone of rootvg with a -B flag"

lspv | grep old_rootvg
echo
echo "Lets clean the ODM.... Remove to free up this disk"
echo
lspv | grep old_rootvg| awk '{print $1}'| while read hdisk
do
  echo "Tidy up for cloning $hdisk"
  echo alt_rootvg_op -X old_rootvg
  echo alt_disk_copy -Bd $hdisk
  echo
  lspv
done

}

main 2>&1 | tee $logname
