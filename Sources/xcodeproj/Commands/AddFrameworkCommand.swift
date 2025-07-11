import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct AddFrameworkCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add-framework",
        abstract: "Add framework dependencies"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Name of the target to add framework to")
    var targetName: String
    
    @Argument(help: "Name of the framework to add (e.g., UIKit, Foundation, or path to custom framework)")
    var frameworkName: String
    
    @Flag(name: .long, help: "Whether to embed the framework (for custom frameworks)")
    var embed = false
    
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
            
            // Find or create frameworks build phase
            let frameworksBuildPhase: PBXFrameworksBuildPhase
            if let existingPhase = target.buildPhases.first(where: { $0 is PBXFrameworksBuildPhase }) as? PBXFrameworksBuildPhase {
                frameworksBuildPhase = existingPhase
            } else {
                frameworksBuildPhase = PBXFrameworksBuildPhase()
                xcodeproj.pbxproj.add(object: frameworksBuildPhase)
                target.buildPhases.append(frameworksBuildPhase)
            }
            
            // Determine if this is a system framework or custom framework
            let isSystemFramework = !frameworkName.contains("/") && !frameworkName.hasSuffix(".framework")
            let frameworkFileName: String
            let frameworkPath: String
            
            if isSystemFramework {
                frameworkFileName = "\(frameworkName).framework"
                frameworkPath = "System/Library/Frameworks/\(frameworkFileName)"
            } else {
                // Custom framework path
                let frameworkURL = URL(fileURLWithPath: frameworkName)
                frameworkFileName = frameworkURL.lastPathComponent
                frameworkPath = frameworkName
            }
            
            // Check if framework already exists
            let frameworkExists = frameworksBuildPhase.files?.contains { buildFile in
                if let fileRef = buildFile.file as? PBXFileReference {
                    return fileRef.name == frameworkFileName || fileRef.path == frameworkName
                }
                return false
            } ?? false
            
            if frameworkExists {
                print("Framework '\(frameworkName)' already exists in target '\(targetName)'")
                return
            }
            
            // Create file reference for framework
            let frameworkFileRef: PBXFileReference
            if isSystemFramework {
                frameworkFileRef = PBXFileReference(
                    sourceTree: .sdkRoot,
                    name: frameworkFileName,
                    lastKnownFileType: "wrapper.framework",
                    path: frameworkPath
                )
            } else {
                frameworkFileRef = PBXFileReference(
                    sourceTree: .group,
                    name: frameworkFileName,
                    lastKnownFileType: "wrapper.framework",
                    path: frameworkPath
                )
            }
            xcodeproj.pbxproj.add(object: frameworkFileRef)
            
            // Add to frameworks group if exists
            if let project = xcodeproj.pbxproj.rootObject,
               let frameworksGroup = project.mainGroup?.children.first(where: { element in
                   if let group = element as? PBXGroup {
                       return group.name == "Frameworks"
                   }
                   return false
               }) as? PBXGroup {
                frameworksGroup.children.append(frameworkFileRef)
            } else {
                // Create Frameworks group if it doesn't exist
                if let project = try xcodeproj.pbxproj.rootProject(),
                   let mainGroup = project.mainGroup {
                    let frameworksGroup = PBXGroup(sourceTree: .group, name: "Frameworks")
                    xcodeproj.pbxproj.add(object: frameworksGroup)
                    frameworksGroup.children.append(frameworkFileRef)
                    mainGroup.children.append(frameworksGroup)
                }
            }
            
            // Create build file
            let buildFile = PBXBuildFile(file: frameworkFileRef)
            xcodeproj.pbxproj.add(object: buildFile)
            frameworksBuildPhase.files?.append(buildFile)
            
            // If embed is requested and it's a custom framework, add to embed frameworks phase
            if embed && !isSystemFramework {
                // Find or create embed frameworks build phase
                var embedPhase: PBXCopyFilesBuildPhase?
                for phase in target.buildPhases {
                    if let copyPhase = phase as? PBXCopyFilesBuildPhase,
                       copyPhase.dstSubfolderSpec == .frameworks {
                        embedPhase = copyPhase
                        break
                    }
                }
                
                if embedPhase == nil {
                    embedPhase = PBXCopyFilesBuildPhase(
                        dstPath: "",
                        dstSubfolderSpec: .frameworks,
                        name: "Embed Frameworks"
                    )
                    xcodeproj.pbxproj.add(object: embedPhase!)
                    target.buildPhases.append(embedPhase!)
                }
                
                // Create build file for embedding
                let embedBuildFile = PBXBuildFile(
                    file: frameworkFileRef,
                    settings: ["ATTRIBUTES": ["CodeSignOnCopy", "RemoveHeadersOnCopy"]]
                )
                xcodeproj.pbxproj.add(object: embedBuildFile)
                embedPhase?.files?.append(embedBuildFile)
            }
            
            // Save project
            try xcodeproj.write(path: Path(projectURL.path))
            
            let embedText = embed && !isSystemFramework ? " (embedded)" : ""
            print("Successfully added framework '\(frameworkName)' to target '\(targetName)'\(embedText)")
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}