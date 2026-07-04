#!/usr/bin/env bash

# 只要中間有任何指令失敗，就直接停止整個 script。
set -e

# 取得第一個參數作為指令，例如 build / run / clean / rebuild。
COMMAND="${1:-help}"
if [ "$#" -gt 0 ]; then
    shift
fi

# 設定這支 script 預設會使用的 image name、container name 與 hostname。
IMAGE_NAME="aoc2026-env"
CONTAINER_NAME="aoc2026-env-container"
CONTAINER_HOSTNAME="aoc2026-env"

# Dockerfile 預設會建立 developer 使用者，UID/GID 固定成 1001。
BUILD_USERNAME="developer"
USER_UID="1001"
USER_GID="1001"

# 預設不額外指定 docker run --user，直接使用 image 裡設定好的 USER。
CONTAINER_USER=""

# 儲存使用者透過 --mount 傳進來的 bind mount 設定。
MOUNT_PATHS=()

show_help() {
    cat <<EOF
Usage:
  $0 <command> [options]

Commands:
  build                 Build Docker image if it does not exist
  run                   Run or enter Docker container
  clean                 Remove container and image
  rebuild               Clean and rebuild image
  help                  Show this help message

Options:
  --image-name, -i NAME      Set Docker image name
                             Default: ${IMAGE_NAME}

  --cont-name, -c NAME       Set Docker container name
                             Default: ${CONTAINER_NAME}

  --username, -u NAME        Set container username when building/running
                             Default build user: ${BUILD_USERNAME}

  --uid UID                 Set UID used when building the image
                             Default: ${USER_UID}

  --gid GID                 Set GID used when building the image
                             Default: ${USER_GID}

  --hostname, -h NAME        Set container hostname
                             Default: ${CONTAINER_HOSTNAME}

  --mount, -m PATH           Bind mount host path into container
                             PATH can be:
                               host_path
                               host_path:container_path

Examples:
  $0 build
  $0 run
  $0 rebuild
  $0 run --mount "\$PWD:/workspace"
  $0 run --image-name aoc2026-env --cont-name lab1-env
  $0 rebuild --username developer --uid 1001 --gid 1001

EOF
}

require_value() {
    # 檢查某個 option 後面有沒有接值，例如 --image-name 後面必須接 image 名稱。
    if [ -z "${2:-}" ]; then
        echo "Missing value for $1"
        exit 1
    fi
}

parse_args() {
    # 解析 command 後面的 CLI arguments，讓使用者可以客製化 Docker 設定。
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --image-name|--image|-i)
                require_value "$1" "${2:-}"
                IMAGE_NAME="$2"
                shift 2
                ;;
            --cont-name|--container-name|--container|-c)
                require_value "$1" "${2:-}"
                CONTAINER_NAME="$2"
                shift 2
                ;;
            --username|--user|-u)
                require_value "$1" "${2:-}"
                BUILD_USERNAME="$2"
                CONTAINER_USER="$2"
                shift 2
                ;;
            --uid)
                require_value "$1" "${2:-}"
                USER_UID="$2"
                shift 2
                ;;
            --gid)
                require_value "$1" "${2:-}"
                USER_GID="$2"
                shift 2
                ;;
            --hostname|--host|-h)
                require_value "$1" "${2:-}"
                CONTAINER_HOSTNAME="$2"
                shift 2
                ;;
            --mount|-m)
                require_value "$1" "${2:-}"
                MOUNT_PATHS+=("$2")
                shift 2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

build_mount_args() {
    # 把 --mount 參數轉成 docker run 看得懂的 -v 參數。
    MOUNT_ARGS=()

    for mount_path in "${MOUNT_PATHS[@]}"; do
        if [[ "${mount_path}" == *:* ]]; then
            host_path="${mount_path%%:*}"
            container_path="${mount_path#*:}"
        else
            host_path="${mount_path}"
            container_path="/workspace/$(basename "${host_path}")"
        fi

        if [ -z "${host_path}" ] || [ -z "${container_path}" ]; then
            echo "Invalid mount path: ${mount_path}"
            exit 1
        fi

        if [ ! -e "${host_path}" ]; then
            echo "Mount path does not exist: ${host_path}"
            exit 1
        fi

        host_path="$(realpath "${host_path}")"
        MOUNT_ARGS+=("-v" "${host_path}:${container_path}")
        echo "Mounting ${host_path} -> ${container_path}"
    done
}

