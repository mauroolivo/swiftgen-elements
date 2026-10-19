//

import SwiftUI

struct ContentView: View {
    private let username = "Mauro"
    private let unreadCount = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stage 2: Assets")
                .font(.headline)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SwiftGen")
                        .font(.subheadline)
                    Asset.Icons.caretLeftRenamed.swiftUIImage
                    Asset.Icons.caretRightLight.swiftUIImage
                    Text("status-warning")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Asset.Colors.statusWarning.swiftUIColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Native")
                        .font(.subheadline)
                    Image(.caretLeftRenamed)
                    Image(.caretRightLight)
                    Text("status-warning")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.statusWarning)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            Divider()

            Text("Stage 3: Localization")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("SwiftGen")
                    .font(.subheadline)
                Text(L10n.Home.title)
                Text(L10n.Home.welcome(username))
                Text(L10n.Notifications.unread(unreadCount))
                Text(L10n.Cart.items(unreadCount))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Native")
                    .font(.subheadline)
                Text("home.title")
                Text(
                    String(
                        format: NSLocalizedString(
                            "home.welcome",
                            tableName: "Localizable",
                            bundle: .main,
                            value: "Welcome, %@!",
                            comment: ""
                        ),
                        username
                    )
                )
                Text(L10n.idCancel)
            }

            Divider()

            Text("Stage 4: Template customization")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Custom namespace")
                    .font(.subheadline)
                Text(StringsLab.Home.title)
                Text(StringsLab.Home.welcome(username))
                Text(StringsLab.idCancel)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
