// GitService.swift
import Foundation

actor GitService {
    static let shared = GitService()

    func currentBranch() async -> String? {
        await run("git", args: ["rev-parse", "--abbrev-ref", "HEAD"])
    }

    func branches() async -> [GitBranch] {
        guard let output = await run("git", args: ["branch", "-a", "--format=%(refname:short)"]) else { return [] }
        let current = await currentBranch() ?? ""
        return output.split(separator: "\n").map { line in
            let name = String(line).trimmingCharacters(in: .whitespaces)
            return GitBranch(name: name, isCurrent: name == current)
        }
    }

    func diff() async -> String? {
        await run("git", args: ["diff", "--stat"])
    }

    func commit(message: String) async -> String? {
        await run("git", args: ["commit", "-m", message])
    }

    func push() async -> String? {
        await run("git", args: ["push"])
    }

    func log(count: Int = 10) async -> String? {
        await run("git", args: ["log", "--oneline", "-\(count)"])
    }

    private func run(_ command: String, args: [String]) async -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        process.standardInput = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }
}
