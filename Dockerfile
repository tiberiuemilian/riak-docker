ARG os_family=ubuntu
ARG os_version=16.04

FROM ${os_family}:${os_version}

ARG riak_version=1.5.2
ARG riak_home=/usr/lib/riak
ARG riak_flavor=ts
ARG riak_pkg=riak-ts
ARG pkg_format=deb

ENV OS_FAMILY ${os_family}
ENV OS_VERSION ${os_version}

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

ENV RIAK_VERSION ${riak_version}
ENV RIAK_HOME ${riak_home}
ENV RIAK_FLAVOR ${riak_flavor}

# Install essentials; Install Riak TS from its specific repo; Clean up APT cache
RUN apt-get update \
&& apt-get dist-upgrade -y \
&& apt-get install -y apt-utils \
&& apt-get install -y apt-transport-https \
&& apt-get install -y python python-six python-pkg-resources python-openssl \
&& apt-get install -y curl \
&& apt-get install -y libapr1 realpath jq unzip \
&& apt-get install -y iproute iputils-ping net-tools telnet \
&& apt-get install -y vim \
&& curl -s https://packagecloud.io/install/repositories/basho/${riak_pkg}/script.${pkg_format}.sh | bash \
&& apt-get install -y ${riak_pkg}=${riak_version}-1 \
&& curl -sSL "https://github.com/basho-labs/riak_explorer/releases/download/1.4.1/riak_explorer-1.4.1.patch-ubuntu-14.04.tar.gz" | tar -zxf - -C $RIAK_HOME --strip-components 2 \
&& for f in riak_pb riak_kv riak_ts riak_dt riak_search riak_yokozuna;do rm -f $RIAK_HOME/lib/basho-patches/$f*; done \
&& rm -rf /var/lib/apt/lists/* /tmp/*

# Expose default ports
EXPOSE 8087
EXPOSE 8098

# Expose volumes for data and logs
VOLUME /var/log/riak
VOLUME /var/lib/riak

# Install custom start script
COPY riak-cluster.sh $RIAK_HOME/riak-cluster.sh
RUN chmod a+x $RIAK_HOME/riak-cluster.sh

# Install custom hooks
COPY prestart.d /etc/riak/prestart.d
COPY poststart.d /etc/riak/poststart.d

# Prepare for bootstrapping schemas
RUN mkdir -p /etc/riak/schemas

WORKDIR /var/lib/riak

CMD ["bash", "-c", "$RIAK_HOME/riak-cluster.sh"]


