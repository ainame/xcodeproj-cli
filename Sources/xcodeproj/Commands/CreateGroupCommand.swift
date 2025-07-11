import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct CreateGroupCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "create-group",
        abstract: "Create a new group in the project navigator"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Name of the group to create")
    var groupName: String
    
    @Option(name: .long, help: "Name of the parent group (defaults to main group)")
    var parentGroup: String?
    
    @Option(name: .long, help: "Relative path for the group")
    var path: String?
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            // Check if group already exists
            if xcodeproj.pbxproj.groups.contains(where: { $0.name == groupName }) {
                print("Group '\(groupName)' already exists in project")
                return
            }
            
            // Create new group
            let newGroup = PBXGroup(sourceTree: .group, name: groupName, path: path)
            xcodeproj.pbxproj.add(object: newGroup)
            
            // Find parent group
            let targetParentGroup: PBXGroup
            if let parentGroupName = parentGroup {
                // Find specified parent group
                if let foundGroup = xcodeproj.pbxproj.groups.first(where: { $0.name == parentGroupName }) {
                    targetParentGroup = foundGroup
                } else {
                    throw ValidationError.invalidParams("Parent group '\(parentGroupName)' not found in project")
                }
            } else {
                // Use main group
                guard let project = try xcodeproj.pbxproj.rootProject(),
                      let mainGroup = project.mainGroup else {
                    throw ValidationError.internalError("Main group not found in project")
                }
                targetParentGroup = mainGroup
            }
            
            // Add new group to parent
            targetParentGroup.children.append(newGroup)
            
            // Save project
            try xcodeproj.write(path: Path(projectURL.path))
            
            print("Successfully created group '\(groupName)' in \(parentGroup ?? "main group")")
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}