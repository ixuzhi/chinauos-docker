# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope

FROM openeuler/openeuler:22.03-lts as bootstrap

ARG TARGETARCH
ARG SP_VERSION

RUN echo "I'm building uos ${SP_VERSION} for arch ${TARGETARCH}"
RUN rm -rf /target && mkdir -p /target/etc/yum.repos.d && mkdir -p /etc/pki/rpm-gpg
COPY uos_a.repo /target/etc/yum.repos.d/uos.repo
COPY RPM-GPG-KEY-uos-release /target/etc/pki/rpm-gpg/RPM-GPG-KEY-uos-release
COPY RPM-GPG-KEY-uos-release /etc/pki/rpm-gpg/RPM-GPG-KEY-uos-release

# see https://github.com/BretFisher/multi-platform-docker-build
RUN ls -al /etc/yum.repos.d/
RUN ls -al /target/etc/yum.repos.d
RUN yum --installroot=/target \
    --releasever=${SP_VERSION} \
    --setopt=tsflags=nodocs \
    # --setopt=module_platform_id=platform:uel20 \
    install -y UnionTech-release yum

RUN case ${SP_VERSION} in \
    "1050")  yum --installroot=/target \
                --releasever=${SP_VERSION} \
                --setopt=tsflags=nodocs \
                install -y yum-utils ;; \
    esac

FROM scratch as runner

ARG TARGETARCH
ARG SP_VERSION
COPY --from=bootstrap /target /
RUN echo "building uos ${SP_VERSION} for arch ${TARGETARCH}"
RUN echo "ufu" > /etc/yum/vars/StateMode
RUN case ${SP_VERSION} in \
    "1050") rm -rf /etc/yum.repos.d/UniontechOS.repo && \
        case ${TARGETARCH} in \
            "amd64")   ufu_rpm="https://enterprise-c-packages.chinauos.com/server-enterprise-c/ufu/kongzi/1050/Extras/x86_64/Packages/UnionTech-repos-ufu-1-2.uelc20.x86_64.rpm" ;; \
            "arm64")   ufu_rpm="https://enterprise-c-packages.chinauos.com/server-enterprise-c/ufu/kongzi/1050/Extras/aarch64/Packages/UnionTech-repos-ufu-1-2.uelc20.aarch64.rpm" ;; \
        esac && \
        yum --releasever=${SP_VERSION} \
            --setopt=tsflags=nodocs \
            install -y ${ufu_rpm} --skip-broken ;; \
    esac

RUN yum --releasever=${SP_VERSION} \
    --setopt=tsflags=nodocs \
    install -y UnionTech-release yum
RUN case ${SP_VERSION} in \
        "1050") rm -rf /etc/yum.repos.d/UniontechOS.repo ;;\
    esac

RUN rm -rf /etc/yum.repos.d/uos.repo && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/log/*
RUN cp /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl && \
    build-locale-archive --install-langs="en:zh"

FROM scratch
COPY --from=runner / /
CMD /bin/bash
