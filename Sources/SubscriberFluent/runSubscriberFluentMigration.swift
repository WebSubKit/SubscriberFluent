import FluentKit


public func runSubscriberFluentMigration(on migrations: Migrations) {
    migrations.add(CreateSubscriptionsTable())
    migrations.add(CreateHubsTable())
    migrations.add(CreateSubscriptionStatusesTable())
}
