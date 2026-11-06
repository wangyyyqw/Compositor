# 简体中文本地化

Compositor 的源代码和界面原文都使用英文。简体中文目录把英文原文同时作为 `.strings` 的 key 和翻译来源，因此不需要维护另一套字符串 ID，也不会改动项目文件格式、图层名称、快捷键 ID 或其他持久化数据。

这样做的目的不是把 UI 文案硬编码成中文，而是把本地化限制在显示层。合并上游更新时，源代码的差异仍然可读；新增或修改的英文文案会被检查脚本找出来，再补到中文目录。

## 文件

- `Compositor/Localization.swift`：`.localized`、`.localizedFormat` 等显示层辅助方法。
- `Compositor/zh-Hans.lproj/Localizable.strings`：界面文案。key 是英文原文，值是简体中文。
- `Compositor/zh-Hans.lproj/InfoPlist.strings`：文件类型名称等包信息。
- `scripts/sync-localizations.sh`：提取 Swift 源码中的静态文案并检查目录。
- `scripts/check-localizations.py`：检查重复 key、空翻译、占位符类型和缺失 key。

## 写新文案

1. 源代码里先写英文原文，保持现有命名和风格。
2. SwiftUI 的 `Text("…")`、`Button("…")`、`Label("…")` 等 `LocalizedStringKey` 字面量会自动查表。
3. 对 `String`、AppKit 控件、菜单标题和运行时拼出的文案使用 `.localized`：

   ```swift
   button.title = "Export".localized
   ```

4. 带参数的文案不要直接插值，否则 key 会变成 `%arg`，无法稳定翻译：

   ```swift
   // 不要这样写：
   Text("Current: \(width) × \(height) pixels")

   // 这样写：
   Text("Current: %lld × %lld pixels".localizedFormat(width, height))
   ```

5. 菜单末尾的省略号放在 key 外：

   ```swift
   Button((kind.rawValue + "…").localizedMenuTitle())
   ```

6. 不要翻译内部标识、文件名、快捷键存储值、Undo/Redo 的原始名称或项目数据；只在显示时转换。

## 补翻译

修改或合并上游代码后先运行：

```sh
scripts/sync-localizations.sh
```

脚本会调用 `xcstringstool` 提取 SwiftUI/AppKit 静态 key，并扫描 `.localized` 字面量。若有源码使用但目录中不存在的 key，会列出并返回失败。

需要先把新 key 追加成英文占位时运行：

```sh
scripts/sync-localizations.sh --write
```

然后翻译 `Compositor/zh-Hans.lproj/Localizable.strings` 中的 TODO 块，再运行检查：

```sh
plutil -lint Compositor/zh-Hans.lproj/Localizable.strings
scripts/sync-localizations.sh
```

检查重点：

- 不允许重复 key 或空翻译。
- 英文 key 与中文值的格式占位符类型必须一致，例如 `%lld` 不能改成 `%d`。位置可以调整，例如 `%@ of %@` 可以译成 `%2$@的%1$@`。
- `%arg` 只会用于数字等不需要翻译的插值；带文字的 `%arg` 会报错，应改成 `.localizedFormat`。

CI 会在构建前运行 `scripts/sync-localizations.sh --strict`。

## 合并上游更新

仓库已有 `upstream` remote 时，常规流程是：

```sh
git fetch upstream
git switch main
git merge upstream/main
```

解决冲突时保留上游的功能和逻辑，再在显示层补回本地化调用。`zh-Hans.lproj` 是新增文件，通常不会和上游冲突；合并后运行 `scripts/sync-localizations.sh`，按报告补齐新增 key，删除确实不再使用的旧词条。

重点检查：

1. 上游改过的英文文案是否已经以新 key 出现在 `.strings` 中。
2. 用 `.localized` 的菜单、错误提示和 AppKit 文案是否仍然在显示层翻译。
3. 带参数的文案是否使用 `.localizedFormat`，没有把 `%lld`、`%@` 写错。
4. `xcodebuild build` 和 `CompositorTests` 是否通过。

这样做可以把“翻译”和“功能更新”分开：上游更新只管英文和逻辑，本地目录只负责中文值，合并后由脚本报告缺口。
