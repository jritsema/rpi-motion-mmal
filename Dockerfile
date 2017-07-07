### jritsema/rpi-motion-mmal

# motion-mmal seems to depend on libraries that are only in wheezy, not jessie
FROM resin/rpi-raspbian:wheezy-20170628

# build raspberry pi userland tools from source (allows access to gpu, camera, etc.)
RUN apt-get update \
    && apt-get upgrade \
    && apt-get install -y \
      build-essential \
      cmake \
      curl \
      git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN cd \
      && git config --global http.sslVerify false \
      && git clone --depth 1 https://github.com/raspberrypi/userland.git \
      && cd userland \
      && ./buildme

# add raspistill to path
ENV PATH /opt/vc/bin:/opt/vc/lib:$PATH

# update library path (to get past: raspistill: error while loading shared libraries: libmmal_core.so: cannot open shared object file: No such file or directory)
ADD 00-vmcs.conf /etc/ld.so.conf.d/
RUN ldconfig

# install the motion-mmal software
RUN apt-get update && apt-get install -y motion libjpeg62 libjpeg62-dev libavformat53 libavformat-dev libavcodec53 libavcodec-dev libavutil51 libavutil-dev libc6-dev zlib1g-dev libmysqlclient18 libmysqlclient-dev libpq5 libpq-dev wget libav-tools

# overwrite custom motion executable and config file made for pi
RUN wget --no-check-certificate https://www.dropbox.com/s/xdfcxm5hu71s97d/motion-mmal.tar.gz \
    && tar zxvf motion-mmal.tar.gz \
    && sudo mv motion /usr/bin/motion \
    && sudo mv motion-mmalcam.conf /etc/motion.conf

# install node.js

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 4.0.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-armv6l.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-armv6l.tar.gz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-armv6l.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-armv6l.tar.gz" SHASUMS256.txt SHASUMS256.txt.asc

# install image recognition tools
RUN npm install -g https://github.com/jritsema/rekognize.git
RUN npm install -g https://github.com/jritsema/rekognotify.git#0.1.0-rc.4

ENTRYPOINT ["motion"]

