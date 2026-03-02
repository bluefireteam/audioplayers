// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "audioplayers_darwin",
  platforms: [
    .iOS("13.0"),
    .macOS("10.15"),
  ],
  products: [
    .library(name: "audioplayers-darwin", targets: ["audioplayers_darwin"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "audioplayers_darwin",
      dependencies: [],
      resources: [
        // .process("PrivacyInfo.xcprivacy"),
      ]
    )
  ]
)