// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "Experiences",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MovieListFeature", targets: ["MovieListFeature"])
    ],
    dependencies: [
        .package(path: "../Interfaces")
    ],
    targets: [
        .target(
            name: "MovieListFeature",
            dependencies: [.product(name: "MoviesDomainInterface", package: "Interfaces")],
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
