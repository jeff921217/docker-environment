# Lab 1 - Git Fundamentals & Docker Environment


## Course Checklist
請打開編輯模式複製清單放進自己的 Hackmd 筆記

- [x] 用自己的 HackMD 帳號創建一則新的筆記，用來記錄問題、開發過程、學習筆記，並用來和團隊成員分享，記得開啟權限 (至少為已登入者可閱讀)
- [x] 在自己的電腦上安裝好 Git
- [x] 在自己的電腦上安裝好 Docker Desktop
- [x] 註冊好 GitHub 帳號
- [x] 設定好 GitHub、GitLab 帳號的 SSH keys
- [ ] 在 [Summer Training GitLab Group Lab1 Submission](https://gitlab.aislab.ee.ncku.edu.tw/aislab-internal/course/summer-training/summer-training-2026/lab1-submission) 底下 create 一個 repo，repository 的名稱統一格式為「`environment-自己的GitLab使用者名稱`」 (例如 `environment-yuting`)，然後將連結貼到 [Submission](#Submission)，之後要將所有需要的 scripts 和 configuration files (including Dockerfile) 推上去，需使用 Git 記錄 docker build 過程中所有版本更新紀錄
- [ ] 在自己的 GitHub 帳號下新增一個 public repo，名稱為「`docker-environment`」，然後將連結貼到 [Submission](#Submission)
- [ ] 閱讀下面列出的 Git 和 Docker 相關資料並實際操作練習
- [ ] 依照指示撰寫 Dockerfile 創建 Docker 環境並使用 Git 做版控
- [ ] 依照指示撰寫 Docker script 和 Frontend script 並使用 Git 做版控
- [ ] 註冊 [Docker Hub](https://hub.docker.com/) 帳號，把 image 上傳並分享


## 學習紀錄
### 6/28
- 檢查有沒有下載git
    `git --version`
    我的是`git version 2.43.0`
- 創建本地資料夾
    ```
    mkdir 2026_summer_train
    cd 2026_summer_train
    mkdir Lab1
    cd Lab1
    ```
### 6/29 
1. 測試能不能用 SSH 連到 GitLab
    ```bash
    ssh -T -p "port" git@"gitlab server 帳號"
    ```
    - `-T`


ssh -T -p 3175 git@gitlab.aislab.ee.ncku.edu.tw
這是在測試你能不能用 SSH 連到課程 GitLab。
ssh -T -p 3175 git@gitlab.aislab.ee.ncku.edu.tw
意思拆開看：
ssh
用 SSH 連線。
-T
不要開互動式 shell，只測連線/認證。GitLab 不會真的讓你登入成一台 Linux 主機操作，它只是用 SSH 做 git 認證。
-p 3175
指定 port 是 3175。一般 SSH 預設是 port 22，但課程 GitLab 用的是 3175。
git@gitlab.aislab.ee.ncku.edu.tw
用 git 這個帳號連到 GitLab server。這裡的 git 不是你的 GitLab 使用者名稱，而是 GitLab SSH 服務共用的系統帳號。
成功時通常會像：
Welcome to GitLab, @你的帳號!
失敗時可能會看到：
Permission denied (publickey)
代表你的 SSH key 還沒被 GitLab 認得。
ssh-keygen -t ed25519 -C "your_email@example.com"
這是在產生一組新的 SSH key。
ssh-keygen -t ed25519 -C "your_email@example.com"
拆開：
ssh-keygen
產生 SSH key 的工具。
-t ed25519
指定 key 的演算法是 ed25519。這是現在常用、短、快、安全性也好的 SSH key 類型。
-C "your_email@example.com"
加一段註解 comment，通常放 email，方便你以後知道這把 key 是誰的或在哪台機器用的。它不是登入密碼，也不是一定要和 GitLab email 完全相同，但通常會用自己的 email。
執行後通常會產生兩個檔案：
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
ls -al ~/.ssh
這是在列出你家目錄下的 .ssh 資料夾內容：
ls -al ~/.ssh
拆開：
ls
列出檔案。
-a
包含隱藏檔。
-l
用詳細格式顯示，例如權限、大小、時間。
~/.ssh
SSH 相關設定和 key 通常都放在這裡。
id_ed25519 是什麼
id_ed25519
這是你的 SSH private key 私鑰。
它非常重要，不能貼給別人、不能上傳、不能傳到聊天室。它就像你的身份憑證本體。
權限通常應該是：
-rw-------
也就是只有你自己能讀寫。
id_ed25519.pub 是什麼
id_ed25519.pub
這是你的 SSH public key 公鑰。
這個可以貼到 GitLab 的 SSH Keys 頁面。GitLab 會保存你的公鑰，之後你 clone/push 時，GitLab 會用它來確認你手上有對應的私鑰。
簡單比喻：
id_ed25519      = 私鑰，只能自己保管
id_ed25519.pub  = 公鑰，可以交給 GitLab
cat ~/.ssh/id_ed25519.pub
這是在顯示公鑰內容：
cat ~/.ssh/id_ed25519.pub
你會看到類似：
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your_email@example.com
這整行就是要貼到 GitLab SSH Keys 的內容。
注意，只能 cat 和複製：
cat ~/.ssh/id_ed25519.pub
不要複製這個：
cat ~/.ssh/id_ed25519
因為沒有 .pub 的那個是私鑰，不能外流。
整個流程就是：
1. 看自己有沒有 SSH key
   ls -al ~/.ssh

2. 沒有的話產生一組
   ssh-keygen -t ed25519 -C "你的 email"

3. 顯示 public key
   cat ~/.ssh/id_ed25519.pub

4. 把 public key 貼到 GitLab

5. 測試 SSH 是否成功
   ssh -T -p 3175 git@gitlab.aislab.ee.ncku.edu.tw

6. 成功後就能 git clone / git push










## Git

:::success
**Study Goal:**
- 了解 Git 的基本運作原理（工作區、暫存區、版本庫）
- 熟悉常見 Git 指令與實務情境
- 能獨立建立 repo 並與 GitHub 同步
- 使用 Git 管理 Docker 環境建置歷程（如 Dockerfile）
:::

作為實驗室的研究生，我們經常需要共同維護大型研究專案、管理實驗用的 Dataset 腳本與 Model 權重設定，或是接手學長姐留下來的程式碼。無論是重現論文結果、開發新的模型架構，或是將成果打包發布，這些任務都涉及多人開發與版本控管。

Git 可以幫助我們追蹤每一次變更：誰、何時、為何做了什麼修改，避免遺失重要設定。多位研究員可在不同分支上同時工作，再整合到主線，避免互相覆蓋檔案。不小心刪錯檔、改錯設定時，Git 可以讓你安全地回到前一個版本。需要進行不同參數的實驗與嘗試時，你可以自由開分支 (Experiments Branch) 測試新方法，不影響主分支的穩定性，確定實驗成功後再合併。

掌握 Git 能讓你做事更有效率、更有條理，也能與教授及實驗室團隊更順利地合作。
:::info
#### Reference

後面我們將參考以下幾個來源的資料，尤其是第一個 **《為你自己學 Git》**，建議可以存下來方便日後查閱參考

- [為你自己學 Git | 高見龍](https://gitbook.tw/)
- [寫給 Git 初學者的入門 4 步驟 - Max行銷誌](https://www.maxlist.xyz/2018/11/02/git_tutorial/)
- [GitHub Docs](https://docs.github.com/en/get-started)
:::
---
### Install Git

- Mac
    1. Install Homebrew
        ```bash
        $ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        ```
    2. 安裝 Git
        ```mac
        $ brew install git
        ```
- Windows
    - 從 [Git 官方頁面](https://git-scm.com/downloads/win) 下載並安裝 Git

---
### Basic Concepts & Commands

以下四篇文章示範了幾個最基本的使用情境，請一個一個點開仔細閱讀，可以的話也請在自己電腦上跟著操作

- [新增、初始 Repository](https://gitbook.tw/chapters/using-git/init-repository)
- [把檔案交給 Git 控管](https://gitbook.tw/chapters/using-git/add-to-git)
- [工作區、暫存區與儲存庫](https://gitbook.tw/chapters/using-git/working-staging-and-repository)
- [檢視紀錄](https://gitbook.tw/chapters/using-git/log)

上述教學有使用到 SourceTree，如果需要，也可以用用看 GitHub 官方的 [GitHub Desktop](https://desktop.github.com/download/)，或是直接在 Terminal 上操作也行

下面這張圖則呈現了常用的 commands 以及 working directory (workspace), staging area (index), local repository, remote repository 的關係

![Git command visualization](https://hackmd.io/_uploads/BJnsQLIrgx.png)

---
### Commit Best Practice

在團隊開發當中，清楚記錄每一次的程式碼變更非常重要，通常團隊會對 commit message 制定一些規範，除了格式之外，內容上的規範不外乎以下幾點：

- 一次 commit 做一件事（small and clean）
- message 須言簡意賅但清晰完整，包含像是變更內容 (做了什麼)、目的 (為什麼)、影響範圍、可能的副作用，或是其他參考資料 (如相關的 issue 或 PR ID 等等)
- 不應該包含和該 commit 無關的檔案
- 避免無意義訊息如：update, fix bug, 123

通常會遵循以下格式：

```
type(scope): title

body (detailed description about this change)

footer (issue numbers, reference links)
```

**常見的 commit type：**

- feat：新增功能
- fix：修 bug
- chore：設定 / 工具相關
- refactor：重構
- docs：說明文件
- test：測試
- ci：自動化部署設定
- perf：效能改進

下列兩個網頁有一些 commit message 規範的例子，建議大家仔細閱讀，未來進行團隊開發時會讓大家自行討論出一套大家都有共識並共同遵守的規範

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [angular/CONTRIBUTING.md](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#-commit-message-format)

---
### Git Configurations

- [使用者設定](https://gitbook.tw/chapters/config/user-config): user name & email
- [其它方便的設定](https://gitbook.tw/chapters/config/convenient-settings): editor & alias

其他還有像是 default branch name、default merge rule、credential 等設定，有興趣的同學可以自行 Google 搜尋或詢問 AI，並整理成文件和大家分享

> [!Tip]
> 實驗室 Mattermost 上有個公開的頻道 [Git Learning](https://gitlab.aislab.ee.ncku.edu.tw:446/ai-system-lab/channels/git-learning) 專門用來交流和學習 Git 相關的知識和用法，感興趣的同學可以點擊連結加入

---
### SSH Key

GitHub 自 2021 年起移除了密碼驗證，HTTPS 存取需改用 Personal Access Token（PAT），操作上較繁瑣；GitLab 雖仍支援 HTTPS，但 clone/push/pull 時同樣都要重新輸入帳號密碼。因此建議不管是 GitHub 還是 GitLab 都設定一下 SSH key，設定完成後即可直接用金鑰驗證，不需每次輸入任何憑證。

1. 建立金鑰：
    ```bash
    ssh-keygen -t ed25519 -C "your_email@example.com"
    ```
2. 啟用 ssh-agent 並加入金鑰：
    ```bash
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    ```
3. 複製金鑰：
    ```bash
    cat ~/.ssh/id_ed25519.pub
    ```
4. 貼上至 GitHub 或 GitLab
    :::spoiler GitLab
    ![GitLab add ssh key](https://hackmd.io/_uploads/Bks9LULrxe.png)
    :::

    :::spoiler GitHub
    ![GitHub add ssh key - 1](https://hackmd.io/_uploads/B1cx7DUBge.png)

    ![GitHub add ssh key - 2](https://hackmd.io/_uploads/Sy-GXD8ree.png)
    :::

完成上述步驟後可以嘗試用 SSH clone 以下 repo，看看 SSH key 是否有設定成功

```
git clone ssh://git@gitlab.aislab.ee.ncku.edu.tw:3175/aislab-internal/general/student-handbook.git
```

需要注意的是，如果同學今天是在 Docker 內存取遠端 repo，一樣需要設定 SSH Key，Docker 內和 Docker 外是不同的系統，要在 Docker 內有以下三種做法：

1. 在 Docker 內使用 `ssh-keygen` 產生另外一對 SSH key
2. 將 host 端的 SSH key 複製到 Docker 內
3. 將 SSH key 所在的目錄設定為 Docker bind mount 的路徑，讓 Docker 內外可以共用

---
### .gitignore

專案當中有些檔案不適合加入 Git 做版本控制，例如 pre-built binary、model weights、access keys/tokens 等等，因此不建議使用 `git add .` 來追蹤程式碼變更，比較好的做法是先用 `git status` 確認後再手動將要加入該次 commit 的檔案用 `git add <filename/directory>` 進行追蹤，但團隊合作中難免手殘，會補不小心把不該加入的東西給加進去，因此可以在 project root 新增一個 `.gitignore` 設定檔，明確指出哪些檔案不希望被 Git 所追蹤

`.gitignore` 的寫法可以參考 [【狀況題】有些檔案我不想放在 Git 裡面](https://gitbook.tw/chapters/using-git/ignore) 或 [官網文件](https://git-scm.com/docs/gitignore)，GitHub 上也有許多為不同類型專案設計的 [gitignore template](https://github.com/github/gitignore)，也可以使用 [gitignore.io](https://www.toptal.com/developers/gitignore) 產生常見的專案範例

---
### Modifying History

如果不幸地已經將某些不該加入的檔案 commit 下去，或是臨時反悔想要修改 commit message，可以參考：

- [【狀況題】修改 Commit 紀錄](https://gitbook.tw/chapters/using-git/amend-commit1)
- [【狀況題】追加檔案到最近一次的 Commit](https://gitbook.tw/chapters/using-git/amend-commit2)
- [【狀況題】剛才的 Commit 後悔了，想要拆掉重做…](https://gitbook.tw/chapters/using-git/reset-commit)
- [【狀況題】修改歷史訊息](https://gitbook.tw/chapters/rewrite-history/change-commit-message)
- [【狀況題】把多個 Commit 合併成一個 Commit](https://gitbook.tw/chapters/rewrite-history/merge-multiple-commits-to-one-commit)
- [【狀況題】把一個 Commit 拆解成多個 Commit](https://gitbook.tw/chapters/rewrite-history/split-one-commit-to-many-commits)

但雖然使用 `git reset`、`git rebase` 可以修改 commit 歷史，讓你的紀錄看起來比較乾淨整潔，但輕易修改歷史可能會造成衝突，尤其是當你把 commit 從 local repository 推上 remote repository 時，這時若修改了 commit 記錄，就會和遠端的 main branch 發生衝突 (就算沒動到檔案、只修改 message 也一樣，因為 `git commit --amend` 因為本質上是把本來的 commit 拆掉後重新做一顆新的)

解決方式有以下幾種：

1. `git push -f`：強制覆寫遠端的分支，須確保該分支是你自己私人擁有，且遠端 repo 上沒有設定 branch protection rule 阻擋 force push
2. `git revert`：再多製作一顆 commit 執行「反向操作」接在原本舊的 commit 後面，不會有衝突，但會讓 commit history 看起來較為雜亂

注意如果你的分支是和別人共用 (如 `main` branch)，盡量不要擅自在上面做會修改到歷史的行為，否則會造成其他團隊成員很大的困擾，若真的非得要修改共用分支的歷史，則必須主動和其他團隊成員確認，並主動協助對方解決衝突。

---
### Multiple Remotes

你可能需要同時把專案推送到 GitHub（開源或備份）和實驗室的 GitLab（內部協作），這時可以這樣設定：

* GitHub Repo：https://github.com/your-username/my-project.git
* AISLab GitLab Repo：https://gitlab.aislab.ee.ncku.edu.tw/your-name/my-project.git

#### 設定 remote
```bash
# GitHub
git remote add github https://github.com/your-username/my-project.git

# GitLab
git remote add gitlab https://gitlab.aislab.ee.ncku.edu.tw/your-name/my-project.git
```

#### 推送到兩邊：
```bash
git push github main
git push gitlab main
```

#### 檢查目前的 remote：
```bash
git remote -v
```

你可能會看到的樣子
```bash=
github https://github.com/your-username/my-project.git (fetch)
github https://github.com/your-username/my-project.git (push)
gitlab https://gitlab.your-lab.org/your-group/my-project.git (fetch)
gitlab https://gitlab.your-lab.org/your-group/my-project.git (push)
```

後面我們會要求大家建立一個 Docker 環境的 repository 作為範例，**同時在 GitLab 和 GitHub 上做開發**，細節請參考下個章節

## Docker

:::success
**Study Goal:**
- Learn how to write a Dockerfile for Docker setting (config file of the Docker environment)
- Learn how to write Docker script to execute containers (run outside container)
- Learn how to write a frontend script to execute programs (run inside container)
:::

Docker 是現今廣泛使用的容器化工具，能快速建立一致的執行環境，並在不同主機間輕鬆移植，具有相較虛擬機更輕量、效能更佳的優勢。

在實驗室的研究中，不同專案往往會依賴不同的套件版本（例如不同版本的 PyTorch 或 CUDA），如果直接在共用的 GPU Server 上安裝，很容易引發「相依性地獄 (Dependency Hell)」。
透過引入 Docker，我們可以為每個專案打包一份專屬的環境映像檔 (Image)，確保大家在共用伺服器上執行時，環境是完全隔離且互不干擾的。更重要的是，這確保了研究結果的「可重現性 (Reproducibility)」——不論是學長姐交接、投稿論文附上程式碼，或者是把模型佈署到不同的硬體上，只要透過 Docker，任何人都能在本地端或伺服器上建立一模一樣的環境並成功執行程式。

此外，這對於同時身兼助教的研究生來說也至關重要。過去修課同學自行設定環境時，常因為作業系統或套件版本差異導致程式無法編譯運行，而統一提供 Server 環境又容易遇到斷電或當機等問題影響公平性。透過 Docker，我們可以為特定 Lab 規範並打包好確定的實驗環境，讓每位修課同學都能在自己的電腦上建立一模一樣的環境，大幅減少除錯與環境設定的困擾。



### Install Docker

- [Docker Docs](https://docs.docker.com/)

#### Install Docker Desktop on Mac

底下的文件提供了 Mac 安裝所需的 dmg 檔案，下載後按照步驟或文件中的指示進行。

- [Mac | Docker Docs](https://docs.docker.com/desktop/setup/install/mac-install/)

:::warning
注意請確認自己的 Mac chip 架構是 Arm 或 Intel，下載對應的 dmg 檔案
:::

#### Install Docker Desktop on Windows

底下的官方文件提供了 Windows 版本的 docker 安裝檔以及安裝步驟，下載後按照文件中的指示進行安裝即可，底下提供一些額外的中文以及圖片說明方便大家進行安裝。

- [Windows | Docker Docs](https://docs.docker.com/desktop/setup/install/windows-install/)

:::info
- **Step 1 - 開啟 Windows 功能**
![upload_396c6e60bb897f005155e13f920362e6](https://hackmd.io/_uploads/SJfuXGSBxx.png)
    1. 在檔案總管的位址欄輸入**控制台\程式集**並前往
    2. 點選**開啟或關閉 Windows 功能**
    3. 勾選**Windows 子系統 Linux 版**及**虛擬機器平台**
    4. 點選**確定**及**立即重新啟動**
- **Step 2 - 安裝 WSL2**
    - 在 Windows 上安裝 WSL，安裝步驟可以詳閱 [Microsoft 官方說明文件](https://learn.microsoft.com/en-us/windows/wsl/install)
- **Step 3 - 安裝 Docker Desktop for Windows**
:::


---

### Dockerfile

Dockerfile 是用來定義 Docker Image 的建構腳本。透過撰寫 Dockerfile，可以逐步描述如何建立所需的環境，包括基礎 image 的選擇、套件安裝、檔案複製、執行指令等。Docker 會根據這些指令自動建構出一個一致且可重複使用的 image，方便將環境部署到不同系統。使用 Dockerfile 可以幫助我們有效管理環境建置流程，確保開發、測試與正式環境一致。

#### What is Image & Container?
Docker Image 是一個唯讀的映像檔，它會封裝檔案系統層、binary、函式庫與設定，作為部署應用程式的藍圖。當我們執行 `docker run` 時，Docker 會在該 image 頂端新增一層 **writable layer**，並啟動一個隔離行程，這個行程連同其 filesystem 被稱作 **Container**  。
Writable layer 實際上會儲存在 host 儲存 driver 裡，因此 container 停止後，這個 layer **仍然會被保留在硬碟中**，只有在執行 `docker rm` 或使用 `--rm` 選項執行才會把對應的 container 從硬碟上清除掉。

Developer 通常會將建構 image 的指令寫成 Dockerfile。Docker Engine 於 `docker build` 階段依序解析每條指令，為每個指令建立一個層並嘗試沿用 cache，以生成一個可重複發佈的 image。

因此標準的 workflow 是：
1. `docker build`
    根據 Dockerfile 產生 image
2. `docker run`
    以該 image 為模板建立並啟動 container
3. `docker stop`
    會釋放記憶體與 CPU 但不刪除 writable layer。如果要連同 writable layer 一起移除，需要使用 `docker rm` 或在 run 時加 `--rm`。
> [!Note]
> 假設要將停止的 container 重新啟動起來，請參考下面的指令。

#### .dockerignore
當我們執行 `docker build <path>` 時，CLI 會把指定路徑中所有檔案和 directory (除了 `.dockerignore` 中指定要排除的檔案) 打包，打包完的資料會被傳到 docker engine 中執行，CLI 會顯示 `Sending build context to Docker daemon …`。

如果傳輸的資料 size 過大會導致網路傳輸和 I/O 會越耗時，所以我們通常會用 `.dockerignore` 簡化要打包的內容，常見做法是排除 `node_modules`、size 過大的 binary 檔以及我們的工作目錄等等...。

#### Commonly-Used Command

| 使用情境                                            | Command                                       | Reference Link                                                       |
| --------------------------------------------------- | --------------------------------------------- | -------------------------------------------------------------------- |
| Build an image from a Dockerfile                    | `docker build -t <image:tag> -f <Dockerfile>` | [Link](https://docs.docker.com/reference/cli/docker/buildx/build)    |
| Download (pull) an image from Docker Hub / Registry | `docker image pull <repo>/<image>:<tag>`      | [Link](https://docs.docker.com/reference/cli/docker/image/pull)      |
| Run a container with a pre-built image              | `docker container run [opts] <image>`         | [Link](https://docs.docker.com/reference/cli/docker/container/run/)  |
|  Stop a running container                                                   |                `docker container stop [opts] <container>`                               |                                                       [Link](https://docs.docker.com/reference/cli/docker/container/stop/)               |
| Remove (delete) an image  |`docker image rm <image>` |  [Link](https://docs.docker.com/reference/cli/docker/image/rm/)      |
| Remove (delete) a container| `docker container rm <container>`      | [Link](https://docs.docker.com/reference/cli/docker/container/rm/) |
| Open a new shell in a running container| `docker exec -it <container> /bin/bash`   | [Link](https://docs.docker.com/reference/cli/docker/container/exec/)     |
| List all containers (running + stopped)| `docker ps -a`   | [Link](https://docs.docker.com/reference/cli/docker/container/ls/)     |
| List local images|  `docker image ls`  |  [Link](https://docs.docker.com/reference/cli/docker/image/ls/)      |

#### Commonly-Used Keyboard Shortcuts
| Shortcuts | Purpose |
| -------- | -------- |
| `Ctrl + C`     | Stops the main process and therefore ends the container   |
| `Ctrl + D`     | Sends an EOF to the shell; if the shell is PID 1 in the container this exits the shell and the container terminates.    |
> [!Note]
> `Ctrl + D` 是**給目前的 shell 送 EOF**，會不會把容器關掉要看那個 shell 是否是 PID 1（主行程）。如果它只是一個 `docker exec` 或第二個 terminal 的行程，則結束的就只會是這個行程而已。
> 但如果 container 當初就是**以該bash 作為主行程**啟動，這樣`Ctrl + D` 退出後主行程就會結束，導致整個 container 變成 Exited 狀態。
因此如果要**保證 container 可以繼續運行**的通用快捷鍵是 `Ctrl + P → Ctrl + Q`（Detach），但因為我們通常都是讓 container 維持在運行的狀態，並使用 `docker exec` 再次進入 container 中，所以較常直接使用 `Ctrl + D` 來跳出 container。

---

#### Requirement 1 - Minimal `Ubuntu 26.04` Base Image (Stage `base`)
先建立一個只包含 OS `Ubuntu 26.04` 的 base image，確認這個 base image 可以被 build up 起來，並能夠成功進入 container 內。

#### Requirement 2 - Add Environment Settings in Stage `base`
因為 Ubuntu container 預設的時區是 UTC，由於許多測試、排程與 log 都會仰賴當地時間，維持時區在 UTC 會增加 debug 與 data align 的難度，所以我們必須調整時區設定。
此外，我們還要確保所有安裝流程皆能在**非互動**的模式下執行，以方便未來在 CI/CD pipeline 中可以全程自動化不被中斷。

最後是我們要統一為 container 建立固定的 **UID/GID**，並改用 **Non-root** 帳號運行，因為在 container 中使用 root 權限可能會有安全疑慮，這樣做可以降低安全風險並確保 mount 到不同主機或其他容器時仍然可以保持檔案權限一致，避免存取失敗或權限過大。

#### Requirement 3 - Install Package
設定完 base image 的所有設定後要開始安裝環境中所需要用到的套件，基於 Docker 的 multi-stage builds 的設計，我們通常會把不同的 package 進行區分，方便 cache reuse 以及未來套件的擴增，在這次實作中已經把要加入的套件切分成了下面 3 個 stage，分開進行安裝設定與 compile，有興趣了解 Docker 機制可以參考官方文件 [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)。
- **Stage `common_pkg_provider` : Core CLI Tools**
安裝以下的內容並在 container 內輸入對應的指令確認是否有正確被安裝。
    - 安裝 `vim`, `git` 等日常開發套件
        ```bash=
        $ vim --version
        $ git --version
        ```
    - 安裝 `curl`, `wget`, `ca-certificates` 等網路傳輸套件
        ```bash=
        $ curl --version
        $ wget --version
        ```
    - 安裝 `build-essential` (內含 `gcc`、`g++`、`make` 等編譯工具)
        ```bash=
        $ gcc --version
        $ g++ --version
        $ make --version
        ```
- **Stage `common_pkg_provider` : Python and pip**
    - `Ubuntu 26.04` 通常預設會安裝 `Python 3.12`，但並不會安裝 `python3-pip`；為了避免套件沒有安裝的狀況發生，所以一樣統一在 dockerfile 中設定安裝流程
    - 安裝完後可以在 container 內輸入對應的指令確認是否有正確被安裝。
        ```bash=
        $ python3 --version
        # 輸出應該要顯示如 `Python 3.12.x`，表示 Python 已安裝成功
        $ pip --version
        # 輸出應該要顯示如 `pip 24.x`，表示 pip 管理器已經可用
        ```
    > [!Note]
    > 可以加入 `ln -s /usr/bin/python3 /usr/bin/python` 指令，避免部分 shell script 只找得到 python

    > [!Warning]
    > Ubuntu 24.04 採用 **PEP 668（externally managed environment）** 機制，直接執行 `pip install <package>` 會被系統拒絕並報錯：
    > ```
    > error: externally-managed-environment
    > ```
    > 在 Dockerfile 中安裝 Python 套件時，需要在 `pip install` 指令後加上 `--break-system-packages` 旗標，或改用 `python3 -m venv` 建立虛擬環境。例如：
    > ```dockerfile
    > RUN pip install --break-system-packages <package>
    > ```
- **Stage `verilator_provider` : Build Verilator from Source**
    - 從官方 GitHub Repo 抓取 source code 進行安裝
    - 安裝完後可以在 container 內輸入對應的指令確認是否有正確被安裝
        ```bash=
        $ verilator --version
        # 輸出應該要顯示如 `Verilator 5.x, rev …` 等版本資訊，這樣便確保可以順利呼叫 Verilator 命令
        ```
- **Stage `systemc_provider` : Build SystemC from Source**
    - 從 Accellera 官網/GitHub 下載最新版本 (2.3.4 ver.) 並進行 configure 與安裝
    - 安裝完後可以在 container 內用建立一個使用 SystemC libs 的最小程式進行 compile，測試是否有正確安裝並且路徑位置可以正確被 compiler 與 linker access：
        ```bash=
        cat << 'EOF' > test.cpp
        #include <systemc>
        int sc_main(int argc, char* argv[]) { return 0; }
        EOF

        g++ $SYSTEMC_CXXFLAGS test.cpp \
            $SYSTEMC_LDFLAGS -o test && ./test
        # 程式應該要 print 出 SystemC 的 version, e.g., 
        # SystemC 2.3.4-Accellera
        # Copyright (c) 1996-2022 by all Contributors,
        # ALL RIGHTS RESERVED
        #
        # 即可確認 include、compile flag 與 link 設定均無誤
        ```
        > [!Note]
        > 上面範例中的 `$SYSTEMC_CXXFLAGS` 與 `$SYSTEMC_LDFLAGS` 並非 SystemC 官方提供的工具指令，只是用來表示 user 自行指定 compile 與 link 的參數設定。
        > 如果沒有在 Docker 環境中設定類似的參數，也可以在 terminal 中手動指定對應的 flag 與 link path:
        > ```bash=
        > $ g++ -I${SYSTEMC_HOME}/include test.cpp \
        >       -L${SYSTEMC_HOME}/${lib} -lsystemc -o test
        > $ ./test 
        > ```
        > 如果是使用 CMake 進行安裝，取決於 CPU 架構不同 `${lib}` 有可能是 `lib-linux64`, `lib-linux` 或 `lib`。
- **Copy built stages to Stage `release`**
    - 在上面的 stage 都設定好後，接著可以使用 `COPY --from=<stage-name>` 語法將上面各別建立與 compile 的 stage 複製一份到我們最終的 `release` stage 中使用，這就是所謂的 **Docker Multi-stage Builds**。這樣做的好處是每個 stage 可以分開進行 compile，後續如果要進行套件更動也會是以 stage 為單位進行 compile，而不用在更改某些部分時又要將整份 dockerfile 從頭到尾 compile 一次。
    - `release` stage 是一份 Dockerfile 中最終要產出的階段，基本上任何和執行環境參數有關的設定，或是最終需要保留的套件與執行檔，都會在這個 stage 彙整。
    > [!Note]
    > 在一份 Dockerfile 中並沒有限定可以有多少個 stage，所以在一份文件中如果想要有多個中介的 stage 也不會有問題。
    > 但 Docker 在一份 Dockerfile 中只會有一個建構目標，並基於這個目標產生最終的 image 與 container。如果 `docker build` 時在 CLI 沒有特別指定 `--target <stage-name>` 的話，這個建構目標預設會是文件上的最後一個 stage，所以我們通常會把最終的 `release` stage 放在最下面。

    > [!Note]
    > 把 `common_pkg_provider` 這個 stage copy 到 `release` stage 的時候應該會覺得哪裡怪怪的，可以仔細思考一下這個做法可能存在了什麼問題？想一想有沒有比較好的做法可以讓你在 `release` stage 可以使用到透過 `apt`, `pip` 安裝的內容，但同時又不需要搬一大堆存在於系統檔案 `/usr` 內的東西？

> [!Tip]
> 在 MacBook 上特別有可能會因為新舊 CPU 架構的不同 (`x86_64` 或 `arm64`)，導致一些套件的安裝方式或是 package 會不一樣，所以在 dockerfile 中**務必**要特別檢查架構的不同，可以使用 predefined args `TARGETARCH` 來協助處理。
#### Basic Instructions
| 指令                    | 功能摘要                                                                                   |
| --------------------- | -------------------------------------------------------------------------------------- |
| `FROM <image>`        | 指定一個 image 來建立環境，一個 dockerfile 中可以使用多個 image 來建立多個 stage                     |
| `RUN <command>`       | 在目標 stage (image) 上建立新的 layer 來執行指定的 command                                           |
| `WORKDIR <directory>` | 設定後續指令 `RUN`、`CMD`、`ENTRYPOINT`、`COPY` 和 `ADD` 執行的 working directory                   |
| `COPY <src> <dest>`   | 從 `<src>` 將新檔案或目錄複製到 `<dest>` 路徑中 cotainer 的 filesystem                                |
| `CMD <command>`       | 用來定義以這個 image 啟動的 container 預設要執行的程式。由於一個 Dockerfile 只能出現一條 CMD 指令，因此若寫了多條，只有最後一條會被使用。 |

其他更多指令的說明或是關於指令用法的補充請參考 reference。

> [!Tip]
> **Package 放哪裡最合適？**
> 1. **跟隨套件管理器**：
    > - 用 apt → 讓它決定 `/usr/bin` | `/usr/lib`
	> - 用 pip → 默認安裝至 `/usr/local`（系統層級）；使用 `--user` 旗標時改為安裝至 `~/.local/`（使用者家目錄）
> 2. **自己編譯、想保留** → `/usr/local/bin` | `/usr/local/lib`
> 3. **完整第三方套件、獨立更新** → `/opt/<app>`
> 4. **專案可執行檔** → `/<app>/bin`（或 `/usr/local/bin` 但專案名可能難以區隔）
> 5. **專案其他資源** → 依需求在 `/<app>` 下再分成 `config/`, `static/`, `logs/` 等

:::info
#### Reference
- [Dockerfile Basic Overview](https://docs.docker.com/build/concepts/dockerfile/)
- [Dockerfile Instructions Reference](https://docs.docker.com/reference/dockerfile/)
- [Dockerfile Best Practices](https://docs.docker.com/build/building/best-practices/)
:::

---
### Docker Script

每次要修改環境需要重新 build Docker image，或是離開 container 後需要重啟，但所用的 command 會根據當前 container 的狀態而有不同，需要先確認，然後才能決定要怎麼下指令。這對剛進實驗室或不熟悉環境的人來說相對繁瑣，因此身為專案的維護者，我們應該要有能力撰寫一個 shell script 來執行 docker container，簡化並統一實驗環境的運行流程，並搭配 CLI arguments 來做設定。這樣每次要運行 container 進行實驗時，都只需要執行這個 script 並傳入對應參數即可。

下面將請同學撰寫一份 `docker.sh`，滿足以下需求：

1. 建立 Docker image
2. 運行 Docker container
3. 提供命令列參數供使用者對 Docker 環境客製化

**Example:**

```shell
$ ./docker.sh run \    # running the containers
    --username $USER \
    --mount path1 \
    --mount path2 \
    --image-name {IMAGE_NAME} \
    --cont-name {CONTAINER_NAME}
    
$ ./docker.sh clean    # delete all the containers and the image
$ ./docker.sh rebuild    # delete and rebuild
```

#### 1. Build Image

寫一個 shell script 建立一個名為 `aoc2026-env` 的 Docker image，這個 script 由一或多個 shell functions 組成，用來 build Docker image，同時需要確認 image 是否存在，若 image 已經存在則印出提示訊息告訴使用者該 image 已存在，並提示刪除 image 的指令；若 image 不存在，則使用 Dockerfile 將 image build 起來

#### 2. Run Container

擴充以上的 shell script，撰寫新的 function 用來將 container 跑起來，這個 function 需要先確認 container 當前的狀態為下列何者

- running：進入 container
- stoped：啟動 container 後進入
- not existed：建立 container 後進入

確認後做相應的處理，最終是要 run 起一個 Docker container 並登入進裡面的 Bash shell

#### 3. Add Customized Command Line Arguments

為了讓 Docker 環境更有彈性且容易使用，請修改 shell script 提供一些 CLI 參數供使用者可以指定，以下舉例：

- Container name
- Image name
- Username
- Hostname
- Directory path(s) to be binded into the container
- or other parameters you want

> [!Tip]
> 若對 shell script 不熟悉，可以參考 [Bash Scripting Cheatsheet](https://devhints.io/bash)，尤其是 variable、conditionals 和 function 的部分。
若希望使用 Python 撰寫 `docker.sh` 的同學可以參考 Python 的 `argparse` 和 `subprocess` 這兩個標準函式庫。

---
### Frontend Script

為了確認環境是否有正確安裝，所以我們要在 container 中測試是否可以正確運行程式。請撰寫一個用於在 container 中測試程式執行的 script，驗證我們的研究環境是否建置成功。以下文件中的原始碼都可以從 [AOC - Lab 0 Tutorial](https://gitlab.aislab.ee.ncku.edu.tw/aislab-internal/course/aoc/aoc2026/lab-0-tutorial) repo 中找到，請直接 clone 這份 repo 進行測試。

**Frontend script example:** (可以用 shell script 也可以用 Python script)

```shell
eman help
eman verilator
eman c-compiler
```

> [!Note]
> `eman` 是 Environment MANager (環境管理員) 的縮寫

#### 1. Build C/C++ Example

使用以下 C Code 和 Makefile 的範例編譯出一支測試的小程式，如果 Docker 環境中有正常安裝 gcc 和 make，下列範例將能夠正常運行

:::spoiler C Code Example
```cpp
#include <stdio.h>

int main() {
    int arr[2][3][4] = {
        {
            {1, 2, 3, 4}, 
            {5, 6, 7, 8}, 
            {9, 10, 11, 12}
        },
        {
            {13, 14, 15, 16}, 
            {17, 18, 19, 20}, 
            {21, 22, 23, 24}
        }
    };
    
    int *ptr = (int*)arr;
    
    printf("-----  print out  ----- \n");
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 3; j++) {
            for (int k = 0; k < 4; k++) {
                int idx = i*12 + j*4 + k;
                printf("addr: %p , value: %d\n", &arr[idx], *(ptr + idx));
            }
        }
    }
}
```
:::

:::spoiler Makefile
```makefile
BIN := main.exe

CC := gcc

CFLAGS := -Wall -Wextra -O2
INCLUDE_DIR := .

SRC := main.c
OBJ := $(SRC:.c=.o)

.PHONY: all run clean

all: $(BIN) run

$(BIN): $(OBJ)
	$(CC) $^ -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $< -I$(INCLUDE_DIR) -o $@

run: $(BIN)
	./$(BIN)

clean:
	rm -rf $(BIN) $(OBJ)
```
:::

#### 2. Build Verilator Example

使用以下範例程式碼，編譯並執行，如果環境中有正常安裝 Verilator 且有正確設定環境變數的話，以下的範例將可以正常運行

:::spoiler Verilog Example
```verilog
module Counter(
    input clk,
    input rst,
    input [8:0] max,
    output reg [8:0] out
);
    reg [8:0] cnt;

    always @(posedge clk, posedge rst) begin
        if (rst) cnt <= max;
        else if (cnt == 0) cnt <= max;
        else cnt <= cnt - 1;
    end

    always @(*) out = cnt;

endmodule
```
:::

:::spoiler Testbench Example
```
#include <iostream>
#include "VCounter.h"
#include "verilated_vcd_c.h"


int main() {
    Verilated::traceEverOn(true);
    VerilatedVcdC* fp = new VerilatedVcdC();

    auto dut = new VCounter;
    dut->trace(fp, 0);
    fp->open("wave.vcd");

    int clk = 0;
    const int maxclk = 10;

    dut->rst = 1;
    dut->max = 9;
    dut->clk = 1; dut->eval(); fp->dump(clk++);

    dut->rst = 0;
    while (clk < maxclk << 1) {
        // falling edge
        dut->clk = 0; dut->eval(); fp->dump(clk++);

        // rising edge
        dut->clk = 1; dut->eval(); fp->dump(clk++);
        std::cout << "count: " << dut->out << std::endl;
    }

    fp->close();
    dut->final();
    delete dut;
    return 0;
}
```
:::

:::spoiler Makefile
```makefile
TB_SRC = testbench.cc
BIN = obj_dir/VCounter

VFLAGS = -Wall --cc --exe --build --trace
VC = verilator

.PHONY: all clean format run

all: $(BIN)

run: $(BIN)
	./$<

obj_dir/V%: %.v $(TB_SRC)
	$(VC) $(VFLAGS) $^

format:
	clang-format -i tb/*.cpp

clean:
	$(RM) -rv obj_dir *.vcd
```
:::

#### 3. Help Message

根據上兩個確認的功能撰寫 frontend script 的 help message，再加上以下確認版本

- check the version of C compiler
- compile and run the C code example(s)
- check the version of Verilator
- compile and run Verilator example(s)
- switch different version of Verilator

shell script 模板如下：

```shell
help() {
    cat <<EOF
    
    eman check-verilator            : print the version of the first found Verilator (if there are multiple version of Verilator installed)
    eman verilator-example          : compile and run the Verilator example(s)
    eman change-verilator <VERSION> : change default Verilator to different version. If not installed, install it.

    eman c-compiler-version         : print the version of default C compiler and the version of GNU Make
    eman c-compiler-example         : compile and run the C/C++ example(s)

    EOF
}
```

同學也可以依照自己想法加上其他的功能，每個功能需要有獨立的 commit


## Submission
雖然這週的課程是各自完成，但鼓勵大家互相討論交流，因此請大家將 repo link 貼在下方的表格

此外，在未來進行團隊開發和助教工作時，撰寫文件並讓別人看懂的能力很重要，在整個 summer training 過程中會除了該週的主題之外，也會讓大家練習撰寫技術文件，請自行建立 HackMD 筆記記錄你自己開發和學習的過程，以及希望和其他同學或學長姐討論的問題，然後貼在下面和大家分享

> [!Tip]
> 不用等到全部寫完才貼，建立空白筆記和 repo 後即可貼上來，方便掌握大家的進度並給予必要的協助

 Meeting Recording: **[here](https://youtu.be/_o7PrMxUAx4?t=1290)**

| Name   | GitHub link        | GitLab link        | HackMD link          | 已檢討 |
| ------ | ------------------ | ------------------ | -------------------- | ------ |
| 簡誌加 | [Lab1][ccc-github] | [Lab1][ccc-gitlab] | [HackMD][ccc-hackmd] | V      |
| 王翊勝 | [Lab1] | [Lab1] |  [HackMD] |        |
| 楊詠樂       |                   |                    |          [HackMD][yly-hackmd]             |        |
| 徐嫚君 | | | [HackMD][hsu-hackmd]||


[ccc-hackmd]: https://hackmd.io/@Jackiempty/ta-training
[ccc-gitlab]: https://gitlab.aislab.ee.ncku.edu.tw/aislab-internal/course/summer-training/ta-training-2025/lab1-submission/environment-jackiempty
[ccc-github]: https://github.com/Jackiempty/docker-environment.git
    
    
[yly-hackmd]: https://hackmd.io/@PkG2SxJORSqDyLpaR04efA/r1DC1Ky7Mx

[hsu-hackmd]: https://hackmd.io/@VESUWqGnQYug7aotZDk--w/HyPX4hyQzx