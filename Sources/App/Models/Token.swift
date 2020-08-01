//
//  Token.swift
//  
//
//  Created by Samantha Gatt on 8/1/20.
//

import Foundation
import Vapor
import FluentSQLite

struct Token: Content, SQLiteUUIDModel, Migration {
    // Actual token
    var id: UUID?
    var username: String
    var expiry: Date
}
