import Foundation

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
}
