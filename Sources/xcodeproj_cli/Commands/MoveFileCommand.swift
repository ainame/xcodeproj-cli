import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct MoveFileCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "move-file",
        abstract: "Move or rename a file within the project"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Current path of the file to move")
    var oldPath: String
    
    @Argument(help: "New path for the file")
    var newPath: String
    
    @Flag(name: .long, help: "Also move the file on disk")
    var moveOnDisk = false
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            // Resolve and validate the old and new file paths
            let oldFileURL = URL(fileURLWithPath: oldPath)
            let newFileURL = URL(fileURLWithPath: newPath)
            
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            let oldFileName = oldFileURL.lastPathComponent
            let newFileName = newFileURL.lastPathComponent
            
            var fileMoved = false
            
            // Find and update file references
            for fileRef in xcodeproj.pbxproj.fileReferences {
                if fileRef.path == oldPath || fileRef.name == oldFileName || fileRef.path == oldFileName {
                    // Update the file reference
                    fileRef.path = newPath
                    fileRef.name = newFileName
                    fileMoved = true
                }
            }
            
            if fileMoved {
                try xcodeproj.write(path: Path(projectURL.path))
                
                // Optionally move on disk
                if moveOnDisk {
                    // Create parent directory if needed
                    let newParentDir = newFileURL.deletingLastPathComponent()
                    if !FileManager.default.fileExists(atPath: newParentDir.path) {
                        try FileManager.default.createDirectory(
                            at: newParentDir, withIntermediateDirectories: true)
                    }
                    
                    // Move the file
                    if FileManager.default.fileExists(atPath: oldFileURL.path) {
                        try FileManager.default.moveItem(at: oldFileURL, to: newFileURL)
                        print("Successfully moved \(oldFileName) to \(newPath) on disk and in project")
                    } else {
                        print("Successfully moved \(oldFileName) to \(newPath) in project. File not found on disk.")
                    }
                } else {
                    print("Successfully moved \(oldFileName) to \(newPath) in project")
                }
            } else {
                print("File not found in project: \(oldFileName)")
            }
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}