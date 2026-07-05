# docker-environment

AISLab Summer Training 2026 Lab 1 的 Docker 開發環境。

這份 repository 主要提供：

- 使用 Dockerfile 建立可重現的開發環境
- 使用 `docker.sh` 統一管理 image 和 container
- 使用 `eman` 在 container 內快速測試 C/C++ 與 Verilator 範例

## Requirements

使用前需要先準備：

- Git
- Docker Desktop
- Docker Desktop WSL integration
- GitHub / AISLab GitLab SSH key

如果在 WSL 裡執行 `docker` 時出現：

```text
The command 'docker' could not be found in this WSL 2 distro.
```

請到 Docker Desktop 開啟：

```text
Settings -> Resources -> WSL Integration
```

並啟用目前使用的 Ubuntu WSL distro。

## 檔案說明

- `Dockerfile`：使用 multi-stage build 建立最後的開發環境 image。
- `docker.sh`：管理 Docker image 和 container 的 shell script。
- `eman`：在 container 中執行的環境測試 script。
- `README.md`：環境使用說明。
- `Lab1_report.md`：Lab1 整理後的實作報告。
- `.gitignore`：忽略本地筆記、暫存檔、以及 clone 下來的 tutorial repo。

## Docker Image

預設 image 名稱：

```bash
aoc2026-env
```

環境內容包含：

- Ubuntu 26.04
- non-root 使用者 `developer`
- `vim`、`git`、`curl`、`wget`
- `gcc`、`g++`、`make`
- Python 和 pip
- Verilator `v5.032`
- SystemC `2.3.4`

## Quick Start

先 clone AOC Lab0 Tutorial repo，作為 frontend script 的測試範例：

```bash
git clone ssh://git@gitlab.aislab.ee.ncku.edu.tw:3175/aislab-internal/course/aoc/aoc2026/lab-0-tutorial.git lab-0-tutorial
```

接著 build image 並進入 container：

```bash
./docker.sh clean
./docker.sh build
./docker.sh run --mount "$PWD:/workspace"
```

進入 container 後可以測試：

```bash
eman c-compiler
eman c-compiler-example
eman verilator
eman verilator-example
```

## Docker Script

建立 image：

```bash
./docker.sh build
```

啟動或進入 container：

```bash
./docker.sh run
```

刪除 container 和 image：

```bash
./docker.sh clean
```

清掉舊環境後重新 build：

```bash
./docker.sh rebuild
```

把目前 Lab1 資料夾 mount 到 container 的 `/workspace`：

```bash
./docker.sh run --mount "$PWD:/workspace"
```

常用參數：

```bash
./docker.sh run --hostname lab1
./docker.sh run --mount "$PWD:/workspace"
./docker.sh run --image-name aoc2026-env --cont-name lab1-env
```

## Frontend Test Script

`eman` 是 Environment MANager，用來在 container 裡確認環境能不能正常編譯和執行範例。

支援指令：

```bash
eman help
eman c-compiler
eman c-compiler-example
eman verilator
eman verilator-example
eman change-verilator v5.032
```

`eman` 會優先尋找：

```text
./lab-0-tutorial
/workspace/lab-0-tutorial
```

如果找不到，會嘗試 clone AOC Lab0 Tutorial repo。

## Expected Output

`eman c-compiler` 應該會看到類似：

```text
gcc:  gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0
g++:  g++ (Ubuntu 15.2.0-16ubuntu1) 15.2.0
make: GNU Make 4.4.1
```

`eman c-compiler-example` 應該會編譯並執行：

```text
value: 1
...
value: 24
```

`eman verilator` 應該會看到：

```text
verilator: Verilator 5.032 2025-01-01 rev v5.032
path:      /opt/verilator/current/bin/verilator
```

`eman verilator-example` 應該會編譯並執行 counter example：

```text
count: 9
count: 8
...
count: 0
```

## Verilator 版本切換

預設 Verilator 路徑指向：

```bash
/opt/verilator/current
```

切換到已安裝的 Verilator 版本：

```bash
eman change-verilator v5.032
```

如果指定版本還沒有安裝，`eman` 會嘗試在 container 裡從 source code build 該版本。

## Known Issues

### WSL 中找不到 docker

請確認 Docker Desktop 已啟動，並且有開啟 WSL integration。

### `lab-0-tutorial` 找不到

請確認已經 clone：

```bash
git clone ssh://git@gitlab.aislab.ee.ncku.edu.tw:3175/aislab-internal/course/aoc/aoc2026/lab-0-tutorial.git lab-0-tutorial
```

並且使用：

```bash
./docker.sh run --mount "$PWD:/workspace"
```

讓 container 可以讀到 `/workspace/lab-0-tutorial`。

### Verilator example 找不到 `zlib.h`

AOC Lab0 的 Verilator counter example 使用 `--trace-fst`，需要 zlib header。
因此 release image 中有安裝 `zlib1g-dev`。

## Docker Hub

Docker image 已上傳到 Docker Hub：

```text
https://hub.docker.com/r/smamall/aoc2026-env
```

下載 image：

```bash
docker pull smamall/aoc2026-env:latest
```

如果要重新上傳目前本機的 image：

```bash
docker login
docker tag aoc2026-env:latest smamall/aoc2026-env:latest
docker push smamall/aoc2026-env:latest
```
