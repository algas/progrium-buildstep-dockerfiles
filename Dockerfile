FROM ubuntu:14.04
MAINTAINER progrium "progrium@gmail.com"

RUN apt-get update
RUN apt-get upgrade
ADD ./stack/ /build
RUN /build/prepare
