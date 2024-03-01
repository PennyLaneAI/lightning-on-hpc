# syntax=docker/dockerfile:1
   
FROM rockylinux:9.2

ENV WORKDIR=/workdir
WORKDIR $WORKDIR

ADD . .

RUN dnf install g++ python3-pip python3-devel -y git

# Build all libraries and binaries
RUN /bin/bash ./build_script.sh
CMD ["/bin/bash"]
