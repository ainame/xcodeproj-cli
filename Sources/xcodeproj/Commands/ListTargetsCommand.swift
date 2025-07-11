import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct ListTargetsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list-targets",
        abstract: "List all targets in an Xcode project"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            // Load project
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            // Get all native targets
            let nativeTargets = xcodeproj.pbxproj.nativeTargets
            
            if nativeTargets.isEmpty {
                print("No targets found in the project.")
                return
            }
            
            // Format output
            let projectFileName = projectURL.lastPathComponent
            print("Targets in \(projectFileName):")
            
            for target in nativeTargets {
                let productType = target.productType?.rawValue ?? "unknown"
                print("- \(target.name) (\(productType))")
            }
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}