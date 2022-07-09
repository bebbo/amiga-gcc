FROM debian:10.4-slim AS builder

RUN echo deb http://deb.debian.org/debian/ buster main >/etc/apt/sources.list &&\
 echo deb-src http://deb.debian.org/debian/ buster main >>/etc/apt/sources.list &&\
 echo deb http://security.debian.org/debian-security buster/updates main >>/etc/apt/sources.list &&\
 echo deb-src http://security.debian.org/debian-security buster/updates main >>/etc/apt/sources.list &&\
 echo deb http://deb.debian.org/debian/ buster-updates main >>/etc/apt/sources.list &&\
 echo deb-src http://deb.debian.org/debian/ buster-updates main >>/etc/apt/sources.list

RUN apt-get -y update &&\
    apt-get -y install make wget git gcc g++ libgmp-dev libmpfr-dev libmpc-dev flex bison gettext texinfo ncurses-dev autoconf rsync

RUN git clone https://github.com/bebbo/amiga-gcc &&\
    cd amiga-gcc &&\
    make update -j &&\
    make all all-sdk -j8



FROM debian:10.4-slim

COPY --from=builder /opt/amiga /opt/amiga

RUN echo deb http://deb.debian.org/debian/ buster main >/etc/apt/sources.list &&\
    apt-get -y update &&\
    apt-get -y install make git libmpc3 libmpfr6 libgmp10

RUN chmod o+r -R /opt/amiga &&\
    useradd -m -s /bin/bash test &&\
    echo 'export PATH=$PATH:/opt/amiga/bin' >> /home/test/.bashrc

