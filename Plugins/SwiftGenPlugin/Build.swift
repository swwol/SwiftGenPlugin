import Foundation
import PackagePlugin
#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
#endif

enum Build {
  case package(PluginContext, Target)
#if canImport(XcodeProjectPlugin)
  case xcode(XcodePluginContext,XcodeTarget)
#endif

  private var seearchPaths: [Path] {
    switch self {
    case let .package(context, target):
      return [context.package.directory, target.directory]
#if canImport(XcodeProjectPlugin)
    case let .xcode(context, _):
      return [context.xcodeProject.directory]
#endif
    }
  }

  var configurationPaths: [Path] {
    seearchPaths
      .map { $0.appending("swiftgen.yml") }
      .filter { FileManager.default.fileExists(atPath: $0.string) }
  }

  var targetName: String {
    switch self {
    case let .package(_, target):
      return target.name
#if canImport(XcodeProjectPlugin)
    case let .xcode(_, target):
      return target.displayName
#endif
    }
  }

  var targetModuleName: String {
    switch self {
    case let .package(_, target):
      return target.moduleName
#if canImport(XcodeProjectPlugin)
    case .xcode:
      return ""
#endif
    }
  }

  var expectedConfigLocation: String {
    switch self {
    case .package:
      return """
      include a `swiftgen.yml` in the target's source directory, or include a shared `swiftgen.yml` at the \
      package's root.
      """
#if canImport(XcodeProjectPlugin)
    case .xcode:
      return "include a shared `swiftgen.yml` at the root of the project directory"
#endif
    }
  }
  func hasConfig() -> Bool {
    guard !configurationPaths.isEmpty else {
      Diagnostics.error("""
      No SwiftGen configurations found for target \(targetName). If you would like to generate sources for this \
      target \(expectedConfigLocation)
      """ )
      return false
    }
    return true
  }

  var context: SwiftGenContext {
    switch self {
    case let .package(context, _):
      return context
#if canImport(XcodeProjectPlugin)
    case let .xcode(context, _):
      return context
#endif
    }
  }

  func commands() throws -> [Command] {
    return try configurationPaths.map { configuration in
      try Command.swiftgen(using: configuration, build: self)
    }
  }
}

private extension Command {
  static func swiftgen(using configuration: Path, build: Build) throws -> Command {
    .prebuildCommand(
      displayName: "SwiftGen BuildTool Plugin",
      executable: try build.context.tool(named: "swiftgen").path,
      arguments: [
        "config",
        "run",
        "--verbose",
        "--config", "\(configuration)"
      ],
      environment: [
        "PROJECT_DIR": build.context.root,
        "TARGET_NAME": build.targetName,
        "PRODUCT_MODULE_NAME": build.targetModuleName,
        "DERIVED_SOURCES_DIR": build.context.pluginWorkDirectory
      ],
      outputFilesDirectory: build.context.pluginWorkDirectory
    )
  }
}
