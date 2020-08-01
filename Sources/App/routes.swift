import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.post(User.self, at: "create") { req, user -> Future<User> in
        guard let id = user.id else { throw Abort(.badRequest) }
        return User.find(id, on: req).flatMap(to: User.self) { found in
            guard found == nil else { throw Abort(.badRequest) }
            return user.create(on: req)
        }
    }
    router.post(User.self, at: "login") { req, user -> Future<Token> in
        _ = Token.query(on: req).filter(\.expiry, .lessThan, Date()).delete()
        guard let name = user.id, !name.isEmpty, !user.password.isEmpty
            else { throw Abort(.badRequest) }
        return User.find(name, on: req).flatMap(to: Token.self) { found in
            guard let found = found else { throw Abort(.notFound) }
            guard user.password == found.password
                else { throw Abort(.unauthorized) }
            let token = Token(id: nil, username: name,
                              expiry: Date().addingTimeInterval(86400))
            return token.create(on: req)
        }
    }
}
