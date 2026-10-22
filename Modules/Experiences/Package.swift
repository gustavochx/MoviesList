// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "Experiences",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MovieListFeature", targets: ["MovieListFeature"])
    ],
    dependencies: [
        .package(path: "../Interfaces"),
        .package(path: "../Cores"),
        .package(path: "../UI")
    ],
    targets: [
        .target(
            name: "MovieListFeature",
            dependencies: [
                .product(name: "MoviesDomainInterface", package: "Interfaces"),
                .product(name: "DesignSystem", package: "UI"),
                .product(name: "FoundationExtensions", package: "Cores")
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(
            name: "MovieListFeatureTests",
            dependencies: [
                "MovieListFeature",
                .product(name: "MoviesDomainInterface", package: "Interfaces")
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)
