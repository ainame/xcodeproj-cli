import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct DuplicateTargetCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "duplicate-target",
        abstract: "Duplicate an existing target"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Name of the target to duplicate")
    var sourceTarget: String
    
    @Argument(help: "Name for the new target")
    var newTargetName: String
    
    @Option(name: .long, help: "Bundle identifier for the new target (optional)")
    var newBundleIdentifier: String?
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            // Find the source target
            guard let sourceTarget = xcodeproj.pbxproj.nativeTargets.first(where: { $0.name == sourceTarget }) else {
                print("Source target '\(sourceTarget)' not found in project")
                return
            }
            
            // Check if target with new name already exists
            if xcodeproj.pbxproj.nativeTargets.contains(where: { $0.name == newTargetName }) {
                print("Target '\(newTargetName)' already exists in project")
                return
            }
            
            // Duplicate build configuration list
            let newBuildConfigurations: [XCBuildConfiguration] = sourceTarget.buildConfigurationList?.buildConfigurations.map { sourceConfig in
                var newBuildSettings = sourceConfig.buildSettings
                
                // Update product name and bundle identifier
                newBuildSettings["PRODUCT_NAME"] = newTargetName
                if let newBundleIdentifier = newBundleIdentifier {
                    newBuildSettings["BUNDLE_IDENTIFIER"] = newBundleIdentifier
                }
                
                // Update info plist if it references the target name
                if let infoPlist = newBuildSettings["INFOPLIST_FILE"] as? String,
                   infoPlist.contains(sourceTarget.name) {
                    let newInfoPlist = infoPlist.replacingOccurrences(of: sourceTarget.name, with: newTargetName)
                    newBuildSettings["INFOPLIST_FILE"] = newInfoPlist
                }
                
                let newConfig = XCBuildConfiguration(name: sourceConfig.name, buildSettings: newBuildSettings)
                xcodeproj.pbxproj.add(object: newConfig)
                return newConfig
            } ?? []
            
            let newConfigList = XCConfigurationList(
                buildConfigurations: newBuildConfigurations,
                defaultConfigurationName: sourceTarget.buildConfigurationList?.defaultConfigurationName ?? "Release"
            )
            xcodeproj.pbxproj.add(object: newConfigList)
            
            // Duplicate build phases
            let newBuildPhases: [PBXBuildPhase] = sourceTarget.buildPhases.compactMap { sourcePhase in
                if let sourcesPhase = sourcePhase as? PBXSourcesBuildPhase {
                    let newPhase = PBXSourcesBuildPhase(files: sourcesPhase.files ?? [])
                    xcodeproj.pbxproj.add(object: newPhase)
                    return newPhase
                } else if let resourcesPhase = sourcePhase as? PBXResourcesBuildPhase {
                    let newPhase = PBXResourcesBuildPhase(files: resourcesPhase.files ?? [])
                    xcodeproj.pbxproj.add(object: newPhase)
                    return newPhase
                } else if let frameworksPhase = sourcePhase as? PBXFrameworksBuildPhase {
                    let newPhase = PBXFrameworksBuildPhase(files: frameworksPhase.files ?? [])
                    xcodeproj.pbxproj.add(object: newPhase)
                    return newPhase
                } else if let shellScriptPhase = sourcePhase as? PBXShellScriptBuildPhase {
                    let newPhase = PBXShellScriptBuildPhase(
                        name: shellScriptPhase.name,
                        inputPaths: shellScriptPhase.inputPaths,
                        outputPaths: shellScriptPhase.outputPaths,
                        shellPath: shellScriptPhase.shellPath ?? "/bin/sh",
                        shellScript: shellScriptPhase.shellScript
                    )
                    xcodeproj.pbxproj.add(object: newPhase)
                    return newPhase
                } else if let copyFilesPhase = sourcePhase as? PBXCopyFilesBuildPhase {
                    let newPhase = PBXCopyFilesBuildPhase(
                        dstPath: copyFilesPhase.dstPath,
                        dstSubfolderSpec: copyFilesPhase.dstSubfolderSpec,
                        name: copyFilesPhase.name,
                        files: copyFilesPhase.files ?? []
                    )
                    xcodeproj.pbxproj.add(object: newPhase)
                    return newPhase
                }
                return nil
            }
            
            // Create new target
            let newTarget = PBXNativeTarget(
                name: newTargetName,
                buildConfigurationList: newConfigList,
                buildPhases: newBuildPhases,
                productType: sourceTarget.productType
            )
            newTarget.productName = newTargetName
            
            // Copy dependencies
            for sourceDependency in sourceTarget.dependencies {
                if let dependencyTarget = sourceDependency.target {
                    // Create new proxy
                    let newProxy = PBXContainerItemProxy(
                        containerPortal: .project(xcodeproj.pbxproj.rootObject!),
                        remoteGlobalID: .object(dependencyTarget),
                        proxyType: .nativeTarget,
                        remoteInfo: dependencyTarget.name
                    )
                    xcodeproj.pbxproj.add(object: newProxy)
                    
                    // Create new dependency
                    let newDependency = PBXTargetDependency(
                        name: sourceDependency.name,
                        target: dependencyTarget,
                        targetProxy: newProxy
                    )
                    xcodeproj.pbxproj.add(object: newDependency)
                    newTarget.dependencies.append(newDependency)
                }
            }
            
            xcodeproj.pbxproj.add(object: newTarget)
            
            // Add target to project
            if let project = xcodeproj.pbxproj.rootObject {
                project.targets.append(newTarget)
            }
            
            // Create target folder in main group
            if let project = try xcodeproj.pbxproj.rootProject(),
               let mainGroup = project.mainGroup {
                let targetGroup = PBXGroup(sourceTree: .group, name: newTargetName)
                xcodeproj.pbxproj.add(object: targetGroup)
                mainGroup.children.append(targetGroup)
            }
            
            // Save project
            try xcodeproj.write(path: Path(projectURL.path))
            
            let bundleIdText = newBundleIdentifier != nil ? " with bundle identifier '\(newBundleIdentifier!)'" : ""
            print("Successfully duplicated target '\(sourceTarget.name)' as '\(newTargetName)'\(bundleIdText)")
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}
