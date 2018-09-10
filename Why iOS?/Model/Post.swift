//
//  Post.swift
//  Why iOS?
//
//  Created by Jason Goodney on 9/5/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import Foundation

struct Post: Codable {
    let name: String
    let reason: String
    let uuid: String = UUID().uuidString
    let cohort: String = "iOS21"
}
