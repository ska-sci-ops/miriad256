# syntax=docker/dockerfile:1
FROM ubuntu:22.04
RUN apt-get update 
RUN apt-get install build-essential git libreadline-dev libreadline8 gfortran pgplot5 wcslib-dev libwcs7 libcfitsio9 libcfitsio-dev python3 python3-pip -y
RUN pip install meson ninja
COPY . /app
WORKDIR /app
RUN meson build --wipe --prefix=/usr/local/miriad; cd build; meson compile; meson install
