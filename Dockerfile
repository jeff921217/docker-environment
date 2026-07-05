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


# 第三個 stage，verilator_provider，安裝 Verilator。
FROM common_pkg_provider AS verilator_provider

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=developer

# 固定 Verilator 版本
ARG VERILATOR_VERSION=v5.032

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        autoconf \
        bison \
        flex \
        help2man \
        perl \
        libfl-dev \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

# 用 git clone 下載 Verilator 原始碼，並編譯安裝到 /opt/verilator/${VERILATOR_VERSION}，最後建立 /opt/verilator/current 的符號連結。
RUN git clone --depth 1 --branch ${VERILATOR_VERSION} https://github.com/verilator/verilator.git && \
    cd verilator && \
    autoconf && \
    ./configure --prefix=/opt/verilator/${VERILATOR_VERSION} && \
    make -j"$(nproc)" && \
    make install && \
    ln -sfn /opt/verilator/${VERILATOR_VERSION} /opt/verilator/current && \
    rm -rf /tmp/build

ENV VERILATOR_HOME=/opt/verilator/current
ENV PATH="${VERILATOR_HOME}/bin:${PATH}"

USER ${USERNAME}
WORKDIR /home/${USERNAME}


# 下一個 Stage：systemc_provider => Build SystemC from Source
# 從 Accellera 官方 GitHub 下載 2.3.4 並 configure / 安裝
FROM common_pkg_provider AS systemc_provider

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=developer
ARG SYSTEMC_VERSION=2.3.4

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cmake && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

RUN git clone --depth 1 --branch ${SYSTEMC_VERSION} https://github.com/accellera-official/systemc.git && \
    cmake -S systemc -B systemc-build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DCMAKE_INSTALL_PREFIX=/opt/systemc/${SYSTEMC_VERSION} && \
    cmake --build systemc-build --parallel "$(nproc)" && \
    cmake --install systemc-build && \
    if [ ! -d /opt/systemc/${SYSTEMC_VERSION}/lib ]; then \
        if [ -d /opt/systemc/${SYSTEMC_VERSION}/lib-linux64 ]; then \
            ln -sfn lib-linux64 /opt/systemc/${SYSTEMC_VERSION}/lib; \
        elif [ -d /opt/systemc/${SYSTEMC_VERSION}/lib-linux ]; then \
            ln -sfn lib-linux /opt/systemc/${SYSTEMC_VERSION}/lib; \
        fi; \
    fi && \
    ln -sfn /opt/systemc/${SYSTEMC_VERSION} /opt/systemc/current && \
    rm -rf /tmp/build

ENV SYSTEMC_HOME=/opt/systemc/current
ENV SYSTEMC_CXXFLAGS="-I/opt/systemc/current/include"
ENV SYSTEMC_LDFLAGS="-L/opt/systemc/current/lib -Wl,-rpath,/opt/systemc/current/lib -lsystemc"
ENV LD_LIBRARY_PATH="/opt/systemc/current/lib"

USER ${USERNAME}
WORKDIR /home/${USERNAME}


# 最終輸出的 stage
FROM common_pkg_provider AS release

ARG USERNAME=developer

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# 將上面各別建立與 compile 的 stage 複製一份到我們最終的 release stage 中使用
COPY --from=verilator_provider /opt/verilator /opt/verilator
COPY --from=systemc_provider /opt/systemc /opt/systemc
COPY --chmod=0755 eman /usr/local/bin/eman

ENV VERILATOR_HOME=/opt/verilator/current
ENV SYSTEMC_HOME=/opt/systemc/current
ENV SYSTEMC_CXXFLAGS="-I/opt/systemc/current/include"
ENV SYSTEMC_LDFLAGS="-L/opt/systemc/current/lib -Wl,-rpath,/opt/systemc/current/lib -lsystemc"
ENV LD_LIBRARY_PATH="/opt/systemc/current/lib"
ENV PATH="${VERILATOR_HOME}/bin:${PATH}"

RUN chown -R ${USERNAME}:${USERNAME} /opt/verilator /opt/systemc

USER ${USERNAME}
