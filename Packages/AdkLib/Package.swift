// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "AdkLib",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AdkLib",
            type: .static,
            targets: ["AdkLib"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/OneSignal/OneSignal-iOS-SDK",
            from: "5.0.0"
        )
    ],
    targets: [
        .target(
            name: "AdkLib",
            dependencies: [
                .product(name: "OneSignalExtension", package: "OneSignal-iOS-SDK"),
                .product(name: "OneSignalFramework", package: "OneSignal-iOS-SDK")
            ])
    ]
)
