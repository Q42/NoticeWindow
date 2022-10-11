// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NoticeWindow",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "NoticeWindow",
            targets: ["NoticeWindow"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "NoticeWindow",
            dependencies: [],
            path: "Pod",
            resources: [
                .process("Resources"),
                .copy("Assets")
            ]
        )
    ]
)
