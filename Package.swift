// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "doctrina-core",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v15),
  ],
  products: [
    .library(name: "Core", targets: ["Core"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.16.0"),
  ],
  targets: [
    .target(
      name: "Core",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "CoreTests",
      dependencies: [ "Core" ]
    ),
  ]
)
