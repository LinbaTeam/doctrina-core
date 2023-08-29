import XCTest

import ComposableArchitecture
import CustomDump

import Core

@MainActor
final class EngineTests: XCTestCase {
  func testAppendsStats() async {
    var anylticsEvents: [Analytics.Event] = []
    let now = Date()

    typealias TestEngine = Engine<
      TestActivity,
      TestActivityType,
      TestActivity.CoreAction,
      CoreState,
      TestItem
    >

    let store = TestStoreOf<TestEngine>(
      initialState: TestEngine.State(
        itemsWithStats: [
          .init(item: TestItem(id: "1"), stats: []),
        ],
        activity: .one,
        core: CoreState()
      )
    ) {
      TestEngine(
        activity: TestActivity(),
        nextActivity: { _, _ in .two }
      )
    } withDependencies: {
      $0.analytics = Analytics { anylticsEvents.append($0) }
      $0.date = .constant(now)
    }

    await store.send(.core(.checkAnswer))

    let result = ActivityResult<TestActivityType>(
      activityType: .one,
      date: now,
      status: .correct
    )
    await store.receive(.delegate(type: .one, action: .storeResult("1", .correct))) {
      $0.itemsWithStats[id: "1"]?.stats = [result]
    }

    await store.receive(.delegate(type: .one, action: .activityWasCompleted([:]))) {
      $0.activity = .two
    }

    XCTAssertNoDifference(anylticsEvents, [
      Analytics.Event(
        name: "ACTIVITY_ANSWER_GIVEN",
        parameters: [
            "answer": "correct",
            "item": "1",
            "type": "one"
          ]
      ),
      .init(
        name: "ACTIVITY_COMPLETED",
        parameters: ["type": "one"]
      ),
    ])
  }
}

private struct CoreState: Equatable {}

private struct TestItem: Equatable, Identifiable, ActivityItem {
  var id: String
  var analyticsDescription: String { id }
}

private struct TestActivity: Reducer {
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

  var body: some ReducerOf<TestActivity> {
    Reduce { state, action in
      switch action {
      case .core(.checkAnswer):
        let type = state.type
        let itemID = state.itemID
        return .run { send in
          await send(.delegate(type: type, action: .storeResult(itemID, .correct)))
          await send(.delegate(type: type, action: .activityWasCompleted([:])))
        }

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
