import FluentKit
import Foundation


final class SubscriptionStatusModel: Model {
    
    static var schema: String = "subscription_statuses"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "subscription_id")
    var rSubscription: SubscriptionModel
    
    @Field(key: "status")
    var rStatus: String
    
    @Field(key: "lease_seconds")
    var rLeaseSeconds: Int?
    
    @Field(key: "expired_at")
    var rExpiredAt: Date?
    
    @Field(key: "created_at")
    var rCreatedAt: Date
    
    @Field(key: "note")
    var rNote: String?
    
    required init() { }
    
    init(
        subscription: SubscriptionModel,
        status: SubscriptionStatusValue
    ) throws {
        self.$rSubscription.id = try subscription.requireID()
        self.rStatus = status.rawValue
        self.rCreatedAt = Date()
    }
    
}


enum SubscriptionStatusValue: String {
    
    case pendingSubscription
    
    case pendingUnSubscription
    
    case subscribed
    
    case unsubscribed
    
    case expired
    
    case denied
    
}
