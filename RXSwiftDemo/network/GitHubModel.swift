//
//  GitHubModel.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/17.
//  Copyright © 2020 NULL. All rights reserved.
//

import Foundation
import ObjectMapper

struct GitHubRepositories: Mappable {
    var totalCount: Int!
    var incompleteResults: Bool!
    var items: [GitHubRepository]! //本次查询返回的所有仓库集合
    
    init() {
        totalCount = 0
        incompleteResults = false
        items = []
    }
    
    init?(map: Map) { }
    
    // Mappable
    mutating func mapping(map: Map) {
        totalCount <- map["total_count"]
        incompleteResults <- map["incomplete_results"]
        items <- map["items"]
    }
}

struct GitHubRepository: Mappable {
    var id: Int!
    var name: String!
    var fullName:String!
    var htmlUrl:String!
    var description:String!
    
    init?(map: Map) { }
    
    // Mappable
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        fullName <- map["full_name"]
        htmlUrl <- map["html_url"]
        description <- map["description"]
    }
}
