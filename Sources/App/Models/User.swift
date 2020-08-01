//
//  User.swift
//  
//
//  Created by Samantha Gatt on 8/1/20.
//

import Foundation
import Vapor
import FluentSQLite

struct User: Content, SQLiteStringModel, Migration {
    var id: String?
    var password: String
}
