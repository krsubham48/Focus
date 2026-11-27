// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "FocusCore",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [.library(name: "FocusCore", targets: ["FocusCore"])],
    targets: [
        .target(name: "FocusCore"),
        .testTarget(name: "FocusCoreTests", dependencies: ["FocusCore"]),
    ]
)
