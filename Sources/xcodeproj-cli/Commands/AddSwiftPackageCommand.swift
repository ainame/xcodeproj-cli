import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct AddSwiftPackageCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add-swift-package",
        abstract: "Add a Swift Package dependency to an Xcode project"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "URL of the Swift Package repository")
    var packageURL: String
    
    @Argument(help: "Version requirement (e.g., '1.0.0', 'from: 1.0.0', 'upToNextMajor: 1.0.0', 'branch: main')")
    var requirement: String
    
    @Option(name: .long, help: "Target to add the package to (optional)")
    var targetName: String?
    
    @Option(name: .long, help: "Specific product name to link (optional)")
    var productName: String?
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            // Check if package already exists
            if let project = try xcodeproj.pbxproj.rootProject(),
               project.remotePackages.contains(where: { $0.repositoryURL == packageURL }) {
                print("Swift Package '\(packageURL)' already exists in project")
                return
            }
            
            // Create Swift Package reference
            let packageRef = XCRemoteSwiftPackageReference(
                repositoryURL: packageURL,
                versionRequirement: parseRequirement(requirement)
            )
            xcodeproj.pbxproj.add(object: packageRef)
            
            // Add to project's package references
            if let project = try xcodeproj.pbxproj.rootProject() {
                project.remotePackages.append(packageRef)
            }
            
            // If target name is specified, add package product to target
            if let targetName = targetName {
                guard let target = xcodeproj.pbxproj.nativeTargets.first(where: { $0.name == targetName }) else {
                    print("Target '\(targetName)' not found in project", to: &standardError)
                    throw ExitCode.failure
                }
                
                // Create product dependency
                let productDependency = XCSwiftPackageProductDependency(
                    productName: productName ?? "Unknown",
                    package: packageRef
                )
                xcodeproj.pbxproj.add(object: productDependency)
                
                // Initialize packageProductDependencies if nil
                if target.packageProductDependencies == nil {
                    target.packageProductDependencies = []
                }
                target.packageProductDependencies?.append(productDependency)
            }
            
            // Save project
            try xcodeproj.write(path: Path(projectURL.path))
            
            var message = "Successfully added Swift Package '\(packageURL)' with requirement '\(requirement)'"
            if let targetName = targetName {
                message += " to target '\(targetName)'"
            }
            print(message)
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
    
    private func parseRequirement(_ requirement: String) -> XCRemoteSwiftPackageReference.VersionRequirement {
        let trimmed = requirement.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Parse different requirement formats
        if trimmed.hasPrefix("from:") {
            let version = String(trimmed.dropFirst(5)).trimmingCharacters(in: .whitespacesAndNewlines)
            return .upToNextMajorVersion(version)
        } else if trimmed.hasPrefix("upToNextMajor:") {
            let version = String(trimmed.dropFirst(14)).trimmingCharacters(in: .whitespacesAndNewlines)
            return .upToNextMajorVersion(version)
        } else if trimmed.hasPrefix("upToNextMinor:") {
            let version = String(trimmed.dropFirst(14)).trimmingCharacters(in: .whitespacesAndNewlines)
            return .upToNextMinorVersion(version)
        } else if trimmed.hasPrefix("branch:") {
            let branch = String(trimmed.dropFirst(7)).trimmingCharacters(in: .whitespacesAndNewlines)
            return .branch(branch)
        } else if trimmed.hasPrefix("revision:") {
            let revision = String(trimmed.dropFirst(9)).trimmingCharacters(in: .whitespacesAndNewlines)
            return .revision(revision)
        } else if trimmed.hasPrefix("exact:") {
            let version = String(trimmed.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
            return .exact(version)
        } else {
            // Default to exact version if just a version number
            return .exact(trimmed)
        }
    }
}
