import PackagePlugin

protocol SwiftGenTarget {
  var name: String { get }
  var moduleName: String { get }
  var directory: Path? { get }
}

extension Target where Self: SwiftGenTarget {}
