# Parts of this file are based on the legacy GitHub Actions Runner Dockerfile (a.k.a. summerwind/actions-runner)
# - https://github.com/actions/actions-runner-controller/blob/f7b6ad901d7021046038f69e0d4d1055c41e9914/runner/

ARG TARGETPLATFORM=linux/amd64
# This is the official actions-runner image packaged with gha-runner-scale-set
ARG BASE_IMAGE=ghcr.io/actions/actions-runner:2.312.0@sha256:da57c2566f6f0c3826fb0f41029ec9c0ba23070db789b662166687eeaf0298cc

FROM --platform=$TARGETPLATFORM $BASE_IMAGE

ARG DOCKER_COMPOSE_VERSION=v2.23.0
ARG TARGETPLATFORM

USER root

RUN apt-get update -y \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:git-core/ppa \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    jq \
    sudo \
    unzip \
    zip \
    wget \
    jq \
    python3-pip \
    rsync \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Download latest git-lfs version
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y --no-install-recommends git-lfs

RUN export ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
    && echo "ARCH: $ARCH" \
    && if [ "$ARCH" = "arm64" ]; then export ARCH=aarch64 ; fi \
    && if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "i386" ]; then export ARCH=x86_64 ; fi \
    && mkdir -p /usr/libexec/docker/cli-plugins \
    && curl -fLo /usr/libexec/docker/cli-plugins/docker-compose https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH} \
    && chmod +x /usr/libexec/docker/cli-plugins/docker-compose \
    && ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose \
    && which docker-compose \
    && docker compose version

# Python packages get installed to ~/.local by default
ENV PATH="${PATH}:/home/runner/.local/bin"

USER runner

# Used for uploading/downloading artifacts
RUN python3 -m pip install s3cmd
