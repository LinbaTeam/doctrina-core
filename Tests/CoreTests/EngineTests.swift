import XCTest

import ComposableArchitecture

import Core

@MainActor
final class EngineTests: XCTestCase {
  func testAppendsStats() async {
    let now = Date()

    let store = TestStore(
      initialState: Engine.State(
        stats: [],
        activity: .check(TestActivity.State.one)
      ),
      reducer: Engine(
        activity: Activity(
          checkActivity: TestActivity(),
          otherActivity: EmptyReducer<Never, Never>()
        ),
        nextActivity: { .check(.two) }
      )
    ) {
      $0.date = DateGenerator { now }
    }

    await store.send(.check(.checkAnswer))

    let result = ActivityResult<TestActivityType>(
      activityType: .one,
      date: now,
      status: .correct
    )
    await store.receive(.check(.delegate(.storeResult(.correct)))) {
      $0.stats.append(result)
    }

    await store.receive(.check(.delegate(.activityWasCompleted))) {
      $0.activity = .check(.two)
    }
  }
}

private struct TestActivity: ReducerProtocol {
  enum State: Equatable, CheckActivityState {
    case one
    case two

    var activityType: TestActivityType {
      switch self {
      case .one: return .one
      case .two: return .two
      }
    }
  }

  enum CoreAction: Equatable {}

  typealias Action = CheckActivityAction<CoreAction>

  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .checkAnswer:
        return .merge(
          .task { .delegate(.storeResult(.correct)) },
          .task { .delegate(.activityWasCompleted) }
        )

      case .core:
        return .none

      case .delegate:
        return .none
      }
    }
  }
}

private enum TestActivityType: Equatable {
  case one
  case two
}
