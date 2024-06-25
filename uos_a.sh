#/bin/bash

BUILDER_NAME="multi-arch-builder"

if docker buildx ls | grep -q "$BUILDER_NAME"; then
  echo "Builder $BUILDER_NAME already exists."
else
  docker buildx create --name "$BUILDER_NAME" --driver docker-container --use
  docker run -it --rm --privileged tonistiigi/binfmt --install all
  echo "Builder $BUILDER_NAME created and activated."
fi

# uos-1060a
# docker run -it --rm  liwanggui/uos-server:v20-1060a etc/pki/rpm-gpg/RPM-GPG-KEY-uos-release

# amd64
OS_TYPE=a && SP_VERSION=1070 && docker buildx build --progress=plain --no-cache . -f uos_a.Dockerfile --platform=linux/amd64 -t uos-${SP_VERSION}a-amd64 --build-arg SP_VERSION=$SP_VERSION --build-arg OS_TYPE=${OS_TYPE} --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log
SP_VERSION=1060 && docker buildx build --progress=plain --no-cache . -f uos_a.Dockerfile --platform=linux/amd64 -t uos-${SP_VERSION}a-amd64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log

# 1050失败
SP_VERSION=1050 && docker buildx build --progress=plain --no-cache . -f uos_a.Dockerfile --platform=linux/amd64 -t uos-${SP_VERSION}a-amd64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log

# arm64
SP_VERSION=1070 && docker buildx build --progress=plain --no-cache . -f uos_a.Dockerfile --platform=linux/arm64 -t uos-${SP_VERSION}a-arm64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-arm64-build.log
SP_VERSION=1060 && docker buildx build --progress=plain --no-cache . -f uos_a.Dockerfile --platform=linux/arm64 -t uos-${SP_VERSION}a-arm64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-arm64-build.log

# 1050失败
SP_VERSION=1050 && docker buildx build --progress=plain --no-cache . -f uos_a.Dockerfile --platform=linux/arm64 -t uos-${SP_VERSION}a-arm64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-arm64-build.log


# docker run -it --rm uos-1070a-amd64 /bin/bash
# docker run -it --rm uos-1060a-amd64 /bin/bash
# docker run -it --rm uos-1050a-amd64 /bin/bash


# docker run -it --rm uos-1070a-arm64 /bin/bash
# docker run -it --rm uos-1060a-arm64 /bin/bash
# docker run -it --rm uos-1050a-arm64 /bin/bash

docker run -it --rm  liwanggui/uos-server:v20-1060a cat etc/pki/rpm-gpg/RPM-GPG-KEY-uos-release


# bash-5.1# ls -al /etc/yum.repos.d/
# total 16
# drwxr-xr-x 2 root root 4096 Jun 25 02:27 .
# drwxr-xr-x 1 root root 4096 Jun 25 02:31 ..
# -rw-r--r-- 1 root root 2623 Apr  7  2023 UnionTechOS-ufu.repo
# -rw-r--r-- 1 root root 2887 Jun 25 02:27 UniontechOS.repo
