/// Use this enum as |Action| implementation for checking activities.
///
/// |CoreAction| is user defined action set used to express custom activity flow.
public enum CheckActivityAction<CoreAction> {
  /// Use DelegateAction to communicate with learning Engine.
  public enum DelegateAction {
    case storeResult(ActivityResultStatus)
    case activityWasCompleted
  }
  
  case delegate(DelegateAction)

  // Custom logic of activity is declared here.
  case core(CoreAction)

  /// Sent by learning logic and expects to recieve delegate action back.
  case checkAnswer
}

/// Each checking activity state should conform to this protocol.
///
/// In future we should get rid of |ActivityType| and determine type of activity the other way.
public protocol CheckActivityState {
  associatedtype ActivityType

  var activityType: ActivityType { get }
}

extension CheckActivityAction.DelegateAction: Equatable {}
extension CheckActivityAction: Equatable where CoreAction: Equatable {}
