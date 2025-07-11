import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct CreateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new Xcode project file (.xcodeproj)"
    )
    
    @Argument(help: "Name of the project to create")
    var projectName: String
    
    @Option(name: .long, help: "Path where the project should be created (defaults to current directory)")
    var path: String = "."
    
    @Option(name: .long, help: "Organization name for the project")
    var organizationName: String = ""
    
    @Option(name: .long, help: "Bundle identifier prefix (defaults to com.example)")
    var bundleIdentifier: String = "com.example"
    
    mutating func run() throws {
        do {
            // Resolve and validate the path
            let projectPath = Path(path) + "\(projectName).xcodeproj"
            
            // Create the .pbxproj file using XcodeProj
            let pbxproj = PBXProj()
            
            // Create project groups
            let mainGroup = PBXGroup(sourceTree: .group)
            pbxproj.add(object: mainGroup)
            let productsGroup = PBXGroup(children: [], sourceTree: .group, name: "Products")
            pbxproj.add(object: productsGroup)
            
            // Create project build configurations
            let debugConfig = XCBuildConfiguration(
                name: "Debug",
                buildSettings: [
                    "ORGANIZATION_NAME": organizationName
                ])
            let releaseConfig = XCBuildConfiguration(
                name: "Release",
                buildSettings: [
                    "ORGANIZATION_NAME": organizationName
                ])
            pbxproj.add(object: debugConfig)
            pbxproj.add(object: releaseConfig)
            
            // Create project configuration list
            let configurationList = XCConfigurationList(
                buildConfigurations: [debugConfig, releaseConfig],
                defaultConfigurationName: "Release"
            )
            pbxproj.add(object: configurationList)
            
            // Create target build configurations with bundle identifier
            let targetDebugConfig = XCBuildConfiguration(
                name: "Debug",
                buildSettings: [
                    "PRODUCT_BUNDLE_IDENTIFIER": "\(bundleIdentifier).\(projectName)",
                    "PRODUCT_NAME": "$(TARGET_NAME)",
                    "SWIFT_VERSION": "5.0",
                ])
            let targetReleaseConfig = XCBuildConfiguration(
                name: "Release",
                buildSettings: [
                    "PRODUCT_BUNDLE_IDENTIFIER": "\(bundleIdentifier).\(projectName)",
                    "PRODUCT_NAME": "$(TARGET_NAME)",
                    "SWIFT_VERSION": "5.0",
                ])
            pbxproj.add(object: targetDebugConfig)
            pbxproj.add(object: targetReleaseConfig)
            
            // Create target configuration list
            let targetConfigurationList = XCConfigurationList(
                buildConfigurations: [targetDebugConfig, targetReleaseConfig],
                defaultConfigurationName: "Release"
            )
            pbxproj.add(object: targetConfigurationList)
            
            // Create product reference for the app target
            let productReference = PBXFileReference(
                sourceTree: .buildProductsDir,
                name: "\(projectName).app",
                explicitFileType: "wrapper.application"
            )
            pbxproj.add(object: productReference)
            productsGroup.children.append(productReference)
            
            // Create build phases
            let sourcesBuildPhase = PBXSourcesBuildPhase(files: [])
            pbxproj.add(object: sourcesBuildPhase)
            
            let frameworksBuildPhase = PBXFrameworksBuildPhase(files: [])
            pbxproj.add(object: frameworksBuildPhase)
            
            let resourcesBuildPhase = PBXResourcesBuildPhase(files: [])
            pbxproj.add(object: resourcesBuildPhase)
            
            // Create app target with bundle identifier
            let appTarget = PBXNativeTarget(
                name: projectName,
                buildConfigurationList: targetConfigurationList,
                buildPhases: [sourcesBuildPhase, frameworksBuildPhase, resourcesBuildPhase],
                productName: projectName,
                productType: .application
            )
            appTarget.product = productReference
            pbxproj.add(object: appTarget)
            
            // Create project
            let project = PBXProject(
                name: projectName,
                buildConfigurationList: configurationList,
                compatibilityVersion: "Xcode 14.0",
                preferredProjectObjectVersion: 56,
                minimizedProjectReferenceProxies: 0,
                mainGroup: mainGroup,
                developmentRegion: "en",
                knownRegions: ["en", "Base"],
                productsGroup: productsGroup,
                targets: [appTarget]
            )
            pbxproj.add(object: project)
            pbxproj.rootObject = project
            
            // Create workspace
            let workspaceData = XCWorkspaceData(children: [])
            let workspace = XCWorkspace(data: workspaceData)
            
            // Create xcodeproj
            let xcodeproj = XcodeProj(workspace: workspace, pbxproj: pbxproj)
            
            // Write project
            try xcodeproj.write(path: projectPath)
            
            print("Successfully created Xcode project at: \(projectPath.string)")
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}