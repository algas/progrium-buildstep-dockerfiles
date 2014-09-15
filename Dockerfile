FROM ubuntu:14.04
MAINTAINER progrium "progrium@gmail.com"

RUN apt-get update
ADD ./stack/ /build
RUN /build/prepare
