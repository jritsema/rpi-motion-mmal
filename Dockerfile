### jritsema/rpi-motion-mmal

# motion-mmal seems to depend on libraries that are only in wheezy, not jessie
FROM resin/rpi-raspbian:wheezy

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
RUN sudo apt-get install -y motion \
    && cd /tmp \
    && sudo apt-get install -y libjpeg62 libjpeg62-dev libavformat53 libavformat-dev libavcodec53 libavcodec-dev libavutil51 libavutil-dev libc6-dev zlib1g-dev libmysqlclient18 libmysqlclient-dev libpq5 libpq-dev \
    && wget --no-check-certificate https://www.dropbox.com/s/xdfcxm5hu71s97d/motion-mmal.tar.gz \
    && tar zxvf motion-mmal.tar.gz \
    && sudo mv motion /usr/bin/motion \
    && sudo mv motion-mmalcam.conf /etc/motion.conf

