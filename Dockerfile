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