import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct SetBuildSettingCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "set-build-setting",
        abstract: "Modify build settings for a target"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Name of the target to modify")
    var targetName: String
    
    @Argument(help: "Build configuration name (Debug, Release, or All)")
    var configuration: String
    
    @Argument(help: "Name of the build setting to modify")
    var settingName: String
    
    @Argument(help: "New value for the build setting")
    var settingValue: String
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            // Find the target
            guard let target = xcodeproj.pbxproj.nativeTargets.first(where: { $0.name == targetName }) else {
                print("Target '\(targetName)' not found in project")
                return
            }
            
            // Get the build configuration list for the target
            guard let configList = target.buildConfigurationList else {
                print("Target '\(targetName)' has no build configuration list")
                return
            }
            
            var modifiedConfigurations: [String] = []
            
            // Handle "All" configuration
            if configuration.lowercased() == "all" {
                for config in configList.buildConfigurations {
                    config.buildSettings[settingName] = settingValue
                    modifiedConfigurations.append(config.name)
                }
            } else {
                // Find specific configuration
                guard let config = configList.buildConfigurations.first(where: { $0.name == configuration }) else {
                    print("Configuration '\(configuration)' not found for target '\(targetName)'")
                    return
                }
                
                config.buildSettings[settingName] = settingValue
                modifiedConfigurations.append(config.name)
            }
            
            // Save project
            try xcodeproj.write(path: Path(projectURL.path))
            
            let configurationsText = modifiedConfigurations.joined(separator: ", ")
            print("Successfully set '\(settingName)' to '\(settingValue)' for target '\(targetName)' in configuration(s): \(configurationsText)")
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}