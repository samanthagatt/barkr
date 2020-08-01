//
//  File.swift
//  
//
//  Created by Samantha Gatt on 8/1/20.
//

import Foundation
import Vapor
import FluentSQLite

struct Post: Content, SQLiteModel, Migration, Validatable {
    var id: Int?
    var username: String
    var message: String
    var parent: Int
    var date: Date
}

struct PostInput: RequestDecodable {
    static func decode(from req: Request) throws -> EventLoopFuture<PostInput> {
        Future.map(on: req) {
            PostInput(token: try req.content.syncGet(at: "token"),
                      message: try req.content.syncGet(at: "message"),
                      reply: try? req.content.syncGet(at: "reply"))
        }
    }
    
    var token: UUID
    var message: String
    var reply: Int?
}

extension Post {
    static func validations() throws -> Validations<Post> {
        var validations = Validations(Post.self)
        try validations.add(\.username, .count(1...) && .alphanumeric)
        try validations.add(\.message, .count(2...))
        try validations.add(\.parent, .range(0...))
        return validations
    }
}
