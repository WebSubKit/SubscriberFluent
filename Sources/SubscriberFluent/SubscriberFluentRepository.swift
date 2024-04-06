import Foundation
import FluentKit
import SubscriberKit


public protocol SubscriberFluentRepository: SubscriptionRepository {
    
    var fluentDatabase: Database { get }
    
}


extension SubscriberFluentRepository {
    
    public func store(
        callback: URL,
        topic: URL,
        hubs: [URL],
        leaseSeconds: Int?
    ) async throws -> Subscription {
        let created = SubscriptionModel(
            topic: topic.absoluteString,
            callback: callback.absoluteString
        )
        try await created.save(on: fluentDatabase)
        for hub in hubs {
            let hub = try HubModel(
                subscription: created,
                hub: hub.absoluteString
            )
            try await hub.save(on: fluentDatabase)
        }
        return try await findSubscription(callback: callback)
    }
    
    public func mark(
        _ subscription: Subscription,
        as mark: SubscriptionMark
    ) async throws {
        if let subscription = subscription as? SubscriptionModel {
            try await marking(subscription, as: mark)
            return
        }
        try await marking(
            findSubscription(callback: subscription.callback),
            as: mark
        )
    }
    
    public func subscription(for callback: URL) async throws -> Subscription {
        return try await findSubscription(callback: callback)
    }
    
    public func subscriptions(for topic: URL) async throws -> [Subscription] {
        return try await findSubscriptions(topic: topic)
    }
    
    public func subscriptions() async throws -> [Subscription] {
        return try await findAllSubscriptions()
    }
    
}


extension SubscriberFluentRepository {
    
    fileprivate func marking(
        _ subscription: SubscriptionModel,
        as mark: SubscriptionMark
    ) async throws {
        let status = try SubscriptionStatusModel(
            subscription: subscription,
            status: mark.value
        )
        if case .pendingSubscription(let request) = mark {
            if let leaseSeconds = request.leaseSeconds {
                status.rLeaseSeconds = leaseSeconds
            }
        }
        if case .subscribed(let verify) = mark {
            try await SubscriptionStatusModel.query(on: fluentDatabase)
                .filter(\.$rSubscription.$id, .equal, subscription.id!)
                .filter(\.$rStatus, .equal, SubscriptionStatusValue.pendingSubscription.rawValue)
                .delete()
            if let leaseSeconds = verify.leaseSeconds {
                status.rLeaseSeconds = leaseSeconds
                status.rExpiredAt = Date().addingTimeInterval(Double(leaseSeconds))
            }
        }
        if case .unsubscribed = mark {
            try await SubscriptionStatusModel.query(on: fluentDatabase)
                .filter(\.$rSubscription.$id, .equal, subscription.id!)
                .filter(\.$rStatus, .equal, SubscriptionStatusValue.pendingUnSubscription.rawValue)
                .delete()
        }
        if case .denied(let denial) = mark {
            status.rNote = denial.reason
        }
        try await status.save(on: fluentDatabase)
    }
    
    fileprivate func findSubscription(callback: URL) async throws -> SubscriptionModel {
        guard let result = try await findSubscription(callbackURLString: callback.absoluteString) else {
            throw SubscriberError.subscriptionNotFoundForCallback(callback)
        }
        return result
    }
    
    fileprivate func findSubscription(callbackURLString: String) async throws -> SubscriptionModel? {
        return try await SubscriptionModel.query(on: fluentDatabase)
            .with(\.$rHubs)
            .with(\.$rStatuses)
            .filter(\.$rCallback, .equal, callbackURLString)
            .first()
    }
    
    fileprivate func findSubscriptions(topic: URL) async throws -> [SubscriptionModel] {
        return try await findSubscriptions(topicURLString: topic.absoluteString)
    }
    
    fileprivate func findSubscriptions(topicURLString: String) async throws -> [SubscriptionModel] {
        return try await SubscriptionModel.query(on: fluentDatabase)
            .with(\.$rHubs)
            .with(\.$rStatuses)
            .filter(\.$rTopic, .equal, topicURLString)
            .all()
    }
    
    fileprivate func findAllSubscriptions() async throws -> [SubscriptionModel] {
        return try await SubscriptionModel.query(on: fluentDatabase)
            .with(\.$rHubs)
            .with(\.$rStatuses)
            .all()
    }
    
}


extension SubscriptionMark {
    
    var value: SubscriptionStatusValue {
        switch self {
        case .pendingSubscription:
            return .pendingSubscription
        case .pendingUnsubscription:
            return .pendingUnSubscription
        case .subscribed:
            return .subscribed
        case .unsubscribed:
            return .unsubscribed
        case .denied:
            return .denied
        }
    }
    
}
