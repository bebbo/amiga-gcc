FROM centos:7 as builder
RUN yum install -y gcc gcc-c++ python git perl-Pod-Simple gperf patch autoconf automake make makedepend bison flex ncurses-devel gmp-devel mpfr-devel libmpc-devel gettext-devel texinfo wget
# LhA was missing in some of the steps
RUN yum install -y http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el6/en/x86_64/rpmforge/RPMS/lha-1.14i-19.2.2.el6.rf.x86_64.rpm
RUN git clone https://github.com/bebbo/amiga-gcc && cd amiga-gcc && make update && make all

FROM centos:7
RUN yum install -y make git
COPY --from=builder /opt/amiga /opt/amiga
