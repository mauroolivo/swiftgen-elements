// swiftlint:disable all
// Generated using SwiftGen - https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings (Lab Template)

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum StringsLab {
  /// Cancel
  public static let idCancel = StringsLab.tr("Localizable", "id_cancel", fallback: "Cancel")
  public enum Cart {
    /// Plural format key: "%#@items@"
    public static func items(_ p1: Int) -> String {
      return StringsLab.tr("Localizable", "cart.items", p1, fallback: "Plural format key: \"%#@items@\"")
    }
  }
  public enum Home {
    /// Inbox
    public static let title = StringsLab.tr("Localizable", "home.title", fallback: "Inbox")
    /// Welcome, %@!
    public static func welcome(_ p1: Any) -> String {
      return StringsLab.tr("Localizable", "home.welcome", String(describing: p1), fallback: "Welcome, %@!")
    }
  }
  public enum Notifications {
    /// %d unread notifications
    public static func unread(_ p1: Int) -> String {
      return StringsLab.tr("Localizable", "notifications.unread", p1, fallback: "%d unread notifications")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension StringsLab {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
