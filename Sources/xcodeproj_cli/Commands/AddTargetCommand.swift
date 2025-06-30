import ArgumentParser
import Foundation
import XcodeProj
import PathKit

struct AddTargetCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add-target",
        abstract: "Create a new target"
    )
    
    @Argument(help: "Path to the .xcodeproj file")
    var projectPath: String
    
    @Argument(help: "Name of the target to create")
    var targetName: String
    
    @Argument(help: "Product type (app, framework, staticLibrary, etc.)")
    var productType: String
    
    @Argument(help: "Bundle identifier for the target")
    var bundleIdentifier: String
    
    @Option(name: .long, help: "Platform (iOS, macOS, tvOS, watchOS) - defaults to iOS")
    var platform: String = "iOS"
    
    @Option(name: .long, help: "Deployment target version")
    var deploymentTarget: String?
    
    mutating func run() throws {
        do {
            // Resolve and validate the project path
            let projectURL = URL(fileURLWithPath: projectPath)
            
            let xcodeproj = try XcodeProj(path: Path(projectURL.path))
            
            // Check if target already exists
            if xcodeproj.pbxproj.nativeTargets.contains(where: { $0.name == targetName }) {
                print("Target '\(targetName)' already exists in project")
                return
            }
            
            // Map product type string to PBXProductType
            let pbxProductType: PBXProductType
            switch productType.lowercased() {
            case "application", "app":
                pbxProductType = .application
            case "framework":
                pbxProductType = .framework
            case "staticframework", "static_framework":
                pbxProductType = .staticFramework
            case "staticlibrary", "static_library":
                pbxProductType = .staticLibrary
            case "dynamiclibrary", "dynamic_library":
                pbxProductType = .dynamicLibrary
            case "bundle":
                pbxProductType = .bundle
            case "unittestbundle", "unit_test_bundle":
                pbxProductType = .unitTestBundle
            case "uitestbundle", "ui_test_bundle":
                pbxProductType = .uiTestBundle
            case "appextension", "app_extension":
                pbxProductType = .appExtension
            case "commandlinetool", "command_line_tool":
                pbxProductType = .commandLineTool
            default:
                throw ValidationError.invalidParams("Invalid product type: \(productType). Supported: app, framework, staticLibrary, dynamicLibrary, bundle, unitTestBundle, uiTestBundle, appExtension, commandLineTool")
            }
            
            // Create build configurations for target
            let targetDebugConfig = XCBuildConfiguration(
                name: "Debug",
                buildSettings: [
                    "PRODUCT_NAME": targetName,
                    "PRODUCT_BUNDLE_IDENTIFIER": bundleIdentifier,
                    "SWIFT_VERSION": "5.0",
                    "TARGETED_DEVICE_FAMILY": platform == "iOS" ? "1,2" : "1",
                ])
            
            let targetReleaseConfig = XCBuildConfiguration(
                name: "Release",
                buildSettings: [
                    "PRODUCT_NAME": targetName,
                    "PRODUCT_BUNDLE_IDENTIFIER": bundleIdentifier,
                    "SWIFT_VERSION": "5.0",
                    "TARGETED_DEVICE_FAMILY": platform == "iOS" ? "1,2" : "1",
                ])
            
            // Add deployment target if specified
            if let deploymentTarget = deploymentTarget {
                let deploymentKey: String
                switch platform.lowercased() {
                case "ios":
                    deploymentKey = "IPHONEOS_DEPLOYMENT_TARGET"
                case "macos":
                    deploymentKey = "MACOSX_DEPLOYMENT_TARGET"
                case "tvos":
                    deploymentKey = "TVOS_DEPLOYMENT_TARGET"
                case "watchos":
                    deploymentKey = "WATCHOS_DEPLOYMENT_TARGET"
                default:
                    deploymentKey = "IPHONEOS_DEPLOYMENT_TARGET"
                }
                targetDebugConfig.buildSettings[deploymentKey] = deploymentTarget
                targetReleaseConfig.buildSettings[deploymentKey] = deploymentTarget
            }
            
            xcodeproj.pbxproj.add(object: targetDebugConfig)
            xcodeproj.pbxproj.add(object: targetReleaseConfig)
            
            // Create target configuration list
            let targetConfigurationList = XCConfigurationList(
                buildConfigurations: [targetDebugConfig, targetReleaseConfig],
                defaultConfigurationName: "Release"
            )
            xcodeproj.pbxproj.add(object: targetConfigurationList)
            
            // Create build phases
            let sourcesBuildPhase = PBXSourcesBuildPhase()
            xcodeproj.pbxproj.add(object: sourcesBuildPhase)
            
            let resourcesBuildPhase = PBXResourcesBuildPhase()
            xcodeproj.pbxproj.add(object: resourcesBuildPhase)
            
            let frameworksBuildPhase = PBXFrameworksBuildPhase()
            xcodeproj.pbxproj.add(object: frameworksBuildPhase)
            
            // Create target
            let target = PBXNativeTarget(
                name: targetName,
                buildConfigurationList: targetConfigurationList,
                buildPhases: [sourcesBuildPhase, frameworksBuildPhase, resourcesBuildPhase],
                productType: pbxProductType
            )
            target.productName = targetName
            xcodeproj.pbxproj.add(object: target)
            
            // Add target to project
            if let project = xcodeproj.pbxproj.rootObject {
                project.targets.append(target)
            }
            
            // Create target folder in main group
            if let project = try xcodeproj.pbxproj.rootProject(),
               let mainGroup = project.mainGroup {
                let targetGroup = PBXGroup(sourceTree: .group, name: targetName)
                xcodeproj.pbxproj.add(object: targetGroup)
                mainGroup.children.append(targetGroup)
            }
            
            // Save project
            try xcodeproj.write(path: Path(projectURL.path))
            
            print("Successfully created target '\(targetName)' with product type '\(productType)' and bundle identifier '\(bundleIdentifier)'")
            
        } catch {
            print("Error: \(error.localizedDescription)", to: &standardError)
            throw ExitCode.failure
        }
    }
}