#!/usr/bin/ksh
# Sasi Chand
# @ sasi.chand@global.ntt
# or
# @ eyetnz@gmail.com (Simplyunix)

logname=/root/post_sddpcm_to_aixpcm.log
savedir=/root/save_sddpcm_to_aixpcm

#------------------------------------------------
main()
{
mkdir -p $savedir

echo "####### Check available options based on your controller type"
echo "Executing manage_disk_drivers -l |grep -i [svc or 2107ds8k]"
for controller_type in svc 2107ds8k
do
  manage_disk_drivers -l |grep -i $controller_type
  echo
  echo "####### Next controller is $controller_type ..................."
done

echo "####### Check current disk attributes settings "queue_depth reserve_policy algorithm""
echo "Executing lsattr -El [hdisk] -a algorithm -a reserve_policy -a queue_depth"
for hdisk in `lsdev -Cc disk| awk '{print $1}'`
do
  echo $hdisk
  lsattr -El $hdisk -a algorithm -a reserve_policy -a queue_depth
  echo
  echo "Next disk .............................."
done
echo "-------------------------------------------------------------------------"

echo "####### After the reboot, AIX PCM is now in control of MPIO on this system."
echo "Executing manage_disk_drivers -l |grep -i [svc]"
manage_disk_drivers -l | grep -i svc
lsmpio
echo "-------------------------------------------------------------------------"

echo "####### Remove obsolete packages sddpcm"
echo "Executing installp -u -g [package name]"
for lpp in $(lslpp -Lc | egrep "^devices.sddpcm" |cut -d':' -f2)
do
  echo $lpp
  echo installp -u -g $lpp
done
echo "-------------------------------------------------------------------------"

echo "####### Remove obsolete packages devices.fcp.disk.ibm.mpio"
echo "Executing installp -u -g [package name]"
for lpp in $(lslpp -Lc | egrep "^devices.fcp.disk.ibm.mpio" |cut -d':' -f2)
do
  echo $lpp
  echo installp -u -g $lpp
done
echo "-------------------------------------------------------------------------"

echo "####### Should be Not found as expected, meaning it has been removed successfully"
echo "Executing lslpp -l | grep sddpcm and pcmpath query device"
lslpp -l | grep sddpcm
pcmpath query device
echo "-------------------------------------------------------------------------"

echo "####### After the reboot, AIX PCM is now in control of MPIO on this system."
manage_disk_drivers -l | grep -i svc
lsmpio
echo "-------------------------------------------------------------------------"

echo "####### Final Reboot the system for the change to take effect"
echo "********************** ATTENTION *************************"
echo "Executing....... shutdown -Fr"
echo "Are you sure you want to restart the server? (y/n)"
read RESP
if [ "$RESP" = "y" ];then
  echo "Executing shutdown -Fr"
  echo shutdown -Fr
else
  echo "Exiting........"
  echo "Only options allowed are y and n"
  exit
fi
echo "-------------------------------------------------------------------------"

}

main 2>&1 | tee $logname
