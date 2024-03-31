import FluentKit


struct CreateSubscriptionStatusesTable: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("subscription_statuses")
            .id()
            .field("subscription_id", .uuid, .required, .references("subscriptions", "id"))
            .field("status", .string, .required)
            .field("lease_seconds", .int)
            .field("expired_at", .datetime)
            .field("created_at", .datetime, .required)
            .field("note", .string)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("subscription_statuses").delete()
    }
    
}
