import FluentKit


struct CreateHubsTable: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("hubs")
            .id()
            .field("subscription_id", .uuid, .required, .references("subscriptions", "id"))
            .field("hub", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("hubs").delete()
    }
    
}
