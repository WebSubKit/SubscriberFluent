import FluentKit
import Foundation
import SubscriberKit


final class SubscriptionModel: Model {
    
    static let schema = "subscriptions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "topic")
    var rTopic: String
    
    @Children(for: \.$rSubscription)
    var rHubs: [HubModel]
    
    @Children(for: \.$rSubscription)
    var rStatuses: [SubscriptionStatusModel]
    
    @Field(key: "callback")
    var rCallback: String
    
    @Field(key: "created_at")
    var rCreatedAt: Date
    
    @Field(key: "updated_at")
    var rUpdatedAt: Date?
    
    required init() { }
    
    init(
        topic: String,
        callback: String
    ) {
        self.rTopic = topic
        self.rCallback = callback
        self.rCreatedAt = Date()
    }
    
}


extension SubscriptionModel: Subscription {
    
    var callback: URL { try! rCallback.convertToURL() }
    
    var topic: URL { try! rTopic.convertToURL() }
    
    var hubs: [URL] {
        return ($rHubs.value ?? []).map { item in
            try! item.rHub.convertToURL()
        }
    }
    
    var isPendingSubscription: Bool {
        return ($rStatuses.value ?? []).first {
            $0.rStatus == SubscriptionStatusValue.pendingSubscription.rawValue
        } != nil
    }
    
    var isPendingUnsubscription: Bool {
        return ($rStatuses.value ?? []).first {
            $0.rStatus == SubscriptionStatusValue.pendingUnSubscription.rawValue
        } != nil
    }
    
    var isActive: Bool {
        guard let active = $rStatuses.value?.filter({
            $0.rStatus == SubscriptionStatusValue.subscribed.rawValue
        }).sorted(by: {
            $0.rCreatedAt.compare($1.rCreatedAt) == .orderedDescending
        }).first else {
            return false
        }
        guard let expiredTime = active.rExpiredAt else {
            return true
        }
        return expiredTime > Date()
    }
    
}
