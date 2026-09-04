// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AgentOffice",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "AgentOffice",
            path: "Sources",
            resources: [
                .copy("../../public/agents.json")
            ]
        )
    ]
)
