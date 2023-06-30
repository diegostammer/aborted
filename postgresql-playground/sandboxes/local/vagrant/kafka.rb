# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
require 'open-uri'
require 'nokogiri'

def get_latest_kafka_version
  url = 'https://downloads.apache.org/kafka/'
  html = URI.open(url)
  doc = Nokogiri::HTML(html)

  latest_version = doc.css('a').map(&:content).select { |content| content.match?(/^(\d+\.\d+\.\d+)$/) }.max

  latest_version
end

latest_version = get_latest_kafka_version
unless latest_version == nil
    KAFKA_LATEST_FULL = latest_version
else
    raise "Failed to retrieve the latest LTS Kafka versions."
end

KAFKA_SCALA_VERSION = '2.13'

$script_ubuntu_install_kafka = <<-'SCRIPT'
echo "###############################################################################"
echo "##                          INSTALL KAFKA                                    ##"
echo "###############################################################################"
sudo apt install openjdk-11-jre-headless -y
cd /tmp
wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz
sudo tar -xzf kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz
sudo mkdir /usr/local/kafka-server
sudo mv kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION} /usr/local/kafka-server
sudo rm kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz


cat << EOF | sudo tee /etc/systemd/system/zookeeper.service
[Unit]
Description=Apache Zookeeper Server
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
ExecStart=/usr/local/kafka-server/bin/zookeeper-server-start.sh /usr/local/kafka-server/config/zookeeper.properties
ExecStop=/usr/local/kafka-server/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target

EOF


cat << EOF | sudo tee /etc/systemd/system/kafka.service
[Unit]
Description=Apache Kafka Server
Documentation=http://kafka.apache.org/documentation.html
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
ExecStart=/usr/local/kafka-server/bin/kafka-server-start.sh /usr/local/kafka-server/config/server.properties
ExecStop=/usr/local/kafka-server/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target

EOF


sudo systemctl daemon-reload
sudo systemctl enable --now zookeeper.service
sudo systemctl enable --now kafka.service
sudo systemctl status kafka zookeeper
SCRIPT


$script_ubuntu_install_kafka = <<-'SCRIPT'
echo "###############################################################################"
echo "## INSTALL CLUSTER MANAGER FOR APACHE KAFKA (CMAK)                           ##"
echo "###############################################################################"
sudo apt install unzip -y
cd /tmp
sudo git clone https://github.com/yahoo/CMAK.git
sudo sed -i 's/cmak.zkhosts=.*/cmak.zkhosts="localhost:2181"/g' /./CMAK/conf/application.conf
cd CMAK
sudo ./sbt clean dist
cd target/universal
sudo unzip cmak-.*.zip
sudo mkdir /usr/local/cmak
sudo mv cmak-* /usr/local/cmak
sudo ln -s /usr/local/cmak/cmak-* /usr/local/cmak/cmak
sudo chmod +x /usr/local/cmak/cmak/bin/cmak
sudo ln -s /usr/local/cmak/cmak/bin/cmak /usr/local/bin/cmak
cd /tmp
sudo rm -rf CMAK
cd /usr/local/cmak/cmak/bin
sudo ./cmak
SCRIPT