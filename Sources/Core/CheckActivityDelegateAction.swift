/// Add this action as delegate action in your activites.
///
/// ```swift
/// public struct MyActivity: ReducerProtocol {
///   public enum Action: Equatable {
///     case ...
///     case delegate(CheckActivityDelegateAction<ItemID>)
///   }
/// }
/// ```
public enum CheckActivityDelegateAction<ItemID: Hashable> {
  case storeResult(ItemID, ActivityResultStatus)
  case activityWasCompleted(Analytics.Event.Parameters)
}

extension CheckActivityDelegateAction: Equatable {}
