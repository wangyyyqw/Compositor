import Testing
@testable import Compositor

/// 自动生成的图层名只在显示层翻译，保存名保持不变。
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
}
