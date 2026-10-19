// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "InboxFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "InboxFeature",
            targets: ["InboxFeature"]
        ),
    ],
    targets: [
        .target(
            name: "InboxFeature",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
        .testTarget(
            name: "InboxFeatureTests",
            dependencies: ["InboxFeature"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ]
        ),
    ]
)
