import Foundation
import Testing
@testable import Compositor

/// 运行时生成的名称只在显示层翻译，保存名保持不变。
@MainActor
struct LocalizationTests {
    @Test func generatedLayerNamesTranslateOnlyForDisplay() {
        #expect("Layer 3".localizedLayerName == "Layer %lld".localizedFormat(3))
        #expect("Folder 2".localizedLayerName == "Folder %lld".localizedFormat(2))
        #expect("Page 12".localizedLayerName == "Page %lld".localizedFormat(12))
        #expect("Rectangle 1".localizedLayerName == "Rectangle %lld".localizedFormat(1))
        #expect("Ellipse 4".localizedLayerName == "Ellipse %lld".localizedFormat(4))
        #expect("Line 5".localizedLayerName == "Line %lld".localizedFormat(5))
        #expect("Floating Selection".localizedLayerName == "Floating Selection".localized)
        #expect("Pasted Image".localizedLayerName == "Pasted Image".localized)
        // 用户自己起的名字原样保留。
        #expect("My Photo".localizedLayerName == "My Photo")
        #expect("Layer".localizedLayerName == "Layer".localized)
    }

    @Test func translatedMenusStaySearchableInEnglish() {
        #expect(LocalizationAliases.englishPath(for: "文件 › 导入…") == "File › Import…")
        #expect(LocalizationAliases.englishPath(for: "滤镜 › 高斯模糊…") == "Filter › Gaussian Blur…")
        let entry = CommandPaletteEntry(id: "File › Import…", title: "文件 › 导入…", searchText: "File › Import…",
                                        shortcut: nil, isEnabled: true, perform: {})
        #expect(CommandPaletteSearch.rank([entry], query: "file import").count == 1)
        #expect(CommandPaletteSearch.rank([entry], query: "导入").count == 1)
    }

    @Test(arguments: LayerEffectKind.allCases)
    func effectHistoryNamesTranslateForDisplay(_ kind: LayerEffectKind) {
        for (verb, format) in [("Add", "Add %@"), ("Cancel", "Cancel %@"), ("Edit", "Edit %@"),
                               ("Copy", "Copy %@"), ("Remove", "Remove %@"), ("Show", "Show %@"), ("Hide", "Hide %@")] {
            let action = "\(verb) \(kind.rawValue)"
            #expect(action.localizedHistoryAction() == format.localizedFormat(kind.rawValue.localized))
        }
    }

    @Test(arguments: LayerAlignment.allCases)
    func alignmentHistoryNamesTranslateForDisplay(_ alignment: LayerAlignment) {
        #expect(("Align " + alignment.rawValue).localizedHistoryAction() == "Align %@".localizedFormat(alignment.rawValue.localized))
    }

    @Test func historyTranslationKeepsSpecificActions() {
        for distribution in [LayerDistribution.horizontalSpacing, .verticalSpacing] {
            #expect(("Distribute " + distribution.rawValue).localizedHistoryAction()
                    == "Distribute %@".localizedFormat(distribution.rawValue.localized))
        }
        #expect("Distribute Horizontal Centers".localizedHistoryAction() == "Distribute Horizontal Centers".localized)
        #expect("Edit Curves Adjustment".localizedHistoryAction() == "Edit %@ Adjustment".localizedFormat("Curves".localized))
        #expect("My custom action".localizedHistoryAction() == "My custom action")
    }

    /// 这些词条通过变量传给控件，静态提取器无法可靠覆盖。
    @Test func runtimeNamesHaveChineseEntries() throws {
        let url = try #require(Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "zh-Hans"))
        let catalog = try #require(PropertyListSerialization.propertyList(from: Data(contentsOf: url), format: nil) as? [String: String])
        let names = LayerEffectKind.allCases.map(\.rawValue) + LayerAlignment.allCases.map(\.rawValue)
            + LayerDistribution.allCases.map(\.rawValue) + ShapeKind.allCases.map(\.rawValue)
            + ShapeLineStyle.allCases.map(\.rawValue) + ShapeLineCap.allCases.map(\.rawValue)
            + ShortcutDefinition.all.map(\.title)
        let formats = ["Fill", "Shape Style", "Add %@", "Cancel %@", "Edit %@", "Copy %@", "Remove %@", "Distribute %@",
                       "Frame %lld", "%@ ms", "%@ms", " · %lld DPI: %lld × %lld pixels"]
        for key in Set(names + formats) {
            let translated = try #require(catalog[key], "缺少中文词条：\(key)")
            #expect(translated != key, "词条尚未翻译：\(key)")
        }
    }
}
