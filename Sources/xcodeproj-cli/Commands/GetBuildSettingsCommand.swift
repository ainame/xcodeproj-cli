import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct GetBuildSettingsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "get-build-settings",
        abstract: "Get build settings for a specific target in an Xcode project"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Name of the target to get build settings for")
    var targetName: String
    
    @Option(name: .long, help: "Build configuration name (defaults to Debug)")
    var configuration: String = "Debug"
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            // Load project
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            // Find the target
            guard let target = xcodeproj.pbxproj.nativeTargets.first(where: { $0.name == targetName }) else {
                throw ValidationError.invalidParams("Target '\(targetName)' not found in project")
            }
            
            // Get the build configuration for the target
            guard let configList = target.buildConfigurationList else {
                throw ValidationError.invalidParams("Target '\(targetName)' has no build configuration list")
            }
            
            guard let config = configList.buildConfigurations.first(where: { $0.name == configuration }) else {
                throw ValidationError.invalidParams("Configuration '\(configuration)' not found for target '\(targetName)'")
            }
            
            // Format build settings
            var settingsList: [String] = []
            for (key, value) in config.buildSettings.sorted(by: { $0.key < $1.key }) {
                let valueString: String
                switch value {
                case .string(let stringValue):
                    valueString = stringValue
                case .array(let arrayValue):
                    valueString = arrayValue.joined(separator: " ")
                }
                settingsList.append("  \(key) = \(valueString)")
            }
            
            if settingsList.isEmpty {
                print("No build settings found.")
                return
            }
            
            print("Build settings for target '\(targetName)' (\(configuration)):")
            for setting in settingsList {
                print(setting)
            }
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}