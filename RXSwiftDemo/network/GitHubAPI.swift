//
//  GitHubAPI.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/17.
//  Copyright © 2020 NULL. All rights reserved.
//

import Foundation
import Moya

let GitHubProvider = MoyaProvider<GitHubAPI>()

public enum GitHubAPI {
    case repositories(String)
}

extension GitHubAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    public var path: String {
        switch self {
        case .repositories:
            return "/search/repositories"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var sampleData: Data {
        "{}".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        switch self {
        case .repositories(let query):
            var params: [String: Any] = [:]
            params["q"] = query
            params["sort"] = "stars"
            params["order"] = "desc"
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        nil
    }
    
    public var validate: Bool {
        return false
    }
}
