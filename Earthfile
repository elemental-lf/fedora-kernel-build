VERSION 0.7

ARG --global --required KERNEL_VERSION
ARG --global F_BASE_SRPM=kernel-5.10.23-200.fc33.src.rpm

srpmbuild:
    FROM fedora:36

    RUN dnf install -y rpm-build joe fedpkg fedora-packager rpmdevtools

    WORKDIR /root

    ARG F_BASE_BRANCH=f33
    ARG F_BASE_COMMIT=8cb9b8957f6c41855069d943280362fbf45cdbf1

    RUN rpmdev-setuptree && \
      fedpkg clone -a kernel && \
      cd kernel && \
      fedpkg switch-branch ${F_BASE_BRANCH} && \
      git reset --hard ${F_BASE_COMMIT} && \
      fedpkg srpm

    SAVE ARTIFACT "/root/kernel/${F_BASE_SRPM}" "${F_BASE_SRPM}"

rpmbuild:
    ARG F_BUILD_ENV=39

    FROM fedora:${F_BUILD_ENV}

    RUN dnf install -y rpm-build joe rpmdevtools ncurses-devel pesign grubby python3-dnf-plugins-core python-rpm-macros && \
      rpmdev-setuptree

    WORKDIR /root/rpmbuild

    COPY "+srpmbuild/${F_BASE_SRPM}" "/root/rpmbuild/SRPMS/${F_BASE_SRPM}"
    RUN rpm -ivh "/root/rpmbuild/SRPMS/${F_BASE_SRPM}" && \
      curl -sSL -o "./SOURCES/patch-${KERNEL_VERSION}.xz" "https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/patch-${KERNEL_VERSION}.xz"
    COPY SOURCES/* SOURCES/
    COPY SPECS/kernel-${KERNEL_VERSION}.spec SPECS/kernel.spec

    ARG RPMBUILD_ARGS='--with baseonly --without configchecks'
    # 4 CPUs, see https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners/about-github-hosted-runners#standard-github-hosted-runners-for-public-repositories
    ARG SMP_MFLAGS='-j4'

    RUN echo "%_smp_mflags ${SMP_MFLAGS}" >>~/.rpmmacros && \
      dnf builddep -y SPECS/kernel.spec && \
      rpmbuild -ba SPECS/kernel.spec ${RPMBUILD_ARGS}

    SAVE ARTIFACT --keep-ts /root/rpmbuild/RPMS/* AS LOCAL ./RPMS/$KERNEL_VERSION/

build:
    BUILD +rpmbuild
