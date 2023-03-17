FROM mono:6

ARG DEBIAN_FRONTEND=noninteractive

ARG OPENHV_VERSION_ARG

ENV OPENHV_VERSION=$OPENHV_VERSION_ARG

RUN apt-get update && \
  apt-get upgrade -y

RUN apt-get install -y \
  ca-certificates \
  lsb-release \
  curl \
  unzip \
  libfreetype6 \
  libopenal1 \
  liblua5.1-0 \
  libsdl2-2.0-0 \
  git \
  build-essential \
  --no-install-recommends

RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /srv/openhv

RUN useradd openhv -r -d /srv/openhv -s /bin/bash
RUN chown openhv:openhv /srv/openhv

USER openhv
WORKDIR /srv/openhv

RUN git clone --depth=1 \
  -b $OPENHV_VERSION https://github.com/OpenHV/OpenHV.git \
  application

WORKDIR /srv/openhv/application

RUN make \
  RUNTIME=mono \
  TARGETPLATFORM=unix-generic && \
  make version

EXPOSE 1234/tcp

ENTRYPOINT /srv/openhv/application/launch-dedicated.sh
