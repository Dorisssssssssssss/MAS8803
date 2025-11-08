// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "8803NourishFit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "8803NourishFit",
            targets: ["8803NourishFit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "8803NourishFit",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ]
        )
    ]
)
