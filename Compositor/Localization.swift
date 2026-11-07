import Foundation

/// 中文翻译 → 英文原文的反查表，供命令面板用英文搜索已经翻译的菜单标题。
/// 目录文件缺失时返回空表，搜索按显示文案照常工作。
enum LocalizationAliases {
    /// 标准菜单栏的顶层名称由系统提供，不在目录里，这里补上对应的英文。
    private static let systemMenuEnglish = ["文件": "File", "编辑": "Edit", "显示": "View", "选择": "Select",
                                            "图像": "Image", "滤镜": "Filter", "图层": "Layer", "窗口": "Window",
                                            "帮助": "Help"]

    private static let englishByTranslation: [String: String] = {
        guard let url = Bundle.main.url(forResource: "Localizable", withExtension: "strings",
                                        subdirectory: nil, localization: "zh-Hans"),
              let table = NSDictionary(contentsOf: url) as? [String: String] else { return [:] }
        var map: [String: String] = [:]
        for (key, value) in table where value != key {
            map[value] = key
        }
        return map
    }()

    /// 把菜单路径（"文件 › 导入…"）尽量翻回英文（"File › Import…"）；标题本来就是英文时返回 nil。
    static func englishPath(for title: String) -> String? {
        let parts = title.components(separatedBy: " › ")
        let english = parts.map { englishSource(for: $0) ?? $0 }
        guard english != parts else { return nil }
        return english.joined(separator: " › ")
    }

    /// 菜单末尾的省略号不在目录 key 里，查表时补上。
    private static func englishSource(for part: String) -> String? {
        if let direct = englishByTranslation[part] ?? systemMenuEnglish[part] { return direct }
        guard part.hasSuffix("…") else { return nil }
        let base = String(part.dropLast())
        return (englishByTranslation[base] ?? systemMenuEnglish[base]).map { $0 + "…" }
    }
}

extension String {
    /// 在 Localizable.strings 中查找这段原文。用于 SwiftUI 收到 String 而非 LocalizedStringKey 的场合，
    /// 例如菜单标题和 AppKit 控件。
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /// 用运行时参数格式化本地化文案，同时保留这段原文作为稳定的目录 key。
    func localizedFormat(_ arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }

    /// 菜单标题末尾的省略号不放进目录 key，这样 "Exposure…" 可以复用 "Exposure" 的翻译。
    func localizedMenuTitle() -> String {
        guard hasSuffix("…") else { return localized }
        let base = String(dropLast())
        let translated = base.localized
        return translated == base ? localized : translated + "…"
    }

    /// Undo 和 redo 的名称在 `DocumentHistory` 中保持英文，因为测试会比较它们，且保存的名称不能漂移。
    /// 只在写入菜单时翻译。
    func localizedHistoryAction() -> String {
        let exact = localized
        if exact != self { return exact }
        let prefixes = [
            ("New ", " Adjustment", "New %@ Adjustment"),
            ("Edit ", " Adjustment", "Edit %@ Adjustment"),
            ("Delete ", "", "Delete %@"),
            ("Duplicate ", "", "Duplicate %@"),
            ("Transform ", "", "Transform %@"),
            ("Move ", "", "Move %@"),
            ("Show ", "", "Show %@"),
            ("Hide ", "", "Hide %@"),
        ]
        for (prefix, suffix, format) in prefixes where hasPrefix(prefix) && hasSuffix(suffix) {
            let start = index(startIndex, offsetBy: prefix.count)
            let end = index(endIndex, offsetBy: -suffix.count)
            return format.localizedFormat(String(self[start..<end]).localized)
        }
        return self
    }

    /// "Untitled" 和 "Untitled 2" 是项目名，不是图层名或文件名。保存的标题保持英文，只翻译标签页和窗口标题。
    func localizedProjectTitle() -> String {
        if self == "Untitled" { return localized }
        guard hasPrefix("Untitled "), Int(dropFirst(9)) != nil else { return self }
        return "Untitled %@".localizedFormat(String(dropFirst(9)))
    }

    /// 自动生成的图层名（“Layer 2”“Rectangle 1”等）按当前语言显示；用户命名的图层原样返回。
    /// 图层保存的名称不变，只有列表、提示和可访问性文案用它。
    var localizedLayerName: String {
        if ["Background", "Floating Selection", "Pasted Image", "Canvas Extension", "Layer", "Depth"].contains(self) {
            return localized
        }
        let numbered = [("Layer", "Layer %lld"), ("Page", "Page %lld"), ("Folder", "Folder %lld"),
                        ("Rectangle", "Rectangle %lld"), ("Ellipse", "Ellipse %lld"), ("Line", "Line %lld")]
        for (prefix, format) in numbered {
            guard hasPrefix(prefix + " "), let number = Int(dropFirst(prefix.count + 1)) else { continue }
            return format.localizedFormat(number)
        }
        return self
    }
}
