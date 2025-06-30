import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct AddDependencyCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add-dependency",
        abstract: "Add dependency between targets"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Name of the target that will depend on another target")
    var targetName: String
    
    @Argument(help: "Name of the target to depend on")
    var dependencyName: String
    
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
            
            // Find the dependency target
            guard let dependencyTarget = xcodeproj.pbxproj.nativeTargets.first(where: { $0.name == dependencyName }) else {
                print("Dependency target '\(dependencyName)' not found in project")
                return
            }
            
            // Check if dependency already exists
            let dependencyExists = target.dependencies.contains { dependency in
                dependency.target == dependencyTarget
            }
            
            if dependencyExists {
                print("Target '\(targetName)' already depends on '\(dependencyName)'")
                return
            }
            
            // Create container item proxy
            let containerItemProxy = PBXContainerItemProxy(
                containerPortal: .project(xcodeproj.pbxproj.rootObject!),
                remoteGlobalID: .object(dependencyTarget),
                proxyType: .nativeTarget,
                remoteInfo: dependencyName
            )
            xcodeproj.pbxproj.add(object: containerItemProxy)
            
            // Create target dependency
            let targetDependency = PBXTargetDependency(
                name: dependencyName,
                target: dependencyTarget,
                targetProxy: containerItemProxy
            )
            xcodeproj.pbxproj.add(object: targetDependency)
            
            // Add dependency to target
            target.dependencies.append(targetDependency)
            
            // Save project
            try xcodeproj.write(path: Path(projectURL.path))
            
            print("Successfully added dependency '\(dependencyName)' to target '\(targetName)'")
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}