import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct ListSwiftPackagesCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list-swift-packages",
        abstract: "List all Swift Package dependencies in an Xcode project"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            guard let project = try xcodeproj.pbxproj.rootProject() else {
                throw ValidationError.internalError("Unable to access project root")
            }
            
            var packages: [String] = []
            
            // List remote packages
            for remotePackage in project.remotePackages {
                let requirement = formatVersionRequirement(
                    remotePackage.versionRequirement ?? .exact("unknown"))
                let url = remotePackage.repositoryURL ?? "unknown"
                packages.append("📦 \(url) (\(requirement))")
            }
            
            // List local packages
            for localPackage in project.localPackages {
                packages.append("📁 \(localPackage.relativePath) (local)")
            }
            
            if packages.isEmpty {
                print("No Swift Package dependencies found in project")
                return
            }
            
            print("Swift Package dependencies:")
            for package in packages {
                print(package)
            }
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
    
    private func formatVersionRequirement(
        _ requirement: XCRemoteSwiftPackageReference.VersionRequirement
    ) -> String {
        switch requirement {
        case let .exact(version):
            return "exact: \(version)"
        case let .upToNextMajorVersion(version):
            return "from: \(version)"
        case let .upToNextMinorVersion(version):
            return "upToNextMinor: \(version)"
        case let .range(from, to):
            return "range: \(from) - \(to)"
        case let .branch(branch):
            return "branch: \(branch)"
        case let .revision(revision):
            return "revision: \(revision)"
        }
    }
}