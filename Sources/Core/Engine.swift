import ComposableArchitecture

/// Engine of learning process. Manages activities, stores statistics and more.
@Reducer
public struct Engine<
  Activity: Reducer,
  ActivityType: Equatable,
  CoreAction: Equatable,
  CoreState: Equatable,
  Item: ActivityItem & Identifiable & Equatable
> where
Activity.Action == ActivityContainerAction<ActivityType, Item.ID, CoreAction>,
Activity.State: Equatable {
  public typealias ItemWithStatsArray = IdentifiedArrayOf<ItemWithStats<Item, ActivityType>>

  /// Implement this closure to provide continuous flow of activies.
  ///
  /// - Parameters
  ///  - State.Stats provides readonly stats to decide which activity is better.
  ///  - CoreState mutable core state in case activity changing needs to mark some flags.
  ///
  /// Note: For correct animations consider changing activity type each type closure is called.
  public typealias NextActivity = (ItemWithStatsArray, inout CoreState) -> Activity.State

  @dynamicMemberLookup
  @ObservableState
  public struct State: Equatable {
    public var itemsWithStats: ItemWithStatsArray
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
      itemsWithStats: ItemWithStatsArray,
      activity: Activity.State,
      core: CoreState
    ) {
      self.itemsWithStats = itemsWithStats
      self.activity = activity
      self.core = core
    }
  }

  public typealias Action = Activity.Action

  /// Current activity. Changes when currect activity sends |activityWasCompleted| action.
  /// New activity is gathered by calling |nextActivity| closure.
  public var activity: Activity

  /// A closure to deliver activities into the system.
  public var nextActivity: NextActivity

  @Dependency(\.date) var now
  @Dependency(\.analytics) var analytics

  public init(
    activity: Activity,
    nextActivity: @escaping NextActivity
  ) {
    self.activity = activity
    self.nextActivity = nextActivity
  }

  public var body: some ReducerOf<Engine> {
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
          state.itemsWithStats[id: itemID]?.stats.append(result)
          var eventParameters: [String: AnyHashable] = [
            "type": String(describing: activityType),
            "answer": String(describing: result.status),
          ]
          if let item = state.itemsWithStats[id: itemID]?.item {
            eventParameters["item"] = item.analyticsDescription
          }
          return .run { [analytics, eventParameters] _ in
            analytics(
              Analytics.Event(
                name: "ACTIVITY_ANSWER_GIVEN",
                parameters: eventParameters
              )
            )
          }

        case let .activityWasCompleted(eventParameters):
          state.activity = nextActivity(state.itemsWithStats, &state.core)
          var eventParameters = eventParameters
          eventParameters["type"] = String(describing: activityType)
          return .run { [analytics, eventParameters] _ in
            analytics(
              Analytics.Event(
                name: "ACTIVITY_COMPLETED",
                parameters: eventParameters
              )
            )
          }
        }

      case .core:
        return .none
      }
    }
    Scope(state: \.activity, action: \.self) { activity }
  }
}
