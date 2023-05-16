import ComposableArchitecture

/// Create Activity by implementing inner reducers and pass it to |init|
/// and it will call use reducers according to activity lyfecycle.
public struct Activity<
  CheckActivity: ReducerProtocol,
  OtherActivity: ReducerProtocol,
  CheckCoreAction
>: ReducerProtocol where
CheckActivity.Action == CheckActivityAction<CheckCoreAction>,
CheckActivity.State: CheckActivityState {
  public enum State {
    case check(CheckActivity.State)
    case other(OtherActivity.State)
  }

  public enum Action {
    case check(CheckActivity.Action)
    case other(OtherActivity.Action)
  }

  public var checkActivity: CheckActivity
  public var otherActivity: OtherActivity

  public init(
    checkActivity: CheckActivity,
    otherActivity: OtherActivity
  ) {
    self.checkActivity = checkActivity
    self.otherActivity = otherActivity
  }

  public var body: some ReducerProtocol<State, Action> {
    EmptyReducer()
      .ifCaseLet(/State.check, action: /Action.check) { checkActivity }
      .ifCaseLet(/State.other, action: /Action.other) { otherActivity }
  }
}

extension Activity.State: Equatable
where CheckActivity.State: Equatable,
      OtherActivity.State: Equatable {}

extension Activity.Action: Equatable
where CheckActivity.Action: Equatable,
      OtherActivity.Action: Equatable {}
