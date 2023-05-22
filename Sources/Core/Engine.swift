import ComposableArchitecture

/// Engine of learning process. Manages activities, stores statistics and more.
public struct Engine<
  Activity: ReducerProtocol,
  ActivityType,
  CoreAction,
  CoreState,
  ItemID: Hashable
>: ReducerProtocol where
Activity.Action == ActivityContainerAction<ActivityType, ItemID, CoreAction> {
  /// Implement this closure to provide continuous flow of activies.
  ///
  /// - Parameters
  ///  - State.Stats provides readonly stats to decide which activity is better.
  ///  - CoreState mutable core state in case activity changing needs to mark some flags.
  ///
  /// Note: For correct animations consider changing activity type each type closure is called.
  public typealias NextActivity = (
    State.Stats,
    inout CoreState
  ) -> Activity.State

  @dynamicMemberLookup
  public struct State {
    /// Activity completion statistics. Could be used to track user's progress in learning.
    public typealias Stats = [ItemID: [ActivityResult<ActivityType>]]

    public var stats: Stats
    public var activity: Activity.State

    /// Container to store additional state.
    ///
    /// Can be used when generating new activities.
    public var core: CoreState

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<CoreState, T>) -> T {
      get { core[keyPath: keyPath] }
      set { core[keyPath: keyPath] = newValue }
    }

    public init(
      stats: Stats,
      activity: Activity.State,
      core: CoreState
    ) {
      self.stats = stats
      self.activity = activity
      self.core = core
    }
  }

  public typealias Action = Activity.Action

  public var activity: Activity
  public var nextActivity: NextActivity

  @Dependency(\.date) var now

  public init(
    activity: Activity,
    nextActivity: @escaping NextActivity
  ) {
    self.activity = activity
    self.nextActivity = nextActivity
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { [nextActivity, now] state, action in
      switch action {
      case let .delegate(activityType, action):
        switch action {
        case let .storeResult(itemID, status):
          let result = ActivityResult(
            activityType: activityType,
            date: now(),
            status: status
          )
          state.stats[itemID, default: []].append(result)
          return .none

        case .activityWasCompleted:
          state.activity = nextActivity(state.stats, &state.core)
          return .none
        }

      case .core:
        return .none
      }
    }
    Scope(state: \.activity, action: /Action.self, child: { activity })
  }
}

extension Engine.State: Equatable where
Activity.State: Equatable,
ActivityType: Equatable,
CoreState: Equatable {}
