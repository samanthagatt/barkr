import Vapor
import FluentSQLite

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    let dirConfig = DirectoryConfig.detect()
    services.register(dirConfig)
    
    try services.register(FluentSQLiteProvider())
    
    var dbConfig = DatabasesConfig()
    let db = try SQLiteDatabase(storage: .file(path: dirConfig.workDir +
        "barkr.db"))
    dbConfig.add(database: db, as: .sqlite)
    services.register(dbConfig)
    
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: User.self,
                        database: DatabaseIdentifier<User.Database>.sqlite)
    migrationConfig.add(model: Token.self,
                        database: DatabaseIdentifier<Token.Database>.sqlite)
    migrationConfig.add(model: Post.self,
                        database: DatabaseIdentifier<Post.Database>.sqlite)
    services.register(migrationConfig)
}
