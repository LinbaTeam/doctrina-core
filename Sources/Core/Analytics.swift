import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

/// Dependency for tracking analytics events.
public struct Analytics {
  /// Analytics event. Could be supplied with parameters.
  ///
  /// Some event examples:
  /// ```swift
  /// let addButtonTapped = Event(name: "addButtonTapped")
  ///
  /// let startup = Event(
  ///   name: "startup",
  ///   parameters: [
  ///     "onboardingShown": true,
  ///     "notificationsGranted": false,
  ///   ]
  /// )
  /// ```
  public struct Event {
    /// Event name. Should be unique across application.
    public var name: String

    /// Optional parameters with some additional information.
    public var parameters: [String: String]?

    /// - Parameters
    ///  - name: unique event name
    ///  - parameters: optional parameters with some additional information.
    public init(
      name: String,
      parameters: [String: String]? = nil
    ) {
      self.name = name
      self.parameters = parameters
    }
  }

  /// Sends event to analytics tracker.
  public var report: (Event) -> Void

  /// Convenience method of sending event.
  public func callAsFunction(_ event: Event) {
    report(event)
  }

  public init(report: @escaping (Event) -> Void) {
    self.report = report
  }
}

extension Analytics: TestDependencyKey {
  public static let testValue = Analytics(
    report: unimplemented("\(Self.self).report")
  )
}

extension DependencyValues {
  public var analytics: Analytics {
    get { self[Analytics.self] }
    set { self[Analytics.self] = newValue }
  }
}

extension Analytics.Event: Equatable {}
