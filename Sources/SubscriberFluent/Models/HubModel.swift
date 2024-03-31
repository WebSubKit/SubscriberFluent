import FluentKit
import Foundation


final class HubModel: Model {
    
    static let schema = "hubs"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "subscription_id")
    var rSubscription: SubscriptionModel
    
    @Field(key: "hub")
    var rHub: String
    
    required init() { }
    
    init(
        subscription: SubscriptionModel,
        hub: String
    ) throws {
        self.$rSubscription.id = try subscription.requireID()
        self.rHub = hub
    }
    
}
