import XCTest

import ComposableArchitecture

import Core

@MainActor
final class EngineTests: XCTestCase {
  func testAppendsStats() async {
    let now = Date()

    let store = TestStore(
      initialState: Engine.State(
        stats: [:],
        activity: .one,
        core: CoreState()
      ),
      reducer: Engine(
        activity: TestActivity(),
        nextActivity: { _, _ in .two }
      )
    ) {
      $0.date = DateGenerator { now }
    }

    await store.send(.core(.checkAnswer))

    let result = ActivityResult<TestActivityType>(
      activityType: .one,
      date: now,
      status: .correct
    )
    await store.receive(.delegate(type: .one, action: .storeResult("1", .correct))) {
      $0.stats["1"] = [result]
    }

    await store.receive(.delegate(type: .one, action: .activityWasCompleted)) {
      $0.activity = .two
    }
  }
}

private struct CoreState: Equatable {}

private struct TestActivity: ReducerProtocol {
  enum State: Equatable {
    case one
    case two

    var type: TestActivityType {
      switch self {
      case .one: return .one
      case .two: return .two
      }
    }

    var itemID: String {
      switch self {
      case .one: return "1"
      case .two: return "2"
      }
    }
  }

  enum CoreAction: Equatable {
    case checkAnswer
  }

  public typealias Action = ActivityContainerAction<TestActivityType, String, CoreAction>

  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .core(.checkAnswer):
        let type = state.type
        let itemID = state.itemID
        return .merge(
          .task {
            .delegate(type: type, action: .storeResult(itemID, .correct))
          },
          .task {
            .delegate(type: type, action: .activityWasCompleted)
          }
        )

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
