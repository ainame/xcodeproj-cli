import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct AddFileCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add-file",
        abstract: "Add a file to an Xcode project"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Path to the file to add")
    var filePath: String
    
    @Option(name: .long, help: "Name of the group to add the file to (defaults to main group)")
    var groupName: String?
    
    @Option(name: .long, help: "Name of the target to add the file to")
    var targetName: String?
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            // Resolve and validate the file path
            let fileURL = URL(fileURLWithPath: filePath)
            
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            // Create file reference
            let fileName = fileURL.lastPathComponent
            let fileReference = PBXFileReference(
                sourceTree: .group,
                name: fileName,
                path: filePath
            )
            xcodeproj.pbxproj.add(object: fileReference)
            
            // Find the group to add the file to
            let targetGroup: PBXGroup
            if let groupName = groupName {
                // Find group by name
                if let foundGroup = xcodeproj.pbxproj.groups.first(where: { $0.name == groupName }) {
                    targetGroup = foundGroup
                } else {
                    throw ValidationError.invalidParams("Group '\(groupName)' not found in project")
                }
            } else {
                // Use main group
                guard let project = try xcodeproj.pbxproj.rootProject(),
                      let mainGroup = project.mainGroup else {
                    throw ValidationError.internalError("Main group not found in project")
                }
                targetGroup = mainGroup
            }
            
            // Add file to group
            targetGroup.children.append(fileReference)
            
            // Add file to target if specified
            if let targetName = targetName {
                guard let target = xcodeproj.pbxproj.nativeTargets.first(where: { $0.name == targetName }) else {
                    throw ValidationError.invalidParams("Target '\(targetName)' not found in project")
                }
                
                // Create build file
                let buildFile = PBXBuildFile(file: fileReference)
                xcodeproj.pbxproj.add(object: buildFile)
                
                // Add to appropriate build phase based on file extension
                let fileExtension = fileURL.pathExtension.lowercased()
                
                if ["swift", "m", "mm", "c", "cpp", "cc", "cxx"].contains(fileExtension) {
                    // Source file - add to compile sources
                    if let sourcesBuildPhase = target.buildPhases.first(where: { $0 is PBXSourcesBuildPhase }) as? PBXSourcesBuildPhase {
                        sourcesBuildPhase.files?.append(buildFile)
                    } else {
                        // Create sources build phase if it doesn't exist
                        let sourcesBuildPhase = PBXSourcesBuildPhase(files: [buildFile])
                        xcodeproj.pbxproj.add(object: sourcesBuildPhase)
                        target.buildPhases.append(sourcesBuildPhase)
                    }
                } else if ["h", "hpp", "hxx"].contains(fileExtension) {
                    // Header file - add to headers build phase
                    if let headersBuildPhase = target.buildPhases.first(where: { $0 is PBXHeadersBuildPhase }) as? PBXHeadersBuildPhase {
                        headersBuildPhase.files?.append(buildFile)
                    } else {
                        // Create headers build phase if it doesn't exist
                        let headersBuildPhase = PBXHeadersBuildPhase(files: [buildFile])
                        xcodeproj.pbxproj.add(object: headersBuildPhase)
                        target.buildPhases.append(headersBuildPhase)
                    }
                } else {
                    // Resource file - add to copy bundle resources
                    if let resourcesBuildPhase = target.buildPhases.first(where: { $0 is PBXResourcesBuildPhase }) as? PBXResourcesBuildPhase {
                        resourcesBuildPhase.files?.append(buildFile)
                    } else {
                        // Create resources build phase if it doesn't exist
                        let resourcesBuildPhase = PBXResourcesBuildPhase(files: [buildFile])
                        xcodeproj.pbxproj.add(object: resourcesBuildPhase)
                        target.buildPhases.append(resourcesBuildPhase)
                    }
                }
            }
            
            // Write project
            try xcodeproj.write(path: Path(projectURL.path))
            
            let targetInfo = targetName != nil ? " to target '\(targetName!)'" : ""
            let groupInfo = groupName != nil ? " in group '\(groupName!)'" : ""
            
            print("Successfully added file '\(fileName)'\(targetInfo)\(groupInfo)")
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}
