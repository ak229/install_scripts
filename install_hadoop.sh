#!/bin/bash

echo "This script will install hadoop on a fresh docker instance of centos 7"

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to use this script"
  exit 1
fi

curl https://raw.githubusercontent.com/abhishekunotech/install_scripts/master/installpasswordless.sh > installpass.sh
bash installpass.sh

cd /opt
mkdir hadoop && cd hadoop

wget http://redrockdigimark.com/apachemirror/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz

tar -zxvf hadoop-2.7.3.tar.gz

curl https://raw.githubusercontent.com/abhishekunotech/install_scripts/master/setJavaEnv.sh > setJavaEnv.sh
source setHadoopEnv.sh

hadoop version

cd $HADOOP_HOME/etc/hadoop


#vim hadoop-env.sh

#line_num_conf_first=`grep -wn configuration meow.txt | head -1 | gawk '{split($1,a,":",seps); print a[1]}' | gawk '{print strtonum($1)}'`

sed -i -r "s/<configuration>//gi" core-site.xml
sed -i -r "s/<\/configuration>//gi" core-site.xml



cat <<EOF >>core-site.xml
<configuration>
<property>
<name>fs.default.name</name>
<value>hdfs://localhost:54310</value>
<description>The name of the default file system. A URI whose
scheme and authority determine the FileSystem implementation. The
uri's scheme determines the config property (fs.SCHEME.impl) naming
the FileSystem implementation class. The uri's authority is used to
determine the host, port, etc. for a filesystem.</description>
</property>
</configuration>
EOF


sed -i -r "s/<configuration>//gi" hdfs-site.xml
sed -i -r "s/<\/configuration>//gi" hdfs-site.xml


cat <<EOF >>hdfs-site.xml
<configuration>
<property>
<name>dfs.replication</name>
<value>1</value>
<description>Default block replication.
The actual number of replications can be specified when the file is created.
The default is used if replication is not specified in create time.
</description>
</property>

<property>
<name>dfs.name.dir</name>
<value>/opt/hadoop/namenode</value>
</property>

<property>
<name>dfs.data.dir</name>
<value>/opt/hadoop/datanode</value>
</property>

<property>
<name>dfs.namenode.datanode.registration.ip-hostname-check</name>
<value>false</value>
</property>
</configuration>
EOF

cp mapred-site.xml.template mapred-site.xml


sed -i -r "s/<configuration>//gi" mapred-site.xml
sed -i -r "s/<\/configuration>//gi" mapred-site.xml


cat <<EOF >>mapred-site.xml
<configuration>
<property>
<name>mapred.job.tracker</name>
<value>localhost:54311</value>
<description>The host and port that the MapReduce job tracker runs
at. If "local", then jobs are run in-process as a single map
and reduce task.
</description>
</property>
</configuration>
EOF

hadoop namenode -format

start-all.sh

jps


curl localhost:50070



figlet -f banner "HADOOP Installed :-)"
figlet -f small "FINISHED Installing Hadoop ..."

sleep 1

