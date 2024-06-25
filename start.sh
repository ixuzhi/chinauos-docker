#/bin/bash

BUILDER_NAME="multi-arch-builder"

if docker buildx ls | grep -q "$BUILDER_NAME"; then
  echo "Builder $BUILDER_NAME already exists."
else
  docker buildx create --name "$BUILDER_NAME" --driver docker-container --use
  docker run -it --rm --privileged tonistiigi/binfmt --install all
  echo "Builder $BUILDER_NAME created and activated."
fi




SP_VERSION=1070 && docker buildx build --progress=plain --no-cache . -f uos.Dockerfile --platform=linux/amd64 -t uos-$SP_VERSION-amd64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log
SP_VERSION=1060 && docker buildx build --progress=plain --no-cache . -f uos.Dockerfile --platform=linux/amd64 -t uos-$SP_VERSION-amd64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log
SP_VERSION=1050 && docker buildx build --progress=plain --no-cache . -f uos$SP_VERSION.Dockerfile --platform=linux/amd64 -t uos-$SP_VERSION-amd64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log

SP_VERSION=1050 && docker buildx build --progress=plain --no-cache . -f uos$SP_VERSION.Dockerfile --platform=linux/arm64 -t uos-$SP_VERSION-arm64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-arm64-build.log
docker run --platform linux/arm64 -it --rm uos-1050-arm64 /bin/bash

## uos-a
# uos-1060a

# docker run -it --rm  liwanggui/uos-server:v20-1060a etc/pki/rpm-gpg/RPM-GPG-KEY-uos-release

amd64
SP_VERSION=1070 && docker buildx build --progress=plain --no-cache . -f uos-a.Dockerfile --platform=linux/amd64 -t uos-${SP_VERSION}a-amd64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log
SP_VERSION=1060 && docker buildx build --progress=plain --no-cache . -f uos-a.Dockerfile --platform=linux/amd64 -t uos-${SP_VERSION}a-amd64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log
SP_VERSION=1050 && docker buildx build --progress=plain --no-cache . -f uos-a.Dockerfile --platform=linux/amd64 -t uos-${SP_VERSION}a-amd64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log

docker run -it -it --rm uos-1070a-amd64 /bin/bash
docker run -it -it --rm uos-1060a-amd64 /bin/bash
docker run -it -it --rm uos-1050a-amd64 /bin/bash

arm64
SP_VERSION=1070 && docker buildx build --progress=plain --no-cache . -f uos-a.Dockerfile --platform=linux/arm64 -t uos-${SP_VERSION}a-arm64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log
SP_VERSION=1060 && docker buildx build --progress=plain --no-cache . -f uos-a.Dockerfile --platform=linux/arm64 -t uos-${SP_VERSION}a-arm64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log
SP_VERSION=1050 && docker buildx build --progress=plain --no-cache . -f uos-a.Dockerfile --platform=linux/arm64 -t uos-${SP_VERSION}a-arm64 --build-arg SP_VERSION=$SP_VERSION --load 2>&1 | tee uos-$SP_VERSION-amd64-build.log


docker run -it -it --rm uos-1070a-arm64 /bin/bash
docker run -it -it --rm uos-1060a-arm64 /bin/bash
docker run -it -it --rm uos-1050a-arm64 /bin/bash

docker run -it --rm  liwanggui/uos-server:v20-1060a etc/pki/rpm-gpg/RPM-GPG-KEY-uos-release
