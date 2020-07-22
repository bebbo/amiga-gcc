FROM debian:10.4-slim AS builder

RUN echo deb http://deb.debian.org/debian/ buster main >/etc/apt/sources.list &&\
 echo deb-src http://deb.debian.org/debian/ buster main >>/etc/apt/sources.list &&\
 echo deb http://security.debian.org/debian-security buster/updates main >>/etc/apt/sources.list &&\
 echo deb-src http://security.debian.org/debian-security buster/updates main >>/etc/apt/sources.list &&\
 echo deb http://deb.debian.org/debian/ buster-updates main >>/etc/apt/sources.list &&\
 echo deb-src http://deb.debian.org/debian/ buster-updates main >>/etc/apt/sources.list

RUN apt-get -y update &&\
    apt-get -y install make wget git gcc g++ lhasa libgmp-dev libmpfr-dev libmpc-dev flex bison gettext texinfo ncurses-dev autoconf rsync git lhasa

RUN git clone https://github.com/bebbo/amiga-gcc &&\
    cd amiga-gcc &&\
    make update &&\
    make all -j



FROM debian:10.4-slim

COPY --from=builder /opt/amiga /opt/amiga

RUN echo deb http://deb.debian.org/debian/ buster main >/etc/apt/sources.list &&\
    apt-get -y update &&\
    apt-get -y install make git
