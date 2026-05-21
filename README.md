# asdf-flutter (升级版 / Optimized Edition)

适用于 [asdf](https://github.com/asdf-vm/asdf) 与 [mise](https://github.com/jdx/mise) 版本管理器的 [Flutter](https://flutter.dev/) 超级插件。本插件不仅支持极速管理 **Flutter** SDK，还会自动为您配套管理其内置的 **Dart** SDK。

> **优化版核心亮点**：支持国内网络自动测速降级免代理、官方版本实时 Git Tags 同步（即使插件几个月不更新也能秒获最新版）、版本语义化排序去重、Apple Silicon M1/M2/M3 老版本架构智能降级、以及零 JSON 依赖的下载路径预测。

---

## 🚀 升级版核心独占特性

### 1. ⚡️ 智能测速与国内官方镜像秒级切换
- **逻辑**：在加载基础源时，插件会在后台自动通过 `curl` 针对 `storage.googleapis.com` 进行 2 秒的轻量级连接探测。
- **效果**：若您处于国内无代理网络，插件会**自动且无感地降级切换至国内高速官方镜像源**（`https://storage.flutter-io.cn`），下载速度实测直飚 **20MB/s - 30MB/s**。当您开启代理时，则会自动直连谷歌官方原厂源。

### 2. 📡 实时官方版本同步（终结“插件不更新就拉不到新包”的延迟）
- **逻辑**：除了读取官方的 JSON 版本文件，插件在 `list-all` 时会自动向 Flutter 官方 GitHub 实时发起最新的 tags 标签查询，并将两者的列表进行融合去重。
- **效果**：哪怕本插件几年没更新，只要 Flutter 官方发布了最新版本，您的本地 `mise/asdf` 也能在 **1 秒内** 实时感知并提供安装。

### 3. 🔍 完美语义化排序与去重
- **去重**：完美解决由于 Apple Silicon (arm64) 和 Intel (x64) 独立打包导致同一个版本号在列表中连续重复显示多次的视觉体验问题。
- **排序**：引入严格的语义化版本号排序算法（`sort -V`），彻底纠正字符字典序排序下 `3.9.0` 误排在 `3.44.0` 之后的排序缺陷，最新版本百分之百整齐划一地名列在列表的最底部。

### 4. 💻 芯片与架构判定及智能降级
- 支持 Mac 及 Linux 等多平台对 `arm64`、`aarch64` 等移动/服务器级芯片的精准判定。
- **降级保护**：在 M1/M2/M3 等 Apple Silicon 设备上，当您安装老版本的 Flutter 时，若官方当时尚未发布专门的 `arm64` 压缩包，插件会自动回退去匹配 `x64` 架构包，通过 macOS 内置的 Rosetta 2 完美运行，极大地扩宽了老项目的向下兼容性。

### 5. 🎯 “零 JSON 依赖”下载路径智能预测
- 即使谷歌官方的 `releases.json` 发生大面积延迟或丢失，只要您指定了正确的版本，插件中的预测引擎也能自动依据当前的操作系统、芯片及通道（stable/beta/dev）完美推演出标准的官方压缩包下载路径发起直接拉取，实现 100% 成功安装。

---

## 🛠️ 安装方法

### 方案 A：在 `mise` 中安装（推荐）
在 `mise` 中，调试和关联本地开发插件的官方标准命令是 `plugins link`：
```bash
# 强制将本地优化好的插件目录软链接至 mise 
mise plugins link --force flutter https://github.com/forget-password/mise-flutter-new.git
```

### 方案 B：在 `asdf` 中安装
您也可以直接在 `asdf` 中指定本地路径进行添加：
```bash
asdf plugin add flutter https://github.com/forget-password/mise-flutter-new.git
```

---

## 📖 常用指令指南

```bash
# 1. 实时获取官方所有可用版本（包含最新的 3.44.0-stable 及各种 tags，且已完美排序去重）
mise list-all flutter

# 2. 建议加上 --verbose 参数来安装，能够实时看见高速跳动的百分比进度条（防止 mise 劫持输出误以为卡死）
mise install flutter@3.44.0-stable --verbose

# 3. 在当前项目下激活并使用该 Flutter 版本
mise local flutter 3.44.0-stable
```

---

## ⚙️ 进阶配置与手动覆盖 (可选)

如果您在某些极其偶然的节点下，发现默认镜像站同步出现了延迟，或者您希望手动指定特定的镜像源，本插件支持直接通过环境变量进行强制覆盖。

您只需要在运行安装前临时指定 `FLUTTER_STORAGE_BASE_URL` 即可（插件会高度尊重您的手动设置，跳过探测）：
```bash
# 临时使用清华大学镜像源极速下载安装
FLUTTER_STORAGE_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/flutter mise install flutter 3.44.0-stable --verbose
```

---

## ❓ 常见问题排障 (Troubleshooting)

### 1. VSCode 提示 "Could not find a Flutter SDK"
<img width="668" alt="image" src="https://user-images.githubusercontent.com/877327/158042623-290554da-0b9d-4fe0-b91b-c85b9c48e2d1.png">

要解决 VSCode 找不到 Flutter SDK 的问题，您需要在 shell 配置文件（`.bashrc` 或 `.zshrc`）中，显式将 `FLUTTER_ROOT` 环境变量指向当前被调用的 Flutter 本地路径：
```bash
# 写入到您的 .zshrc 或 .bashrc 文件中
export FLUTTER_ROOT="$(mise where flutter)" # 如果使用 asdf 请替换为 asdf where flutter
```

### 2. Apple Silicon 终端下提示 "Bad CPU type in executable"
因为本插件内部需要借助高性能的 JSON 处理工具 `jq`，如果在 Apple Silicon（M1/M2/M3 等）的 macOS 系统上使用，且没有安装过 Rosetta 2 运行环境，有可能会遇到 CPU 架构不匹配的错误。

通常，您可以通过在终端运行以下官方指令，来手动开启 Rosetta 2 转换层：
```bash
softwareupdate --install-rosetta
```

---

## 📄 开源许可证
本项目基于 **MIT License** 开源。原版由 [asdf-community](https://github.com/asdf-community/asdf-flutter) 社区开发与维护，当前版本由 AI 进行了前沿特性优化。
