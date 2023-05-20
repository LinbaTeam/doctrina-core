import Foundation

/// Status of completed activity is binary by now.
///
/// In the future we should extend it to contain intermediate states.
/// Consider the following example:
/// User was asked to combine the sentence using words. The answer given almost matches
/// the required sentence, but contains some small mistake. Should we mark the result as
/// wrong or should we mark it as correct with minor inaccuracy?
public enum ActivityResultStatus {
  case correct
  case wrong
}

/// An activity result represents the status of completed activity.
/// It can be stored persistantly to collect information about user's progress in studying.
///
/// init is available only from internals.
/// Consumers should not instanciate ActivityResult theirselfs.
public struct ActivityResult<ActivityType> {
  /// Type of activity user completed.
  /// |ActivityType| is intended to be an enum covering all possible activites in the application.
  public var activityType: ActivityType

  /// Date when the activity was completed.
  public var date: Date

  /// Status of completed activity.
  public var status: ActivityResultStatus

  public init(activityType: ActivityType, date: Date, status: ActivityResultStatus) {
    self.activityType = activityType
    self.date = date
    self.status = status
  }
}

extension ActivityResultStatus: Equatable {}
extension ActivityResultStatus: Codable {}

extension ActivityResult: Equatable where ActivityType: Equatable {}
extension ActivityResult: Decodable where ActivityType: Decodable {}
extension ActivityResult: Encodable where ActivityType: Encodable {}
