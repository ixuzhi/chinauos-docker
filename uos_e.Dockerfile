# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope

FROM openeuler/openeuler:22.03-lts as bootstrap

ARG TARGETARCH
ARG SP_VERSION

RUN echo "I'm building uos ${SP_VERSION} for arch ${TARGETARCH}"
RUN rm -rf /target && mkdir -p /target/etc/yum.repos.d && mkdir -p /etc/pki/rpm-gpg
COPY uos_e.repo /target/etc/yum.repos.d/uos.repo
COPY RPM-GPG-KEY-UnionTech /target/etc/pki/rpm-gpg/RPM-GPG-KEY-UnionTech
COPY RPM-GPG-KEY-UnionTech /etc/pki/rpm-gpg/RPM-GPG-KEY-UnionTech

# see https://github.com/BretFisher/multi-platform-docker-build
# make the yum repo file with correct filename; eg: kylin_x86_64.repo
# RUN case ${TARGETARCH} in \
#          "amd64")  ARCHNAME=x86_64  ;; \
#          "arm64")  ARCHNAME=aarch64  ;; \
#     esac && \
#     mv /target/etc/yum.repos.d/uos.repo /target/etc/yum.repos.d/uos_${ARCHNAME}.repo
RUN case ${SP_VERSION} in \
    "1050") case ${TARGETARCH} in \
    "amd64")   ufu_rpm="https://euler-packages.chinauos.com/server-euler/ufu/fuyu/1050/everything/x86_64/Packages/UnionTech-repos-ufu-1-2.uel20.x86_64.rpm" ;; \
    "arm64")   ufu_rpm="https://euler-packages.chinauos.com/server-euler/ufu/fuyu/1050/everything/aarch64/Packages/UnionTech-repos-ufu-1-2.uel20.aarch64.rpm" ;; \
    esac && \
    yum --installroot=/target \
    --releasever=${SP_VERSION} \
    --setopt=tsflags=nodocs \
    install -y ${ufu_rpm} ;;\
    esac
RUN yum --installroot=/target \
    --releasever=${SP_VERSION} \
    --setopt=tsflags=nodocs \
    install -y UnionTech-release yum
#  coreutils rpm yum bash procps tar

FROM scratch as runner
ARG TARGETARCH
ARG SP_VERSION
COPY --from=bootstrap /target /
RUN echo "building uos ${SP_VERSION} for arch ${TARGETARCH}"
RUN echo "ufu" > /etc/yum/vars/StateMode
RUN yum --releasever=${SP_VERSION} \
    --setopt=tsflags=nodocs \
    install -y UnionTech-release yum
# kylin-release coreutils rpm yum bash procps tar
RUN case ${SP_VERSION} in \
    "1050")  case ${TARGETARCH} in \
    "amd64")   ufu_rpm="https://euler-packages.chinauos.com/server-euler/ufu/fuyu/1050/everything/x86_64/Packages/UnionTech-repos-ufu-1-2.uel20.x86_64.rpm" ;; \
    "arm64")   ufu_rpm="https://euler-packages.chinauos.com/server-euler/ufu/fuyu/1050/everything/aarch64/Packages/UnionTech-repos-ufu-1-2.uel20.aarch64.rpm" ;; \
    esac && \
    yum --installroot=/target \
    --releasever=${SP_VERSION} \
    --setopt=tsflags=nodocs \
    install -y ${ufu_rpm} ;;\
    esac

RUN rm -rf /etc/yum.repos.d/uos.repo \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/log/*
RUN cp /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl && \
    build-locale-archive --install-langs="en:zh"

FROM scratch
COPY --from=runner / /
CMD /bin/bash
