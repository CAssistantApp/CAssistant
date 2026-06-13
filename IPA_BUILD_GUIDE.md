# CAssistant IPA 构建指南

> ⚠️ **你没有 Mac 电脑，但别担心！** 本指南提供两种免费方案，让你不花一分钱就能在 iPhone/iPad 上安装 CAssistant。

---

## 方案一：GitHub Actions 云端构建（推荐，最快）🚀

完全免费，不需要任何本地设备，全程在 GitHub 云端完成。

### 详细步骤（10分钟搞定）

#### 第1步：注册 GitHub 账号
1. 打开 https://github.com/signup
2. 输入邮箱、密码、用户名
3. 验证邮箱，完成注册

#### 第2步：创建仓库并上传代码
1. 登录 GitHub，点击右上角 **+** → **New repository**
2. 仓库名输入 `CAssistant`，选 **Public**（公开，免费）
3. 点击 **Create repository**
4. 进入 https://github.com/upload 或者直接在仓库页面点击 **uploading an existing file**
5. 把下面这些文件**拖进去**上传（整个 `CAssistant_iOS` 文件夹的内容）：

| 文件/文件夹 | 必须 |
|------------|:---:|
| `CAssistant/` 文件夹 | ✅ |
| `CAssistant.xcodeproj/` 文件夹 | ✅ |
| `project.yml` | ✅ |
| `ExportOptions.plist` | ✅ |
| `Package.swift` | ✅ |
| `build.sh` | ✅ |
| `setup.sh` | ✅ |
| `.github/workflows/build-ipa.yml` | ✅ |

> 💡 **小技巧**：在电脑上打开 `/workspace/CAssistant_iOS/` 目录，全选所有文件和文件夹，压缩成 zip，然后拖到 GitHub 上传页面。

#### 第3步：触发构建
1. 在仓库页面点击顶部 **Actions** 选项卡
2. 左侧列表找到 **Build IPA**，点击
3. 右侧点击灰色 **Run workflow** 按钮
4. 签名方式选 `unsigned`（无签名，可侧载）
5. 点击绿色 **Run workflow**
6. 等待约 **10分钟**（黄色圆点表示构建中）

#### 第4步：下载 IPA
1. 构建完成后，黄色圆点会变成 ✅ 绿色
2. 点击这个构建条目
3. 在 **Artifacts** 区域点击 **CAssistant-unsigned.ipa** 下载

#### 第5步：安装到 iPhone/iPad
下载 IPA 后，使用以下**免费工具**安装：

| 工具 | 推荐度 | 说明 |
|:----|:------:|:----|
| **AltStore** | ⭐⭐⭐⭐⭐ | 最稳定，电脑+iPhone配合使用 |
| **SideStore** | ⭐⭐⭐⭐ | 无线安装，无需数据线 |
| **Sideloadly** | ⭐⭐⭐⭐ | Windows 也能用 |
| **TrollStore** | ⭐⭐⭐⭐⭐ | 永久安装，无需续签（需设备支持） |
| **爱思助手** | ⭐⭐⭐ | 国产工具，简单易用 |

**以 AltStore 为例：**
1. 电脑下载 AltServer: https://altstore.io
2. iPhone 下载 AltStore（通过 AltServer 安装）
3. 电脑打开 AltServer，用数据线连接 iPhone
4. iPhone 打开 AltStore → My Apps → 右上角 **+**
5. 选择下载的 `CAssistant-unsigned.ipa`
6. 输入你的 Apple ID（免费，仅用于签名）
7. 等待安装完成 ✅

---

## 方案二：PWA 直接使用（零门槛，立即可用）⚡

如果你不想折腾 GitHub，直接用之前做好的 **PWA**，立即可用：

1. **用 iPhone/iPad 的 Safari 打开这个网址**（需要先部署到服务器）
   
   或者用电脑启动：
   ```bash
   cd /workspace/CAssistant_PWA
   python3 deploy.py
   ```
   
2. 手机访问 `http://电脑IP:8080`
3. 点击 Safari 底部 **分享按钮** → **添加到主屏幕**
4. 像原生 App 一样使用

PWA 和原生 IPA 的功能完全一致，只是不能离线使用所有功能。

---

## 方案三：租云 Mac 编译（进阶）

如果 GitHub Actions 免费额度不够用：
- https://myremotemac.com - 月租 Mac Mini M4，$75/月起
- https://macincloud.com - 按小时租 Mac

租到 Mac 后，上传代码，用 Xcode 打开 → 选择设备 → Build → Archive → Export IPA。

---

## 常见问题

### ❓ 没有 Apple ID 能安装吗？
需要免费 Apple ID 来签名。在 iPhone 设置里注册一个就行，不需要付费开发者账号。AltStore 会自动帮你签名。

### ❓ 免费签名能用多久？
免费签名有效期 **7天**。7天后 AltStore 会自动重新签名（只要电脑在同一网络）。

### ❓ 能免除 7 天限制吗？
- 有 **TrollStore**（iOS 14-16.6.1）可以永久安装
- 或者花 **$99/年** 加入 Apple Developer Program，签名有效期 1 年

### ❓ GitHub Actions 收费吗？
**免费**！GitHub 免费用户每月有 2000 分钟 macOS 构建时长，够你构建几百次了。

### ❓ IPA 在 iPad 上能用吗？
**能用！** 项目已配置 `TARGETED_DEVICE_FAMILY: "1,2"`（iPhone + iPad），iPad 上会显示侧边栏布局。

---

## 项目结构

```
CAssistant_iOS/
├── .github/workflows/
│   └── build-ipa.yml        ← GitHub Actions 构建脚本
├── CAssistant/
│   ├── CAssistantApp.swift   ← 主入口
│   ├── Info.plist            ← 配置信息
│   ├── CAssistant.entitlements
│   ├── Models/               ← 数据模型
│   │   └── AppModels.swift
│   ├── Services/             ← 服务层
│   │   └── APKParserService.swift
│   ├── Utils/                ← 工具类
│   │   ├── FileHelpers.swift
│   │   └── GlassEffects.swift
│   ├── Resources/            ← 资源文件
│   │   └── Assets.xcassets/
│   └── Views/                ← 视图层（25+ 个视图）
│       ├── ContentView.swift
│       ├── Analysis/         ← APK分析工具集
│       ├── Viewers/          ← Smali/Dex/Arsc/SO查看器
│       ├── AIChat/           ← AI智能助手
│       ├── Project/          ← 项目管理
│       ├── Tools/            ← 工具（证书/IDE）
│       └── Settings/         ← 设置/关于
├── CAssistant.xcodeproj/     ← Xcode 项目（已生成，无需 xcodegen）
├── project.yml               ← 项目配置参考文件
├── ExportOptions.plist        ← 导出配置
├── build.sh                  ← 本地打包脚本
├── setup.sh                  ← 初始化脚本
└── Package.swift             ← SPM 配置
```

---

**选择方案一（GitHub Actions），现在就去试试？** 有任何问题随时问！