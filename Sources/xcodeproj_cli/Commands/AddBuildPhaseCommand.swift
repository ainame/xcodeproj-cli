import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct AddBuildPhaseCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add-build-phase",
        abstract: "Add custom build phases",
        subcommands: [RunScriptCommand.self, CopyFilesCommand.self]
    )
    
    struct RunScriptCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "run-script",
            abstract: "Add a run script build phase"
        )
        
        @Argument(help: "Path to the .xcodeproj file")
        var projectPath: String
        
        @Argument(help: "Name of the target to add build phase to")
        var targetName: String
        
        @Argument(help: "Name of the build phase")
        var phaseName: String
        
        @Argument(help: "Script content")
        var script: String
        
        mutating func run() throws {
            try addBuildPhase(
                projectPath: projectPath,
                targetName: targetName,
                phaseName: phaseName,
                phaseType: "run_script",
                script: script
            )
        }
    }
    
    struct CopyFilesCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "copy-files",
            abstract: "Add a copy files build phase"
        )
        
        @Argument(help: "Path to the .xcodeproj file")
        var projectPath: String
        
        @Argument(help: "Name of the target to add build phase to")
        var targetName: String
        
        @Argument(help: "Name of the build phase")
        var phaseName: String
        
        @Argument(help: "Destination (resources, frameworks, executables, plugins, shared_support)")
        var destination: String
        
        @Option(name: .long, help: "Array of file paths to copy")
        var files: [String] = []
        
        mutating func run() throws {
            try addBuildPhase(
                projectPath: projectPath,
                targetName: targetName,
                phaseName: phaseName,
                phaseType: "copy_files",
                destination: destination,
                files: files
            )
        }
    }
}

private func addBuildPhase(
    projectPath: String,
    targetName: String,
    phaseName: String,
    phaseType: String,
    script: String? = nil,
    destination: String? = nil,
    files: [String] = []
) throws {
    do {
        // Resolve and validate the project path
        let projectURL = URL(fileURLWithPath: projectPath)
        
        let xcodeproj = try XcodeProj(path: Path(projectURL.path))
        
        // Find the target
        guard let target = xcodeproj.pbxproj.nativeTargets.first(where: { $0.name == targetName }) else {
            print("Target '\(targetName)' not found in project")
            return
        }
        
        switch phaseType.lowercased() {
        case "run_script":
            guard let script = script else {
                print("script is required for run_script phase", to: &standardError)
                throw ExitCode.failure
            }
            
            // Create shell script build phase
            let shellScriptPhase = PBXShellScriptBuildPhase(
                name: phaseName,
                shellScript: script
            )
            xcodeproj.pbxproj.add(object: shellScriptPhase)
            target.buildPhases.append(shellScriptPhase)
            
        case "copy_files":
            guard let destination = destination else {
                print("destination is required for copy_files phase", to: &standardError)
                throw ExitCode.failure
            }
            
            // Map destination string to enum
            let dstSubfolderSpec: PBXCopyFilesBuildPhase.SubFolder
            switch destination.lowercased() {
            case "resources":
                dstSubfolderSpec = .resources
            case "frameworks":
                dstSubfolderSpec = .frameworks
            case "executables":
                dstSubfolderSpec = .executables
            case "plugins":
                dstSubfolderSpec = .plugins
            case "shared_support":
                dstSubfolderSpec = .sharedSupport
            default:
                print("Invalid destination: \(destination). Must be one of: resources, frameworks, executables, plugins, shared_support", to: &standardError)
                throw ExitCode.failure
            }
            
            // Create copy files build phase
            let copyFilesPhase = PBXCopyFilesBuildPhase(
                dstPath: "",
                dstSubfolderSpec: dstSubfolderSpec,
                name: phaseName
            )
            xcodeproj.pbxproj.add(object: copyFilesPhase)
            
            // Add files if provided
            for filePath in files {
                let fileName = URL(fileURLWithPath: filePath).lastPathComponent
                if let fileRef = xcodeproj.pbxproj.fileReferences.first(where: {
                    $0.path == filePath || $0.name == fileName
                }) {
                    let buildFile = PBXBuildFile(file: fileRef)
                    xcodeproj.pbxproj.add(object: buildFile)
                    copyFilesPhase.files?.append(buildFile)
                }
            }
            
            target.buildPhases.append(copyFilesPhase)
            
        default:
            print("Invalid phase_type: \(phaseType). Must be one of: run_script, copy_files", to: &standardError)
            throw ExitCode.failure
        }
        
        // Save project
        try xcodeproj.write(path: Path(projectURL.path))
        
        print("Successfully added \(phaseType) build phase '\(phaseName)' to target '\(targetName)'")
        
    } catch {
        print("Error: \(error.localizedDescription)", to: &standardError)
        throw ExitCode.failure
    }
}
