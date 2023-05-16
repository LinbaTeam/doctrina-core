import ComposableArchitecture

/// Engine of learning process. Manages activities, stores statistics and more.
public struct Engine<
  CheckActivity: ReducerProtocol,
  OtherActivity: ReducerProtocol,
  CheckCoreAction
>: ReducerProtocol where
CheckActivity.State: CheckActivityState,
CheckActivity.Action == CheckActivityAction<CheckCoreAction> {
  public typealias ResolvedActivity = Activity<
    CheckActivity, OtherActivity, CheckCoreAction
  >

  /// Implement this closure to provide continuous flow of activies.
  ///
  /// Note: For correct animations consider changing activity type each type closure is called.
  public typealias NextActivity = () -> ResolvedActivity.State

  public struct State {
    public var stats: [ActivityResult<CheckActivity.State.ActivityType>]
    public var activity: ResolvedActivity.State

    public init(
      stats: [ActivityResult<CheckActivity.State.ActivityType>],
      activity: ResolvedActivity.State
    ) {
      self.stats = stats
      self.activity = activity
    }
  }

  public typealias Action = ResolvedActivity.Action

  public var activity: ResolvedActivity
  public var nextActivity: NextActivity

  @Dependency(\.date) var now

  public init(
    activity: ResolvedActivity,
    nextActivity: @escaping NextActivity
  ) {
    self.activity = activity
    self.nextActivity = nextActivity
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { [nextActivity, now] state, action in
      switch action {
      case let .check(action):
        switch action {
        case let .delegate(action):
          switch action {
          case let .storeResult(status):
            guard case let .check(activity) = state.activity else {
              // TODO: Add asserts on invalid state.
              return .none
            }
            let result = ActivityResult(
              activityType: activity.activityType,
              date: now(),
              status: status
            )
            state.stats.append(result)
            return .none

          case .activityWasCompleted:
            state.activity = nextActivity()
            return .none
          }

        default:
          return .none
        }

      case .other:
        // Other activity actions are managed by library's clients and are ignored by engine.
        return .none
      }
    }
    Scope(state: \.activity, action: /Action.self, child: { activity })
  }
}

extension Engine.State: Equatable
where CheckActivity.State: Equatable,
      CheckActivity.State.ActivityType: Equatable,
      OtherActivity.State: Equatable {}
