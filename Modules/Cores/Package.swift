// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "Cores",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MoviesDomain", targets: ["MoviesDomain"]),
        .library(name: "MoviesData", targets: ["MoviesData"])
    ],
    dependencies: [
        .package(path: "../Interfaces")
    ],
    targets: [
        .target(
            name: "MoviesDomain",
            dependencies: [.product(name: "MoviesDomainInterface", package: "Interfaces")]
        ),
        .testTarget(
            name: "MoviesDomainTests",
            dependencies: [
                "MoviesDomain",
                .product(name: "MoviesDomainInterface", package: "Interfaces")
            ]
        ),
        .target(
            name: "MoviesData",
            dependencies: [.product(name: "MoviesDomainInterface", package: "Interfaces")]
        ),
        .testTarget(
            name: "MoviesDataTests",
            dependencies: [
                "MoviesData",
                .product(name: "MoviesDomainInterface", package: "Interfaces")
            ],
            resources: [.copy("Fixtures")]
        )
    ]
)
