FROM debian:squeeze

ADD ./build.sh /tmp/build.sh
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive /tmp/build.sh

ADD ./stack/configs/etc-profile /etc/profile

ADD ./builder/ /build
RUN xargs -L 1 /build/install-buildpack /tmp/buildpacks < /build/config/buildpacks.txt

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y build-essential uuid-dev libmysqlclient-dev git libxml2-dev libxslt1-dev librsvg2-dev libmagickcore-dev rubygems
RUN gem install foreman


ENV APP_DIR /app
ADD ./swfmill-0.3.1.tar.gz /tmp/swfmill
RUN mkdir -p $APP_DIR/swfmill
RUN apt-get install -y libxml2-dev libxslt1-dev libc6-dev libfreetype6-dev libgcc1 libpng12-dev libstdc++6 zlib1g-dev xsltproc
ADD ./xslt.h /tmp/swfmill/swfmill-0.3.1/src/xslt/xslt.h
RUN cd /tmp/swfmill/swfmill-0.3.1 && ./configure --prefix $APP_DIR/swfmill && make && make install && cd $APP_DIR

ADD http://download.zeromq.org/zeromq-2.2.0.tar.gz /tmp/zeromq-2.2.0.tar.gz
RUN mkdir -p $APP_DIR/zeromq
RUN cd /tmp && tar xzf zeromq-2.2.0.tar.gz && cd /tmp/zeromq-2.2.0 && ./configure --prefix $APP_DIR/zeromq && make && make install && cd $APP_DIR

ADD https://launchpad.net/imagemagick/main/6.8.0-4/+download/ImageMagick-6.8.0-4.tar.gz /tmp/ImageMagick-6.8.0-4.tar.gz
RUN mkdir -p $APP_DIR/ImageMagick
RUN cd /tmp && tar xzf ImageMagick-6.8.0-4.tar.gz && cd /tmp/ImageMagick-6.8.0-4 && ./configure --disable-shared --enable-static --prefix $APP_DIR/ImageMagick && make && make install && cd $APP_DIR

ENV PORT 5000
EXPOSE 5000
