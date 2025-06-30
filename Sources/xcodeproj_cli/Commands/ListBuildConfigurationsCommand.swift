import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct ListBuildConfigurationsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list-build-configurations",
        abstract: "List all build configurations in an Xcode project"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            // Load project
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            let buildConfigurations = xcodeproj.pbxproj.buildConfigurations
            
            if buildConfigurations.isEmpty {
                print("No build configurations found in the project.")
                return
            }
            
            // Format output
            let projectFileName = projectURL.lastPathComponent
            print("Build configurations in \(projectFileName):")
            
            for config in buildConfigurations {
                print("- \(config.name)")
            }
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}