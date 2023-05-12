VerifiedX
=========

VerifiedX is an official project of the [Honeytree Technologies](https://honeytreetech.com) and [Newsie.social,](https://Newsie.social). It serves as a directory and tool to discover and verify accounts on Mastodon and other federated social media platforms.

This beta application is still in its early stages, so users should anticipate occasional bugs, changes, and disruptions.

VerifiedX already powers several sites, including: [VerifiedJournalist.org](https://verifiedjournalist.org), [Lawstodon.org](https://lawstodon.org), and [Verified.thecanadian.social](https://Verified.thecanadian.social), which utilize VerifiedX's searchable directory and verification tools to provide users with accurate and reliable information and engagement metrics on their accounts.

VerifiedX is a valuable resource for anyone seeking to connect their Mastodon account to verified profiles. With Mastodon's vast network of servers and no dedicated team to verify account identities and information, there is a risk of impersonation. By linking their Mastodon account to a VerifiedX profile, users can establish their credibility, legitimacy, and accountability, fostering transparency and trust on the platform.

Furthermore, the service assists readers in discovering and following verified accounts on Mastodon, increasing their visibility and traffic.

The upcoming version of the service will concentrate on tackling federated social media challenges and enhancing the discoverability and value of content and profiles.

For updates, feature suggestions, or complaints, please follow @jeff@Newsie.social.

## <a name="pre-requisites"></a>**Pre-requisites** 
- A machine running **Ubuntu 20.04** or **Debian 11** that you have root access to
- A **domain name** (or a subdomain) for the Mastodon server, e.g. example.com
- An e-mail delivery service or other **SMTP server**

You will be running the commands as root. If you aren’t already root, switch to root: sudo su -
### <a name="system-repositories"></a>**System repositories** 
Make sure curl, wget, gnupg, apt-transport-https, lsb-release and ca-certificates is installed first:

	apt install -y curl wget gnupg apt-transport-https lsb-release ca-certificates
	#### <a name="node-js"></a>**Node.js** 
	curl -sL https://deb.nodesource.com/setup\_16.x | bash -

	sudo apt -get install -y nodejs
### <a name="system-packages"></a>**System packages** 
	apt update

	apt install -y imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file \

	git-core  g++ libprotobuf-dev protobuf-compiler pkg-config gcc autoconf bison \

	build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev \

	libncurses5-dev libffi-dev libgdbm-dev nginx postgresql postgresql-contrib \

	libidn11-dev libicu-dev libjemalloc-dev
#### **Install Yarn**
	curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null

	echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

	sudo apt update && sudo apt install -y yarn

	corepack *enable*

	yarn *set* version classic
#### **Install Redis**
	curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

	echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb\_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

	sudo apt update

	sudo apt install -y redis

	sudo systemctl daemon-reload

	sudo systemctl enable redis-server

	sudo systemctl start redis-server

####
#### **Install Redis**
	curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

	echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb\_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

	sudo apt update

	sudo apt install -y redis

	sudo systemctl daemon-reload

	sudo systemctl enable redis-server

	sudo systemctl start redis-server
	#### **Install ElasticSearch**
	curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg

	echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

	sudo apt update

	sudo apt install -y elasticsearch

For security edit /etc*/*elasticsearch/elasticsearch.yml to set network.host

. . .

\# ---------------------------------- Network -----------------------------------

\#

\# Set the bind address to a specific IP (IPv4 or IPv6):

	\#network.host: localhost
### Enable and start service
	sudo systemctl daemon-reload

	sudo systemctl enable elasticsearch

	sudo systemctl start elasticsearch
	### <a name="installing-ruby"></a>**Installing RVM** 
	sudo apt install -y software-properties-common

	sudo apt-add-repository -y ppa:rael-gc/rvm

	sudo apt update

	sudo apt install -y rvm

	echo 'source "/etc/profile.d/rvm.sh"' >> ~/.bashrc

	source ~/.bashrc

	rvm install 3.2.0

**Create user**

	adduser --disabled-login verifiedx

	sudo usermod -a -G rvm verifiedx

	sudo usermod -a -G verifiedx www-data

	su - verifiedx** 

Setup ssh, paste your public key into .ssh/autorized\_keys

Set RVM for user

	echo 'source "/etc/profile.d/rvm.sh"' >> ~/.bashrc

	rvm user gemsets

	mkdir /home/verifiedx/.rvm/bin

	ln -s /usr/share/rvm/bin/rvm /home/verifiedx/.rvm/bin/rvm

Create application.yml, default path is ~/apps/verifiedx/shared/config/application.yml

Do not forget to generate rails secret and put it in the application.yml

**Setup Services and nginx configuration**

Create services from templates in dist folder

	/etc/systemd/system/verifiedx.service

	/etc/systemd/system/sidekiq.service

Authorize user to manage those services by creating sudoer file: /etc/sudoers.d/verifiedx

	%verifiedx ALL=NOPASSWD: /bin/systemctl \* sidekiq

	%verifiedx ALL=NOPASSWD: /bin/systemctl kill -s TSTP sidekiq

	%verifiedx ALL=NOPASSWD: /bin/systemctl \* verifiedx

Enable services

	sudo systemctl enable verifiedx

	sudo systemctl enable sidekiq

**Deploy with capistrano**

	cap production deploy

	cap production invoke:rake TASK=searchkick:reindex:all

Once all these done and app is working correctly, install certbot to install certificate

	sudo snap install core; sudo snap refresh core

	sudo snap install --classic certbot

	sudo ln -s /snap/bin/certbot /usr/bin/certbot

certbot …
