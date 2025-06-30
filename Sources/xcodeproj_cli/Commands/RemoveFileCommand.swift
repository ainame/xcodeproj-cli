import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct RemoveFileCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "remove-file",
        abstract: "Remove a file from the Xcode project"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Path to the file to remove")
    var filePath: String
    
    @Flag(name: .long, help: "Also delete the file from disk")
    var removeFromDisk = false
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            // Resolve and validate the file path
            let fileURL = URL(fileURLWithPath: filePath)
            
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            let fileName = fileURL.lastPathComponent
            var removedFromTargets: [String] = []
            var fileRemoved = false
            
            // Find and remove file references from build phases
            for target in xcodeproj.pbxproj.nativeTargets {
                // Check sources build phase
                if let sourcesBuildPhase = target.buildPhases.first(where: { $0 is PBXSourcesBuildPhase }) as? PBXSourcesBuildPhase {
                    if let fileIndex = sourcesBuildPhase.files?.firstIndex(where: { buildFile in
                        if let fileRef = buildFile.file as? PBXFileReference {
                            return fileRef.path == filePath || fileRef.name == fileName || fileRef.path == fileName
                        }
                        return false
                    }) {
                        sourcesBuildPhase.files?.remove(at: fileIndex)
                        removedFromTargets.append(target.name)
                        fileRemoved = true
                    }
                }
                
                // Check resources build phase
                if let resourcesBuildPhase = target.buildPhases.first(where: { $0 is PBXResourcesBuildPhase }) as? PBXResourcesBuildPhase {
                    if let fileIndex = resourcesBuildPhase.files?.firstIndex(where: { buildFile in
                        if let fileRef = buildFile.file as? PBXFileReference {
                            return fileRef.path == filePath || fileRef.name == fileName || fileRef.path == fileName
                        }
                        return false
                    }) {
                        resourcesBuildPhase.files?.remove(at: fileIndex)
                        if !removedFromTargets.contains(target.name) {
                            removedFromTargets.append(target.name)
                        }
                        fileRemoved = true
                    }
                }
            }
            
            // Remove from project groups
            func removeFromGroup(_ group: PBXGroup) -> Bool {
                let children = group.children
                if let index = children.firstIndex(where: { element in
                    if let fileRef = element as? PBXFileReference {
                        return fileRef.path == filePath || fileRef.name == fileName || fileRef.path == fileName
                    }
                    return false
                }) {
                    group.children.remove(at: index)
                    return true
                }
                
                // Recursively check child groups
                for child in children {
                    if let childGroup = child as? PBXGroup {
                        if removeFromGroup(childGroup) {
                            return true
                        }
                    }
                }
                return false
            }
            
            if let project = xcodeproj.pbxproj.rootObject,
               let mainGroup = project.mainGroup {
                if removeFromGroup(mainGroup) {
                    fileRemoved = true
                }
            }
            
            if fileRemoved {
                try xcodeproj.write(path: Path(projectURL.path))
                
                // Optionally remove from disk
                if removeFromDisk {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        try FileManager.default.removeItem(at: fileURL)
                        print("Successfully removed \(fileName) from project and disk. Removed from targets: \(removedFromTargets.joined(separator: ", "))")
                    } else {
                        print("Successfully removed \(fileName) from project. Removed from targets: \(removedFromTargets.joined(separator: ", ")). File not found on disk.")
                    }
                } else {
                    print("Successfully removed \(fileName) from project. Removed from targets: \(removedFromTargets.joined(separator: ", "))")
                }
            } else {
                print("File not found in project: \(fileName)")
            }
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}