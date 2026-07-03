# Lab 1 Dockerfile

# stage 命名成 base
FROM ubuntu:26.04 AS base

## set as non-interactive mode
ARG DEBIAN_FRONTEND=noninteractive

## set time zone env var
ARG TZ=Asia/Taipei

## create UID/GID for non-root user
ARG USERNAME=developer
ARG USER_UID=1001
ARG USER_GID=1001

ENV TZ=${TZ}

# 安裝時區資料和 sudo。
## --no-install-recommends 是避免裝一堆非必要推薦套件。

## 把 container 時區設成台灣時間
## ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
## echo ${TZ} > /etc/timezone

## 建立固定 UID/GID 的使用者 developer。
## groupadd ...
## useradd ...

## container 預設不是 root，而是 developer。
## USER ${USERNAME}

RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata sudo && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} --create-home --shell /bin/bash ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    rm -rf /var/lib/apt/lists/*

USER ${USERNAME}
WORKDIR /home/${USERNAME}

CMD ["/bin/bash"]

# 從前面做好的 base stage 繼續建立新的 stage，名字叫 common_pkg_provider
FROM base AS common_pkg_provider

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=developer

# base 最後已經切成 developer，但安裝套件需要 root 權限，所以這裡先切回 root。
USER root

# 安裝 Lab 要求的基本工具，包含 vim、git、curl、wget、gcc/g++/make、python3-pip
    # ln -sf /usr/bin/python3 /usr/local/bin/python：讓輸入 python 時也能找到 Python 3。
    # rm -rf /var/lib/apt/lists/*：清掉 apt cache，讓 image 小一點。
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        vim \
        git \
        curl \
        wget \
        ca-certificates \
        build-essential \
        python3 \
        python3-pip && \
    ln -sf /usr/bin/python3 /usr/local/bin/python && \
    ln -sf /usr/bin/pip3 /usr/local/bin/pip && \
    rm -rf /var/lib/apt/lists/*

# 套件裝完後切回 developer，避免 container 預設用 root
USER ${USERNAME}
WORKDIR /home/${USERNAME}

CMD ["/bin/bash"]