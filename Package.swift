// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "assets-generation-plugin",
    platforms: [.iOS(.v17)],
    products: [
        .plugin(name: "AssetsPlugin", targets: ["AssetsPlugin"]),
    ],
    targets: [
        .executableTarget(name: "AssetsPluginTool"),
        .plugin(name: "AssetsPlugin", capability: .buildTool(), dependencies: [
            .target(name: "AssetsPluginTool")
        ])
    ]
)
