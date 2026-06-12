// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CAssistant",
    platforms: [
        .iOS(.v16),
        .macCatalyst(.v16)
    ],
    products: [
        .library(
            name: "CAssistant",
            targets: ["CAssistant"]
        ),
    ],
    targets: [
        .target(
            name: "CAssistant",
            dependencies: [],
            path: "CAssistant",
            exclude: ["Info.plist", "Resources"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .define("SWIFTUI_ENABLE_LIQUID_GLASS"),
                .unsafeFlags(["-enable-bare-slash-regex"])
            ]
        ),
    ]
)