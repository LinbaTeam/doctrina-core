import ComposableArchitecture

/// Use this as action for activity reducer.
///
/// ```swift
/// public struct Activity: ReducerProtocol {
///   public enum CoreAction: Equatable {
///     case activity1(Activity1.Action)
///     case activity2(Activity2.Action)
///   }
///
///   public typealias Action = ActivityContainerAction<ActivityType, ItemID, CoreAction>
///
///   public enum State {
///     case activity1(Activity1.State)
///     case activity2(Activity2.State)
///   }
///
///   public var body: some ReducerProtocol<State, Action> {
///     Reduce { state, action
///       switch action {
///         case let .core(action):
///           case let .activity1(.delegate(action)):
///             return .task { .delegate(type: .activity1, itemID: itemID, action: action) }
///
///           case let .activity2(.delegate(action)):
///             return .task { .delegate(type: .activity2, itemID: itemID, action: action) }
///
///           case .activity1,
///                .activity2:
///             return .none
///
///         case .delegate:
///           return .none
///         }
///       }
///     }
///   }
/// }
/// ```
///
/// In future there should be a way to ged rid of boilerplate inside body property.
@CasePathable
public enum ActivityContainerAction<ActivityType, ItemID: Hashable, CoreAction> {
  case core(CoreAction)
  case delegate(type: ActivityType, action: CheckActivityDelegateAction<ItemID>)
}

extension ActivityContainerAction: Equatable where ActivityType: Equatable, CoreAction: Equatable {}
