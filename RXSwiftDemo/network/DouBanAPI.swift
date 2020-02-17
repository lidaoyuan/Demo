//
//  DouBanAPI.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/17.
//  Copyright © 2020 NULL. All rights reserved.
//

import Foundation
import Moya


let DouBanProvider = MoyaProvider<DouBanAPI>()

public enum DouBanAPI {
    case channels  //获取频道列表
    case playList(String) //获取歌曲
}

extension DouBanAPI: TargetType {
    public var baseURL: URL {
        switch self {
        case .channels:
            return URL(string: "https://www.douban.com")!
        case .playList(_):
            return URL(string: "https://douban.fm")!
        }
    }
    
    public var path: String {
        switch self {
        case .channels:
            return "/j/app/radio/channels"
        case .playList(_):
            return "/j/mine/playlist"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        switch self {
        case .playList(let channel):
            var params: [String: Any] = [:]
            params["channel"] = channel
            params["type"] = "n"
            params["from"] = "mainsite"
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    //是否执行Alamofire验证
    public var validate: Bool {
        return false
    }
}
