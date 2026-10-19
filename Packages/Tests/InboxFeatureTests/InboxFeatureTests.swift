import Testing
@testable import InboxFeature

@Test func packageLocalizationLookupByLocale() async throws {
    #expect(InboxFeatureProbe.localizedTitle(localeIdentifier: "en") == "Inbox Feature")
    #expect(InboxFeatureProbe.localizedTitle(localeIdentifier: "es") == "Funcion Bandeja")
}

@Test func generatedAccessorsResolveBundleModule() async throws {
    #expect(PackageL10n.Inbox.title == "Inbox Feature")
}
