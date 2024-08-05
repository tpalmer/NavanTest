//
//  Post.swift
//  NavanTest
//
//  Created by Travis Palmer on 8/5/24.
//

import Foundation

struct Post: Identifiable, Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
