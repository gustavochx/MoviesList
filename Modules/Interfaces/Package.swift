// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "Interfaces",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MoviesDomainInterface", targets: ["MoviesDomainInterface"])
    ],
    targets: [
        .target(name: "MoviesDomainInterface"),
        .testTarget(name: "MoviesDomainInterfaceTests", dependencies: ["MoviesDomainInterface"])
    ]
)
