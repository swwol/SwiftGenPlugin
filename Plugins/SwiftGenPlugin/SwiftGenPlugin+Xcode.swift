#if canImport(XcodeProjectPlugin)
import PackagePlugin
import XcodeProjectPlugin
import Foundation

extension SwiftGenPlugin: XcodeBuildToolPlugin {
  func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
    try createBuildCommands(swiftGenContext: context, swiftGenTarget: target)
  }
}

extension XcodePluginContext: SwiftGenContext {
  var root: PackagePlugin.Path {
    xcodeProject.directory
  }
}

extension XcodeTarget: SwiftGenTarget {
  var name: String {
    displayName
  }

  var moduleName: String {
    return ""
  }

  var directory: Path? {
    nil
  }
}
#endif
