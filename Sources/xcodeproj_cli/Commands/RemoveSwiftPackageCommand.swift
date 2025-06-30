import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct RemoveSwiftPackageCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "remove-swift-package",
        abstract: "Remove a Swift Package dependency from an Xcode project"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "URL of the Swift Package repository to remove")
    var packageURL: String
    
    @Flag(name: .long, help: "Whether to remove package from all targets (default: true)")
    var removeFromTargets = true
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            guard let project = try xcodeproj.pbxproj.rootProject() else {
                print("Unable to access project root", to: &standardError)
                throw ExitCode.failure
            }
            
            // Find the package to remove
            guard let packageIndex = project.remotePackages.firstIndex(where: { $0.repositoryURL == packageURL }) else {
                print("Swift Package '\(packageURL)' not found in project")
                return
            }
            
            let packageRef = project.remotePackages[packageIndex]
            
            // Remove package product dependencies from all targets if requested
            if removeFromTargets {
                for target in xcodeproj.pbxproj.nativeTargets {
                    // Find and remove product dependencies that reference this package
                    if let dependencies = target.packageProductDependencies {
                        let dependenciesToRemove = dependencies.filter { dependency in
                            dependency.package === packageRef
                        }
                        
                        for dependency in dependenciesToRemove {
                            // Remove from target
                            target.packageProductDependencies?.removeAll { $0 === dependency }
                            
                            // Remove from pbxproj objects
                            xcodeproj.pbxproj.delete(object: dependency)
                        }
                    }
                }
            }
            
            // Remove package reference from project
            project.remotePackages.remove(at: packageIndex)
            
            // Remove from pbxproj objects
            xcodeproj.pbxproj.delete(object: packageRef)
            
            // Save project
            try xcodeproj.write(path: Path(projectURL.path))
            
            var message = "Successfully removed Swift Package '\(packageURL)' from project"
            if removeFromTargets {
                message += " and all targets"
            }
            print(message)
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}
