# Compositor

Adobe Photoshop 价格太高，而 GIMP 等工具又不够熟悉，难以让我保持流畅的工作状态。因此我开发了 Compositor。

我的目标是打造一款功能齐全、完全免费且开源的图像编辑器。我过去常用 Photoshop 进行合成与后期处理，因此 Compositor 围绕这套工作流程构建，并提供制作像素级精准成品所需的工具。

由于它是开源软件，你可以下载 Xcode 项目，按自己的工作流程添加、移除或修改功能。

## 安装

### 下载
从 [robbietilton.com/compositor](https://robbietilton.com/compositor) 获取 Compositor，或直接从 [GitHub Releases](https://github.com/robbietilton/Compositor/releases/latest) 下载最新版本。

### Homebrew

```sh
brew install --cask robbietilton-compositor
```

## 功能

### 图层
- 支持图层和文件夹，可调节不透明度，并提供 Photoshop 全套混合模式及相同排列顺序；文件夹的不透明度会影响其中所有内容
- 图层蒙版：可在画布任意位置绘制、填充、反相、模糊和羽化，即使超出图层自身像素范围也可以；还可链接或取消链接蒙版，以便单独变换蒙版
- 剪贴蒙版和文件夹蒙版
- 调整图层：色相/饱和度、色阶、曲线、曝光、渐变映射、颗粒、黑白、色彩平衡、反相；滤镜图层：高斯模糊、动态模糊、渐进模糊、锐化、降噪、噪点、暗角、泛光/光晕、RGB 分离、镜头效果和色调对比
- 图层效果：描边、投影、颜色叠加、内阴影、外发光和内发光；由 GPU 渲染，随时可以编辑
- 向下合并、合并图层和合并组（⌘E）
- 可复制、重命名、拖放调整顺序和嵌套；按住 Option 并拖动即可复制；图层面板提供右键菜单
- 可复制和粘贴整个图层或文件夹（未选中内容时按 ⌘C/⌘V），支持在项目内或项目间操作，也可以在项目间拖动

### 变换
- 无损移动、缩放、旋转和翻转；无论缩小多少，图像都会保留完整分辨率
- 自由扭曲（按住 ⌘ 拖动控制点），按住 Shift 可锁定轴向
- 可同时变换多个图层或整个文件夹
- 可对齐画布边缘、图层边缘和中心，并使用参考线吸附
- 距离（视图 › 显示 › 距离）：移动图层时显示画布边缘和相邻图层之间的像素间距；按住 ⌘ 时显示指针下方图层之间的距离
- 可精确设置位置、尺寸、缩放比例和角度，并用方向键逐步调整
- 可水平或垂直翻转图层和画布
- 可通过移动工具栏或“图层”菜单，将图层相互对齐，或与选区、画布对齐和分布

### 选区
- 矩形和椭圆选框、自由和多边形套索，以及魔棒工具；魔棒可按颜色选取，对象模式会描出点击对象的轮廓（按 Tab 切换）
- 主体选择，以及对任意选区进行扩展、收缩和羽化
- 可向选区添加或减去内容、移动选区边缘，或移动和复制选区内的像素
- 可将图层像素或蒙版载入为选区
- 内容识别填充，也可用于向图像边缘以外扩展画面

### 绘画与修饰
- 画笔可调节大小、硬度、不透明度和平滑度，并支持绘画或擦除模式（B 和 E）；按住 Shift 可绘制直线
- 绘图板支持通过笔压控制画笔大小和不透明度
- 污点修复画笔（内容识别）
- 仿制图章，可选择对齐或非对齐，并从单个图层或所有图层取样
- 可在像素或蒙版上使用模糊工具
- 渐变工具和形状工具（矩形、圆角矩形、椭圆和直线）；形状会保持可编辑，不会栅格化
- 文字工具（T）：可直接编辑多行文字，并放入可拖动、可调整大小的段落框；可在工具栏中设置字体、字号、颜色、对齐和间距；也可变换文字，或将文字用作剪贴蒙版
- 吸管工具和完整的颜色选择器

### 调整与滤镜
- Camera Raw 滤镜：在画布旁的面板中调整光线、颜色、曲线、颜色混合、颜色分级、细节、光学和几何；每个分区都可通过标题恢复默认值
- 色阶（含自动调整）、曲线、色相/饱和度、曝光、渐变映射、颗粒、黑白、色彩平衡和反相
- 高斯模糊和动态模糊会延伸到图层边缘之外
- 锐化、降噪、添加杂色、暗角、泛光/光晕、抖动、扫描线、RGB 分离、镜头效果（变形耀斑、星芒、雾化、棱镜和散景；散景支持圆形、六边形、椭圆和猫眼形状）、色调对比、体积光（随距离围绕主体逐渐变浓的雾，可放置光源，照片中的灯光也会在雾中发亮，并可选择添加光束）、轮廓光（最多可在主体后方设置三盏彩色光源，光晕会环绕主体延伸），镜头校正和移除背景
- 支持实时预览；存在选区时，预览仅应用于选区
- 上次使用的滤镜（⌃⌘F）可用相同设置再次运行

### 画布与文件
- 可在标签页中打开多个项目
- 搜索命令（⌘F）：按名称查找所有菜单命令和工具，类似 Raycast 或 Obsidian，按 Return 即可执行
- 切换全屏（F）：只在整个黑色屏幕上显示画布，并隐藏所有面板；按 F 或 Esc 可恢复面板
- 标尺（⌘R）、从标尺拖出的参考线、可调整间距和细分数的网格，以及适用于参考线、网格、图层和文档边界的吸附功能
- 支持吸附裁剪、3:4 和 9:16 等比例，并可按住 Option 对称裁剪；存在选区时，裁剪区域从选区开始
- 画布大小、图像大小和修边
- 窗口高度不足以显示单列工具栏时，工具栏会切换为两列
- 画布角落提供导航器缩略图（缩放达到 300% 时显示）：可查看完整文档和当前视图范围，点击或拖动即可导航（视图 › 导航器）
- 缩小时使用清晰的高质量降采样，放大时显示像素网格
- 支持导入 JPEG、PNG、HEIC、TIFF、WebP、SVG、PDF（每页作为独立图层，可按 300 DPI 或适应画布导入）、动态 GIF（作为单个图层导入，帧以条带显示在画布下方，可播放、绘制、复制、删除和调整帧时长）、相机 RAW（先经过显影步骤）以及 Photoshop PSD 和 PSB（8 位 RGB，不支持 CMYK）。每个 Photoshop 画板会单独在一个标签页中打开；文件夹、蒙版、混合模式、填充矩形/椭圆和简单的水平文字会保持可编辑，其他矢量图形和竖排文字会转换为像素。应用更改前会显示转换报告
- 支持大型文档：内存预算会根据 Mac 的配置调整；超出打开限制的 Photoshop 文件会将图层裁剪至画布大小
- 可导出 PNG（⇧⌘E），也可使用“导出为”（⇧⌥⌘S 或 ⇧⌥⌘W）导出 PNG、JPEG、按打印尺寸生成的单页 PDF，或在包含 GIF 图层时导出动态 GIF；支持调整缩放并实时预览 JPEG 画质和文件大小。“导出为”中的 Channel Pack 可将图层打包到 PNG 的红、绿、蓝和 Alpha 通道，用于游戏纹理；RGB 分离滤镜中的“分离到图层”可将图层还原为这四个通道；在图层面板中右键单击图层可单独导出裁至像素范围的 PNG；还支持“复制合并”
- 项目保存期间可以继续工作
- 全局采用 Photoshop 风格的键盘快捷键，可在“编辑”>“键盘快捷键”中重新映射
- 拖动数值标签即可调整数值，操作方式与 Photoshop 相同
- 支持自动更新；应用已签名并经过公证

### 支持 AI 智能体
- AI 智能体和脚本可以直接创建和编辑项目：`.comp` 是由 PNG 图层和清单文件组成的文件夹；项目打开时，写入的更改会实时更新。详见[编写 Compositor 项目](docs/writing-comp-files.md)

## 系统要求

- 配备 Apple 芯片的 Mac，运行 macOS 26.0 或更高版本
- 从源代码构建需要 Xcode 26 或更高版本

## 翻译

本分支内置简体中文。英文源文案保持为稳定的本地化键，中文目录只改变界面显示文本，因此合并上游更新时无需翻译或重命名已保存的数据。目录结构、检查方式和上游合并流程详见[简体中文本地化](docs/localization.md)。

## 其他平台

Compositor 仅支持 macOS。以下非官方移植由其他开发者制作，未经我审核或支持；遇到问题请联系相应项目维护者：

- [CompositorWindows](https://github.com/Cengokill/CompositorWindows)，由 [@Cengokill](https://github.com/Cengokill) 开发：Windows
- [Composa](https://github.com/dvdstelt/Composa)，由 [@dvdstelt](https://github.com/dvdstelt) 开发：Windows 和 Linux
- [CompositorLX](https://github.com/ClaudiuJitea/compositorLX)，由 [@ClaudiuJitea](https://github.com/ClaudiuJitea) 开发：Linux

更多项目见 [#23（Windows）](https://github.com/robbietilton/Compositor/issues/23) 和 [#19（Linux）](https://github.com/robbietilton/Compositor/issues/19)。

## 构建

打开 `Compositor.xcodeproj` 并运行 **Compositor** scheme。

## 发布

运行 `scripts/release.sh` 可构建 Release 版本、使用 Developer ID 签名、进行公证并附加公证票据，最终打包为 `dist/Compositor-<version>.dmg`。

所需内容均须保存在本仓库之外：

- 登录钥匙串中的 **Developer ID Application** 证书
- 使用 `xcrun notarytool store-credentials "compositor-notary" …` 保存的公证凭证
- [`create-dmg`](https://github.com/create-dmg/create-dmg)（`brew install create-dmg`）

## 许可证

MIT，详见 [LICENSE](LICENSE)。

体积光所用的深度模型 DepthMini 基于 [Depth Anything V2 Small](https://github.com/DepthAnything/Depth-Anything-V2)（Apache-2.0）蒸馏而成，并以 torchvision 使用 ImageNet 训练的 MobileNetV3 权重为起点（BSD-3-Clause）。该模型不包含在应用中，首次打开体积光时会下载。
