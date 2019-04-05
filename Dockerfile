FROM centos:7

MAINTAINER Pierce Harmon <pierceh.dev@gmail.com>

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2019-03-18 \
    LANG=en_US.UTF-8 \
    HOME=/opt/app/ \
    # Set this so that CTRL+G works properly
    TERM=xterm \
    ERL_VERSION=21.2.4 \
    ELIXIR_VERSION=1.8.1

WORKDIR ${HOME}

# Install Erlang
RUN \
    mkdir -p /tmp && \
    yum install -y -q wget unzip make && \
    wget --no-verbose -P /tmp https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -q -y /tmp/epel-release-latest-7.noarch.rpm && \
    yum update -y -q && \
    yum upgrade -y -q --enablerepo=epel && \
    yum install -y -q wxGTK-devel unixODBC-devel && \
    wget --no-verbose -P /tmp/ "https://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_${ERL_VERSION}-1~centos~7_amd64.rpm" && \
    rpm -Uvh "/tmp/esl-erlang_${ERL_VERSION}-1~centos~7_amd64.rpm" && \
    wget --no-verbose -P /tmp/ "https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip" && \
    unzip /tmp/Precompiled.zip -d /usr/local && \
    rm /tmp/Precompiled.zip && \
    mix local.rebar --force && \
    mix local.hex --force

ENV NODE_VERSION="10.14.1"

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
    && for key in \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      B9AE9905FFD7803F25714661B63B535A4C206CA9 \
      77984A986EBC2AA786BC0F66B01FBB92821C587A \
      56730D5401028683275BD23C23EFEFE93C4CFFFE \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      FD3A5288F042B6850C66B31F09FE44734EB7990E \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      4ED778F539E3634C779C87C6D7062848A1AB005C \
      A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    ; do \
      gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
      gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
      gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
    done

RUN set -ex \
    && wget "https://nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" -O node-v$NODE_VERSION-linux-x64.tar.gz \
    && wget "https://nodejs.org/download/release/v$NODE_VERSION/SHASUMS256.txt.asc" -O SHASUMS256.txt.asc \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt | sha256sum -c - \
        && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
        && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc SHASUMS256.txt \
        && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
        && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm set unsafe-perm true

CMD ["/bin/bash"]
