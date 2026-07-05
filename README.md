# docker-environment

AISLab Summer Training 2026 Lab 1 的 Docker 開發環境。

這個 repository 會建立一個包含基本開發工具、C/C++ 編譯工具、Python、
Verilator 和 SystemC 的 Docker image，並提供兩個 helper scripts：

- `docker.sh`：用來 build、run、clean、rebuild Docker 環境。
- `eman`：Environment MANager，用來在 container 裡測試環境是否可以正常運作。

## 檔案說明

- `Dockerfile`：使用 multi-stage build 建立最後的開發環境 image。
- `docker.sh`：管理 Docker image 和 container 的 shell script。
- `eman`：在 container 中執行的環境測試 script。
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

## Build 和 Run

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

## Frontend Test Script

先 clone AOC Lab0 Tutorial repo，作為測試用範例：

```bash
git clone ssh://git@gitlab.aislab.ee.ncku.edu.tw:3175/aislab-internal/course/aoc/aoc2026/lab-0-tutorial.git lab-0-tutorial
```

`lab-0-tutorial/` 已經被 `.gitignore` 忽略，因為它只是本地測試資料，不是這份 Lab1 submission 的內容。

重新建立並進入 container：

```bash
./docker.sh clean
./docker.sh build
./docker.sh run --mount "$PWD:/workspace"
```

進入 container 後執行：

```bash
eman help
eman c-compiler
eman c-compiler-example
eman verilator
eman verilator-example
```

預期結果：

- `eman c-compiler` 會印出 `gcc`、`g++`、`make` 版本。
- `eman c-compiler-example` 會編譯並執行 `lab-0-tutorial/c_cpp/arrays/multidim_array`。
- `eman verilator` 會印出 Verilator 版本和執行檔位置。
- `eman verilator-example` 會編譯並執行 `lab-0-tutorial/verilog/counter`。

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
