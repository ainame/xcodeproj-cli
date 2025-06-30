import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct RemoveTargetCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "remove-target",
        abstract: "Remove an existing target"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Name of the target to remove")
    var targetName: String
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            // Find the target to remove
            guard let targetIndex = xcodeproj.pbxproj.nativeTargets.firstIndex(where: { $0.name == targetName }) else {
                print("Target '\(targetName)' not found in project")
                return
            }
            
            let target = xcodeproj.pbxproj.nativeTargets[targetIndex]
            
            // Remove target dependencies from other targets
            for otherTarget in xcodeproj.pbxproj.nativeTargets {
                otherTarget.dependencies.removeAll { dependency in
                    dependency.target == target
                }
            }
            
            // Remove build phases
            for buildPhase in target.buildPhases {
                xcodeproj.pbxproj.delete(object: buildPhase)
            }
            
            // Remove build configuration list
            if let configList = target.buildConfigurationList {
                for config in configList.buildConfigurations {
                    xcodeproj.pbxproj.delete(object: config)
                }
                xcodeproj.pbxproj.delete(object: configList)
            }
            
            // Remove product reference if exists
            if let productRef = target.product {
                // Remove from products group
                if let project = xcodeproj.pbxproj.rootObject,
                   let productsGroup = project.productsGroup {
                    productsGroup.children.removeAll { $0 == productRef }
                }
                xcodeproj.pbxproj.delete(object: productRef)
            }
            
            // Remove target from project
            if let project = xcodeproj.pbxproj.rootObject {
                project.targets.removeAll { $0 == target }
            }
            
            // Remove target group if exists
            if let project = try xcodeproj.pbxproj.rootProject(),
               let mainGroup = project.mainGroup {
                // Find and remove target folder
                func removeTargetGroup(from group: PBXGroup) {
                    group.children.removeAll { element in
                        if let groupElement = element as? PBXGroup,
                           groupElement.name == targetName {
                            xcodeproj.pbxproj.delete(object: groupElement)
                            return true
                        }
                        return false
                    }
                    
                    // Recursively check child groups
                    for child in group.children {
                        if let childGroup = child as? PBXGroup {
                            removeTargetGroup(from: childGroup)
                        }
                    }
                }
                removeTargetGroup(from: mainGroup)
            }
            
            // Remove the target itself
            xcodeproj.pbxproj.delete(object: target)
            
            // Save project
            try xcodeproj.write(path: Path(projectURL.path))
            
            print("Successfully removed target '\(targetName)' from project")
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}