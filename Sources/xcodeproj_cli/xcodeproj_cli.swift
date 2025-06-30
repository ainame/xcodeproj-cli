import ArgumentParser

@main
struct XcodeprojCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "xcodeproj",
        abstract: "A tool for manipulating Xcode project files",
        version: "1.0.0",
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
            SetBuildSettingCommand.self
        ]
    )
}
