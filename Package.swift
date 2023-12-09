// swift-tools-version: 5.4
//
//  Package.swift
//  Jarvis
//
//  Created by Jason Anderson on 10/14/23.
//  Copyright © 2023 Kosoku Interactive, LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import PackageDescription

let package = Package(
    name: "Jarvis",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Jarvis",
            targets: ["Jarvis"]),
    ],
    dependencies: [
            // other dependencies
            .package(url: "https://github.com/Kosoku/Feige", from: "2.2.0"),
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Jarvis",
			path: "Jarvis"),
        .testTarget(
            name: "JarvisTests",
            dependencies: ["Jarvis"],
			path: "JarvisTests"),
    ]
)
