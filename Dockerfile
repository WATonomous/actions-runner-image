FROM --platform=linux/amd64 ghcr.io/actions/actions-runner:2.312.0@sha256:da57c2566f6f0c3826fb0f41029ec9c0ba23070db789b662166687eeaf0298cc

USER root

# Derived from https://github.com/actions/actions-runner-controller/blob/f7b6ad901d7021046038f69e0d4d1055c41e9914/runner/actions-runner.ubuntu-22.04.dockerfile
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
    && rm -rf /var/lib/apt/lists/*

USER runner