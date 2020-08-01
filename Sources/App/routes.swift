import Routing
import Vapor
import Fluent

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
    let posts = router.grouped("posts")
    posts.post(PostInput.self) { req, postIn -> Future<Post> in
        guard !postIn.message.isEmpty else { throw Abort(.badRequest) }
        let reply = postIn.reply ?? 0
        return Token.find(postIn.token, on: req).flatMap(to: Post.self) { token in
            guard let token = token else { throw Abort(.unauthorized) }
            guard token.expiry > Date() else {
                _ = token.delete(on: req)
                throw Abort(.unauthorized)
            }
            let post = Post(id: nil, username: token.username,
                            message: postIn.message, parent: reply, date: Date())
            return post.create(on: req)
        }
    }
    posts.get { req -> Future<[Post]> in
        let query = try? req.query.get(String.self, at: "search")
        return Post.query(on: req)
            .filter(\.message, .like, "%" + (query ?? "") + "%")
            .all()
    }
    posts.get(Int.parameter) { req -> Future<Post> in
        Post.find(try req.parameters.next(), on: req).map(to: Post.self) { post in
            guard let post = post else { throw Abort(.notFound) }
            return post
        }
    }
    let userPosts = router.grouped(String.parameter, "posts")
    userPosts.get { req -> Future<[Post]> in
        let username: String = try req.parameters.next()
        let query = try? req.query.get(String.self, at: "search")
        return User.find(username, on: req).flatMap(to: [Post].self) { user in
            guard user != nil else { throw Abort(.notFound) }
            return Post.query(on: req)
                .filter(\.username, .equal, username)
                .filter(\.message, .like, "%" + (query ?? "") + "%")
                .all()
        }
    }
}
