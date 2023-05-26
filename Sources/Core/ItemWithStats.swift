/// A Pair of primary learning item and its stats.
public struct ItemWithStats<Item, ActivityType> {
  /// Activity completion statistics. Could be used to track user's progress in learning.
  public typealias Stats = [ActivityResult<ActivityType>]

  /// Primary learning item
  public var item: Item

  /// Item's stats
  public var stats: Stats

  public init(item: Item, stats: Stats) {
    self.item = item
    self.stats = stats
  }
}

extension ItemWithStats: Identifiable where Item: Identifiable {
  public var id: Item.ID { item.id }
}

extension ItemWithStats: Decodable where Item: Decodable, ActivityType: Decodable {}
extension ItemWithStats: Encodable where Item: Encodable, ActivityType: Encodable {}
extension ItemWithStats: Equatable where ActivityType: Equatable, Item: Equatable {}
