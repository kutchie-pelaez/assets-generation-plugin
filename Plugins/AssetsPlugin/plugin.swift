import PackagePlugin

@main struct AssetsPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else {
            return []
        }

        return try target
            .sourceFiles(withSuffix: "xcassets")
            .map { try buildCommand(for: $0, context: context) }
    }

    private func buildCommand(for assetCatalogFile: File, context: PluginContext) throws -> Command {
        let assetCatalogFilePath = assetCatalogFile.path
        let assetCatalogFileName = assetCatalogFilePath.lastComponent
        let generatedFileName = assetCatalogFilePath.stem + ".swift"
        let generatedFilePath = context.pluginWorkDirectory.appending(generatedFileName)
        let executablePath = try context.tool(named: "AssetsPluginTool").path

        return .buildCommand(
            displayName: "Generating \(generatedFileName) for \(assetCatalogFileName)",
            executable: executablePath,
            arguments: [assetCatalogFilePath, generatedFilePath],
            inputFiles: [assetCatalogFilePath],
            outputFiles: [generatedFilePath]
        )
    }
}
