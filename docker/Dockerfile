FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
	terminator \
	python3-numpy \
	python3-scipy \
	python3-matplotlib \
	curl \
	gnupg \
	spyder3 \
	nano
RUN sh -c "echo 'deb [arch=amd64] http://robotpkg.openrobots.org/packages/debian/pub $(lsb_release -sc) robotpkg' >> /etc/apt/sources.list.d/robotpkg.list" && \
    sh -c "echo 'deb [arch=amd64] http://robotpkg.openrobots.org/wip/packages/debian/pub $(lsb_release -sc) robotpkg' >> /etc/apt/sources.list.d/robotpkg.list" && \
    curl http://robotpkg.openrobots.org/packages/debian/robotpkg.key |  apt-key add && \
    apt update && \
    apt install -y \
	robotpkg-py38-pinocchio \
	robotpkg-py38-example-robot-data \
	robotpkg-urdfdom \
	robotpkg-py38-qt5-gepetto-viewer-corba \
	robotpkg-py38-quadprog \
	robotpkg-py38-tsid