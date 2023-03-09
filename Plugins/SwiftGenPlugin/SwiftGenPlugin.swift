import Foundation
import PackagePlugin

@main
struct SwiftGenPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
    try createBuildCommands(for: .package(context, target))
  }

  func createBuildCommands(for build: Build) throws -> [Command] {
    let fileManager = FileManager.default

    // Validate paths list
    guard build.hasConfig() else  {
      return []
    }
    // Clear the SwiftGen plugin's directory (in case of dangling files)
    fileManager.forceClean(directory: build.context.pluginWorkDirectory)
    return try build.commands()
  }
}

private extension FileManager {
  /// Re-create the given directory
  func forceClean(directory: Path) {
    try? removeItem(atPath: directory.string)
    try? createDirectory(atPath: directory.string, withIntermediateDirectories: false)
  }
}

extension Target {
  /// Try to access the underlying `moduleName` property
  /// Falls back to target's name
  var moduleName: String {
    switch self {
    case let target as SourceModuleTarget:
      return target.moduleName
    default:
      return ""
    }
  }
}
