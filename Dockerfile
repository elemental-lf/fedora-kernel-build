ARG F_BUILD_ENV=37
FROM fedora:${F_BUILD_ENV}

ARG F_BASE_BRANCH=f33
# This is the last commit with a 5.10 kernel.
ARG F_BASE_COMMIT=8cb9b8957f6c41855069d943280362fbf45cdbf1
ARG F_BASE_SRPM=kernel-5.10.23-200.fc33.src.rpm
ARG KERNEL_VERSION
ARG RPMBUILD_ARGS="--with baseonly --without configchecks"

RUN dnf install -y rpm-build joe fedpkg fedora-packager rpmdevtools ncurses-devel pesign grubby \
	&& rpmdev-setuptree
	
WORKDIR /root

# Build the original source RPM as a starting point
RUN rpmdev-setuptree \
  && fedpkg clone -a kernel \
  && cd kernel \
  && fedpkg switch-branch ${F_BASE_BRANCH} \
  && git reset --hard ${F_BASE_COMMIT} \
  && fedpkg srpm \
  && rpm -ivh "${F_BASE_SRPM}"

WORKDIR /root/rpmbuild
	
ADD https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/patch-${KERNEL_VERSION}.xz SOURCES/
ADD SOURCES/* SOURCES/
COPY SPECS/kernel-${KERNEL_VERSION}.spec SPECS/kernel.spec

# RUN echo '%_smp_mflags -j4' >>~/.rpmmacros
RUN dnf builddep -y SPECS/kernel.spec
RUN rpmbuild -ba SPECS/kernel.spec ${RPMBUILD_ARGS}
