import SwiftUI

struct PSDConversionRequest: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let confirmTitle: String
    var conversions: [PSDConversion]
    /// The file is still being read: the sheet is up so the click feels answered, but it has
    /// nothing to report yet.
    var isReading: Bool
    init(id: UUID = UUID(), title: String, confirmTitle: String, conversions: [PSDConversion], isReading: Bool = false) {
        self.id = id
        self.title = title
        self.confirmTitle = confirmTitle
        self.conversions = conversions
        self.isReading = isReading
    }
}

struct PSDConversionSheet: View {
    let request: PSDConversionRequest
    let finish: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(request.title).font(.title2.bold())
            Text((request.isReading ? "Reading the file to see what needs converting."
                  : "Compositor will convert these Photoshop features. Nothing is applied until you continue.").localized)
                .foregroundStyle(.secondary)
            if request.isReading {
                HStack(spacing: 10) {
                    ProgressView().controlSize(.small)
                    Text("Reading the Photoshop file…").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                List(request.conversions) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.layerName).font(.headline)
                        Text(item.localizedMessage)
                    }.padding(.vertical, 4)
                }
                .frame(minHeight: 180)
            }
            HStack {
                Spacer()
                Button("Cancel") { finish(false) }.keyboardShortcut(.cancelAction)
                Button(request.confirmTitle) { finish(true) }.keyboardShortcut(.defaultAction)
                    .disabled(request.isReading)
            }
        }
        .padding(24)
        .frame(minWidth: 520, minHeight: 360)
        .roundedControls()
    }
}

extension PSDConversion {
    /// PSD 转换提示由导入层生成，测试也会检查它们。只在显示时翻译，保存的英文提示保持稳定。
    var localizedMessage: String {
        let translated = message.localized
        if translated != message { return translated }
        let patterns = [
            ("Folder blend mode “", "” isn’t supported. The folder will be pass-through.",
             "Folder blend mode “%@” isn’t supported. The folder will be pass-through."),
            ("Blend mode “", "” isn’t supported and will be applied as Normal.",
             "Blend mode “%@” isn’t supported and will be applied as Normal."),
            ("The font “", "” isn’t installed, so the text was drawn with the system font.",
             "The font “%@” isn’t installed, so the text was drawn with the system font."),
        ]
        for (prefix, suffix, format) in patterns where message.hasPrefix(prefix) && message.hasSuffix(suffix) {
            let start = message.index(message.startIndex, offsetBy: prefix.count)
            let end = message.index(message.endIndex, offsetBy: -suffix.count)
            let name = String(message[start..<end])
            return format.localizedFormat(name)
        }
        return message
    }
}

extension View {
    func psdConversionSheet(_ session: EditorSession) -> some View {
        sheet(isPresented: Binding(
            get: { session.showsConversionSheet },
            set: { if !$0 { session.finishConversion(false) } }
        )) {
            if let request = session.conversionRequest {
                PSDConversionSheet(request: request, finish: session.finishConversion)
            }
        }
    }
}
