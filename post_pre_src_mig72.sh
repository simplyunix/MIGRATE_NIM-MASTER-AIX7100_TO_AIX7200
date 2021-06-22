#!/usr/bin/ksh
# Sasi Chand
# @ eyetnz@gmail.com

logname=/stage/`hostname`/post_scr_mig72.log
savedir=/stage/`hostname`/save_nim_mig72

#------------------------------------------------
main()
{
mkdir -p $savedir

echo "####### Check the OSLEVEL"
echo "----------------------------------------------------------------"
oslevel -s
echo "----------------------------------------------------------------"

echo "####### Check if nim master exists"
echo "----------------------------------------------------------------"
lsnim -l master
echo "----------------------------------------------------------------"

echo "####### At this point, NIM master has been successfully migrated to AIX7.2"
echo "----------------------------------------------------------------"
echo "YUY!!!!!!"
echo "----------------------------------------------------------------"

echo "####### Lets create the LPP Source of AIX72TL5SP2"
mkdir -p /export/nim/lpp_source/AIX72TL5SP2
echo "----------------------------------------------------------------"

echo "####### Create mount points CD1 and CD2 iso as /mnt/v1 /mnt/v2"
mkdir -p /mnt/v1
mkdir -p /mnt/v2
echo "----------------------------------------------------------------"

echo "####### Mount the iso images"
loopmount -i /stage/AIX7200_BASE/AIX_v7.2_Install_7200-05-02-2113_DVD_1_of_2_042021_LCD8223016.iso -o "-V cdrfs -o ro" -m /mnt/v1
loopmount -i /stage/AIX7200_BASE/AIX_v7.2_Install_7200-05-02-2113_DVD_2_of_2_042021_LCD8223116.iso -o "-V cdrfs -o ro" -m /mnt/v2
echo "----------------------------------------------------------------"

echo "####### Check if the iso's are mounted and accessible"
df -g | grep mnt
echo "----------------------------------------------------------------"

echo "####### Check the contents..... of both CD's"
ls -ltr /mnt/v1
echo "----------------------------------------------------------------"
ls -ltr /mnt/v2
echo "----------------------------------------------------------------"

echo "####### Run bffcreate . Copy the software to the specified location for future use."
bffcreate -d /mnt/v1 -t /export/nim/lpp_source/AIX72TL5SP2 -X all
echo "----------------------------------------------------------------"
bffcreate -d /mnt/v2 -t /export/nim/lpp_source/AIX72TL5SP2 -X all
echo "----------------------------------------------------------------"

echo "####### Create AIX 7.2 lpp_source NIM Resource"
# mkres -N 'AIX72TL5SP2' -t 'lpp_source' -s 'master' -l '/export/nim/lpp_source/AIX72TL5SP2'
# nim -o define -t lpp_source -a Attribute=Value ... lpp_sourceName
nim -o define -t lpp_source -a server=master -a location=/export/lpp_source/LPP_AIX72TL5SP2 -a source=/export/nim/lpp_source/AIX72TL5SP2 LPP_AIX72TL5SP2
echo "----------------------------------------------------------------"

echo "####### Check to confirm if the lpp_source has been created successfully"
lsnim -t lpp_source | grep 72
echo "----------------------------------------------------------------"
lsnim -l LPP_AIX72TL5SP2
nim -o showres LPP_AIX72TL5SP2 | grep bos.mp64
echo "----------------------------------------------------------------"

echo "####### Unmount the CD iso images..."
umount /mnt/v1
umount /mnt/v2
echo "----------------------------------------------------------------"
nim -o showres LPP_AIX72TL5SP2 | grep bos.mp64
echo "----------------------------------------------------------------"

echo "####### Create AIX 7.2 spot NIM Resource"
nim -o define -t spot -a server=master -a location=/export/spot/SPOT_AIX72TL5SP2 -a source=LPP_AIX72TL5SP2 -a installp_flags=-aQg SPOT_AIX72TL5SP2
echo "----------------------------------------------------------------"

echo "####### Show progress"
nim -o check SPOT_AIX72TL5SP2
nim -o lppchk -a show_progress=yes SPOT_AIX72TL5SP2

}

main 2>&1 | tee $logname
