#!/usr/bin/env bash

set -ue


export STELLAR_HOME="/opt/stellar"
# export PGHOME="$STELLAR_HOME/postgresql"
# export SUPHOME="$STELLAR_HOME/supervisor"
export COREHOME="$STELLAR_HOME/core"

# conditionally install via different methods
install_pkg=0
install_src=0
install_aws=1



# run_silent is a utility function that runs a command with an abbreviated
# output provided it succeeds.
function run_silent() {
	local LABEL=$1
	shift
	local COMMAND=$1
	shift
	local ARGS=$@
	local OUTFILE="/tmp/run_silent.out"

	echo -n "$LABEL: "
	set +e

	$COMMAND $ARGS &> $OUTFILE

	if [ $? -eq 0 ]; then
    echo "ok"
	else
	  echo "failed!"
		echo ""
		cat $OUTFILE
		exit 1
	fi

	set -e
} 

# install deps
apt-get update

apt install wget gnupg2 -y
# wget -qO - https://apt.stellar.org/SDF.asc | apt-key add -
# echo "deb https://apt.stellar.org $(lsb_release -cs) stable" | tee -a /etc/apt/sources.list.d/SDF.list
# apt-get update

apt-get install -y $STELLAR_CORE_BUILD_DEPS unzip 

if [ $install_pkg -eq 1 ]
then
    echo "--> Installing stellar core from package"
    mkdir -p $COREHOME
    mkdir -p /opt/stellar
    export STELLAR_CORE_VERSION=17.3.0.focal
    export DEBIAN_FRONTEND=noninteractive
    apt-get -y install gnupg1 rsync wget
    wget -qO - https://apt.stellar.org/SDF.asc | apt-key add -
    echo "deb https://apt.stellar.org focal stable" >/etc/apt/sources.list.d/SDF.list
    echo "deb https://apt.stellar.org focal unstable" >/etc/apt/sources.list.d/SDF-unstable.list
    apt-get update
    # apt-get install -y stellar-core=${STELLAR_CORE_VERSION}
    apt-get install -y stellar-core 
    
    # apt-get install -y stellar-horizon=${HORIZON_VERSION}
    apt-get clean

    pushd $COREHOME
	# run_silent "chown-core" chown -R stellar:stellar .

    # chown -R  .

    cd ~

    echo "Done installing stellar-core ..."
fi

if [ $install_aws -eq 1 ]
then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    rm awscliv2.zip
    cd ~
fi



if [ $install_src -eq 1 ]
then
    # # clone, compile, and install stellar core
    echo "--> clone, compile, and install stellar core from source"
    STELLAR_CORE_VERSION="v17.2.0rc2"
    apt install  gcc-10
    git clone --branch $STELLAR_CORE_VERSION --recursive --depth 1 https://github.com/stellar/stellar-core.git

    cd stellar-core
    ./autogen.sh
    ./configure
    make
    make install
    cd ..
fi

# install confd for config file management
wget -nv -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64
chmod +x /usr/local/bin/confd

# cleanup
rm -rf stellar-core
apt-get remove -y $STELLAR_CORE_BUILD_DEPS
apt-get autoremove -y

# install deps
apt-get install -y $STELLAR_CORE_DEPS

# cleanup apt cache
rm -rf /var/lib/apt/lists/*



