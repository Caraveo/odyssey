// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Odyssey",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Odyssey",
            targets: ["Odyssey"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Odyssey",
            dependencies: [],
            path: "Sources"
        )
    ]
)

