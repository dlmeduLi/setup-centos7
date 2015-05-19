#!/bin/bash
log_file="install-centos7.log"

echo "" >> ${log_file}
echo "#########  start time  ###########" >> ${log_file}
echo `date` >> ${log_file}
echo "" >> ${log_file}

if [ `id -u` -ne 0 ];then
	echo "run this script as root"
	exit -1
fi

# config ssh
echo "[*] Configing sshd..." | tee -a ${log_file}

sed -i "s/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g" /etc/ssh/sshd_config >> ${log_file} 2>&1
sed -i "s/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/g" /etc/ssh/sshd_config >> ${log_file} 2>&1
systemctl restart sshd.service >> ${log_file} 2>&1

echo "[*] ssh config DONE..." | tee -a ${log_file}

# config yum and wget
echo "[*] Configing yum..." | tee -a ${log_file}

echo  "proxy=http://210.47.248.177:3128" >> /etc/yum.conf 
echo "http-proxy = 210.47.248.177:3128" > ~/.wgetrc

wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo  >> ${log_file} 2>&1
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo >> ${log_file} 2>&1
yum makecache >> ${log_file} 2>&1
yum update -y  >> ${log_file} 2>&1

# requrie rpm
yum install tmux openssl098e net-snmp.x86_64 1:5.7.2-20.el7 net-snmp-utils.x86_64 1:5.7.2-20.el7 R -y  >> ${log_file} 2>&1

echo "[*] yum config DONE..." | tee -a ${log_file}

# install MSM(raid contrl software)
echo "[*] Configing raid contrl..." | tee -a ${log_file}

tar -zxvf 15.03.01.00_Linux-64_MSM.gz >> ${log_file} 2>&1
cd disk
./RunRPM.sh -au >> ${log_file} 2>&1
cd ..

echo "[*] raid contrl DONE..." | tee -a ${log_file}

echo "[*] Installing Bioinformatics Sotware..." | tee -a ${log_file}

# install samtools
echo "    Installing samtools..." | tee -a ${log_file}
tar -zxvf samtools-1.2.tar.gz >> ${log_file} 2>&1

cd htslib/
make >> ${log_file} 2>&1
make install >> ${log_file} 2>&1
cd .. 

cd bcftools/
make >> ${log_file} 2>&1
make install >> ${log_file} 2>&1
cd .. 

cd samtools/
make >> ${log_file} 2>&1
make install >> ${log_file} 2>&1
cd ..

# install FastQC
echo "    Installing fastqc..." | tee -a ${log_file}
unzip fastqc_v0.11.3.zip >> ${log_file} 2>&1
chmod 755 FastQC/fastqc >> ${log_file} 2>&1
cp -r FastQC/ /usr/local/ >> ${log_file} 2>&1
ln -s /usr/local/FastQC/fastqc /usr/local/bin/ >> ${log_file} 2>&1

# install Rstudio
echo "    Installing Rstudio..." | tee -a ${log_file}
yum install --nogpgcheck rstudio-server-0.98.1103-x86_64.rpm -y >> ${log_file} 2>&1
firewall-cmd --zone=public --add-port=8787/tcp --permanent >> ${log_file} 2>&1
firewall-cmd --reload >> ${log_file} 2>&1

echo "[*] Bioinformatics Sotware DONE..." | tee -a ${log_file}

cp skel-README.txt /etc/skel/README.txt
echo "" >> ${log_file}
echo "########   end time   ############" >> ${log_file}
echo `date` >> ${log_file}
echo "" >> ${log_file}