build_image() {
    # 如果 image 已經存在，就不重新 build。
    if docker image inspect "${IMAGE_NAME}" > /dev/null 2>&1; then
        echo "Image ${IMAGE_NAME} already exists."
        echo "Remove it with: docker image rm ${IMAGE_NAME}"
        return 0
    fi

    # 只 build Dockerfile 裡最後整理好的 release stage。
    docker build \
        --target release \
        --build-arg USERNAME="${BUILD_USERNAME}" \
        --build-arg USER_UID="${USER_UID}" \
        --build-arg USER_GID="${USER_GID}" \
        -t "${IMAGE_NAME}" .
}

container_exists() {
    # docker container inspect 成功代表這個 container 已經存在。
    docker container inspect "${CONTAINER_NAME}" > /dev/null 2>&1
}

container_is_running() {
    # 取得 container 的執行狀態，並檢查是不是 running。
    [ "$(docker container inspect -f '{{.State.Running}}' "${CONTAINER_NAME}")" = "true" ]
}

image_exists() {
    # docker image inspect 成功代表這個 image 已經存在。
    docker image inspect "${IMAGE_NAME}" > /dev/null 2>&1
}

run_container() {
    # 進入 container 前，先確保 image 已經存在。
    build_image
    build_mount_args

    # 如果指定 --username，就把 docker exec / docker run 的 user option 加進來。
    USER_ARGS=()
    if [ -n "${CONTAINER_USER}" ]; then
        USER_ARGS+=("--user" "${CONTAINER_USER}")
    fi

    # 如果 container 已經存在，就重複使用它，而不是重新建立一個。
    if container_exists; then
        if [ "${#MOUNT_PATHS[@]}" -gt 0 ]; then
            echo "Mount options only apply when creating a new container."
            echo "Use './docker.sh clean' first if you need to change mounts."
        fi

        if container_is_running; then
            echo "Container ${CONTAINER_NAME} is already running."
        else
            # 如果 container 是 stopped 狀態，先把它啟動。
            echo "Starting stopped container ${CONTAINER_NAME}."
            docker start "${CONTAINER_NAME}" > /dev/null
        fi

        # 進入正在執行的 container，並開啟互動式 Bash shell。
        docker exec -it "${USER_ARGS[@]}" "${CONTAINER_NAME}" /bin/bash
        return 0
    fi

    # 如果 container 還不存在，就建立新的 container 並進入 Bash。
    docker run -it \
        --name "${CONTAINER_NAME}" \
        --hostname "${CONTAINER_HOSTNAME}" \
        "${USER_ARGS[@]}" \
        "${MOUNT_ARGS[@]}" \
        "${IMAGE_NAME}" \
        /bin/bash
}

clean_environment() {
    # 如果 container 存在，先刪除 container，因為 image 可能正在被它使用。
    if container_exists; then
        echo "Removing container ${CONTAINER_NAME}."
        docker rm -f "${CONTAINER_NAME}" > /dev/null
    fi

    # 如果還有其他 container 使用同一個 image，也一併刪除。
    CONTAINERS="$(docker ps -aq --filter "ancestor=${IMAGE_NAME}")"
    if [ -n "${CONTAINERS}" ]; then
        echo "Removing containers using image ${IMAGE_NAME}."
        docker rm -f ${CONTAINERS} > /dev/null
    fi

    # 如果 image 存在，再刪除 image。使用 -f 是為了清掉舊的同名 image tag。
    if image_exists; then
        echo "Removing image ${IMAGE_NAME}."
        docker image rm -f "${IMAGE_NAME}" > /dev/null
    fi
}

rebuild_image() {
    # 先清掉舊 container 和舊 image，再重新 build。
    clean_environment
    build_image
}

parse_args "$@"

# 根據使用者輸入的第一個參數，決定要執行哪個功能。
case "${COMMAND}" in
    build)
        build_image
        ;;
    run)
        run_container
        ;;
    clean)
        clean_environment
        ;;
    rebuild)
        rebuild_image
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        echo "Unknown command: ${COMMAND}"
        show_help
        exit 1
        ;;
esac
