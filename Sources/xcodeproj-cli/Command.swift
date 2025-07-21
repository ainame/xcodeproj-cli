import ArgumentParser

@main
struct Command: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "xcodeproj",
        abstract: "A tool for manipulating Xcode project files",
        version: "0.2.1",
        subcommands: [
            CreateCommand.self,
            ListTargetsCommand.self,
            ListBuildConfigurationsCommand.self,
            ListFilesCommand.self,
            GetBuildSettingsCommand.self,
            AddFileCommand.self,
            RemoveFileCommand.self,
            MoveFileCommand.self,
            CreateGroupCommand.self,
            AddTargetCommand.self,
            RemoveTargetCommand.self,
            AddDependencyCommand.self,
            SetBuildSettingCommand.self,
            AddFrameworkCommand.self,
            ListSwiftPackagesCommand.self,
            AddSwiftPackageCommand.self,
            RemoveSwiftPackageCommand.self,
            AddBuildPhaseCommand.self,
            DuplicateTargetCommand.self
        ]
    )
}
