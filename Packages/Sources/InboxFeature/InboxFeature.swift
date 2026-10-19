import Foundation
import SwiftUI

public struct InboxFeatureNativeView: View {
    @Environment(\.locale) private var locale

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(packageLocalized("inbox.title", fallback: "Inbox Feature", locale: locale))
            Text(packageLocalized("inbox.cta", fallback: "Open message", locale: locale))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color("PackageAccent", bundle: .module))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

public struct InboxFeatureSwiftGenView: View {
    @Environment(\.locale) private var locale

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(packageLocalized("inbox.title", fallback: PackageL10n.Inbox.title, locale: locale))
            Text(packageLocalized("inbox.cta", fallback: PackageL10n.Inbox.cta, locale: locale))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color("PackageAccent", bundle: .module))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

public enum InboxFeatureProbe {
    public static func localizedTitle(localeIdentifier: String) -> String {
        guard let path = Bundle.module.path(forResource: localeIdentifier, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else {
            return "missing-bundle"
        }
        return bundle.localizedString(forKey: "inbox.title", value: nil, table: "Localizable")
    }
}

private func packageLocalized(_ key: String, fallback: String, locale: Locale) -> String {
    let languageCode = locale.language.languageCode?.identifier
    let candidates = [locale.identifier, languageCode].compactMap { $0 }

    for candidate in candidates {
        guard let path = Bundle.module.path(forResource: candidate, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else {
            continue
        }

        let localized = bundle.localizedString(forKey: key, value: nil, table: "Localizable")
        if localized != key {
            return localized
        }
    }

    return Bundle.module.localizedString(forKey: key, value: fallback, table: "Localizable")
}

#if canImport(SwiftUI) && DEBUG
#Preview("Native Bundle.module") {
    InboxFeatureNativeView()
}

#Preview("SwiftGen PackageL10n") {
    InboxFeatureSwiftGenView()
}
#endif
