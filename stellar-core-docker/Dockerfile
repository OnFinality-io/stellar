FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

# git tag from https://github.com/stellar/stellar-core
# ARG STELLAR_CORE_VERSION="v17.2.0rc2"
# ENV STELLAR_CORE_VERSION 17.2.0-615.e47d483.focal
ENV STELLAR_CORE_BUILD_DEPS="git curl systemd build-essential pkg-config autoconf automake libtool bison flex libpq-dev wget pandoc vim zlib1g-dev supervisor psmisc"
ARG STELLAR_CORE_DEPS="curl jq libpq5"
ARG CONFD_VERSION="0.16.0"



# install stellar core and confd
ADD install.sh /
RUN /install.sh
RUN apt-get update && apt-get install -y $STELLAR_CORE_BUILD_DEPS gnupg2 unzip && \ 
    apt-get -y install gnupg1 rsync wget && \
    wget -qO - https://apt.stellar.org/SDF.asc | apt-key add - && \
    echo "deb https://apt.stellar.org focal stable" >/etc/apt/sources.list.d/SDF.list && \
    echo "deb https://apt.stellar.org focal unstable" >/etc/apt/sources.list.d/SDF-unstable.list && \
    apt-get update && \
    apt-get install -y stellar-core && \
    apt-get install stellar-archivist && \
    chmod +x /usr/bin/stellar-core

VOLUME /data

# peer port
EXPOSE 11625

# HTTP port (do NOT expose publicly)
EXPOSE 11626

# configuration options, see here for docs:
# https://github.com/stellar/stellar-core/blob/master/docs/stellar-core_example.cfg
ENV HTTP_MAX_CLIENT="128" \
  NETWORK_PASSPHRASE="Public Global Stellar Network ; September 2015" \
  INITIALIZE_DB=true

ADD ready.sh /
ADD confd /etc/confd

ADD entry.sh /
ENTRYPOINT ["/entry.sh"]

CMD ["stellar-core", "run", "--conf", "/stellar-core.cfg"]
