# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'net/http'
require 'json'

def get_latest_postgresql_versions
    url = URI.parse('https://www.postgresql.org/ftp/source/')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true if url.scheme == 'https'
    response = http.get(url.request_uri)

    if response.code == '200'
        versions = response.body.scan(/v(\d+\.\d+\.\d+|\d+\.\d+)/).flatten.map { |v| v.split('.').map(&:to_i) }
        latest_full_version = versions.max
        latest_major_version = latest_full_version.take(1)
        latest_minor_version = latest_full_version.take(2)

        return latest_full_version.join('.'), latest_major_version.join('.'), latest_minor_version.join('.')
    else
        return nil
    end

end

full_version, major_version, minor_version = get_latest_postgresql_versions
unless full_version == nil
    POSTGRESQL_LATEST_FULL = full_version
    POSTGRESQL_LATEST_MAJOR = major_version
    POSTGRESQL_LATEST_MINOR = minor_version
else
    raise "Failed to retrieve the latest PostgreSQL versions."
end

$script_ubuntu_install_postgresql = <<-'SCRIPT'
echo "###############################################################################"
echo "##                          INSTALL POSTGRESQL                               ##"
echo "###############################################################################"
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null
sudo apt update
sudo apt upgrade -y
sudo apt install postgresql-${POSTGRESQL_VERSION} postgresql-client-${POSTGRESQL_VERSION} -y
pg_ctlcluster ${POSTGRESQL_VERSION} main start
SCRIPT