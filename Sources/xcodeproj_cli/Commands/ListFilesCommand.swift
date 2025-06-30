import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct ListFilesCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list-files",
        abstract: "List all files in a specific target of an Xcode project"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Name of the target to list files for")
    var targetName: String
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            // Load project
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            // Find the target by name
            guard let target = xcodeproj.pbxproj.nativeTargets.first(where: { $0.name == targetName }) else {
                throw ValidationError.invalidParams("Target '\(targetName)' not found in project")
            }
            
            var fileList: [String] = []
            
            // Get files from build phases
            for buildPhase in target.buildPhases {
                if let sourcesBuildPhase = buildPhase as? PBXSourcesBuildPhase {
                    for file in sourcesBuildPhase.files ?? [] {
                        if let fileRef = file.file {
                            if let path = fileRef.path {
                                fileList.append("- \(path)")
                            } else if let name = fileRef.name {
                                fileList.append("- \(name)")
                            }
                        }
                    }
                } else if let resourcesBuildPhase = buildPhase as? PBXResourcesBuildPhase {
                    for file in resourcesBuildPhase.files ?? [] {
                        if let fileRef = file.file {
                            if let path = fileRef.path {
                                fileList.append("- \(path)")
                            } else if let name = fileRef.name {
                                fileList.append("- \(name)")
                            }
                        }
                    }
                } else if let frameworksBuildPhase = buildPhase as? PBXFrameworksBuildPhase {
                    for file in frameworksBuildPhase.files ?? [] {
                        if let fileRef = file.file {
                            if let path = fileRef.path {
                                fileList.append("- \(path)")
                            } else if let name = fileRef.name {
                                fileList.append("- \(name)")
                            }
                        }
                    }
                }
            }
            
            if fileList.isEmpty {
                print("No files found in target '\(targetName)'.")
                return
            }
            
            print("Files in target '\(targetName)':")
            for file in fileList {
                print(file)
            }
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}