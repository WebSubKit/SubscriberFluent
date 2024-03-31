import FluentKit


struct CreateSubscriptionsTable: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("subscriptions")
            .id()
            .field("topic", .string, .required)
            .field("callback", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime)
            .unique(on: "callback")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("subscriptions").delete()
    }
    
}
