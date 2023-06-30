# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'net/http'
require 'json'

def get_latest_lts_clickhouse_version
    url = 'https://api.github.com/repos/ClickHouse/ClickHouse/releases/latest'
    response = URI.open(url)
    data = JSON.parse(response.read)

    latest_version = data['tag_name'].split('-').first.downcase.gsub('v', '')

    latest_version
end

def get_latest_clickhouse_version
    url = 'https://api.github.com/repos/ClickHouse/ClickHouse/releases'
    response = URI.open(url)
    data = JSON.parse(response.read)

    versions = data.map { |release| release['tag_name'] }
    latest_version = versions.max

    latest_version
end

latest_lts_version = get_latest_lts_clickhouse_version
unless latest_lts_version == nil
    CLICKHOUSE_LATEST_LTS_FULL = latest_lts_version
else
    raise "Failed to retrieve the latest LTS Clickhouse versions."
end

latest_version = get_latest_clickhouse_version
unless latest_version == nil
    CLICKHOUSE_LATEST_FULL = latest_version
else
    raise "Failed to retrieve the latest Clickhouse versions."
end

$script_ubuntu_install_clickhouse = <<-'SCRIPT'
echo "###############################################################################"
echo "##                          INSTALL CLICKHOUSE                               ##"
echo "###############################################################################"
sudo apt-get install -y apt-transport-https ca-certificates dirmngr
GNUPGHOME=$(mktemp -d)
sudo GNUPGHOME="$GNUPGHOME" gpg --no-default-keyring --keyring /usr/share/keyrings/clickhouse-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8919F6BD2B48D754
sudo rm -r "$GNUPGHOME"
sudo chmod +r /usr/share/keyrings/clickhouse-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main" | sudo tee \
    /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y clickhouse-server=${CLICKHOUSE_VERSION} clickhouse-client=${CLICKHOUSE_VERSION} clickhouse-common-static=${CLICKHOUSE_VERSION}
sudo service clickhouse-server start
SCRIPT