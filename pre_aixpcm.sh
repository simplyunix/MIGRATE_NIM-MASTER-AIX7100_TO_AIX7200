#!/usr/bin/ksh
# Sasi Chand
# @ sasi.chand@global.ntt
# or
# @ eyetnz@gmail.com (Simplyunix)

logname=/root/pre_sddpcm_to_aixpcm.log
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

echo "####### Change disk attributes queue_depth=32 reserve_policy=no_reserve alogrithm=shortest_queue"
echo "Executing [chdef -a queue_depth=32 -c disk -s fcp -t mpioosdisk]"
echo chdef -a queue_depth=32 -c disk -s fcp -t mpioosdisk
echo "Executing [chdef -a reserve_policy=no_reserve -c disk -s fcp -t mpioosdisk]"
echo chdef -a reserve_policy=no_reserve -c disk -s fcp -t mpioosdisk
echo "Executing [chdef -a algorithm=shortest_queue -c PCM -s friend -t fcpother]"
echo chdef -a algorithm=shortest_queue -c PCM -s friend -t fcpother
echo "-------------------------------------------------------------------------"

echo "####### Note: It is highly recommended that a bosboot be executed when the "chdef" command has been issued prior to a reboot to avoid losing changes to the ODM."
echo "Checking the current bootlist....................."
echo "bootlist settings on the following hdisk"
bootlist -m normal -o
echo "BOSBOOT IT......"
echo "Would you like to write the bootblock image? (y/n)"
read RESP
if [ "$RESP" = "y" ];then
  echo "Executing bosboot -a"
  echo bosboot -a
else
  echo "Exiting........"
  echo "Only options allowed are y and n. The script will stop here. Boot image not written"
  exit
fi
echo "-------------------------------------------------------------------------"

echo "####### Run the manage_disk_drivers command to switch to AIX PCM and reboot the system."
echo "Executing manage_disk_drivers -d IBMSVC -o AIX_AAPCM"
echo manage_disk_drivers -d IBMSVC -o AIX_AAPCM
echo "-------------------------------------------------------------------------"

echo "####### Reboot the system for the change to take effect"
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
