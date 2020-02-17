//
//  GitHubNetworkService.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/17.
//  Copyright © 2020 NULL. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class GitHubNetworkService {
//    func searchRepositories(query: String) -> Observable<GitHubRepositories> {
//        return GitHubProvider.rx.request(.repositories(query))
//            .filterSuccessfulStatusCodes()
//            .mapObject(GitHubRepositories.self, context: nil)
//            .asObservable()
//            .catchError { (error) -> Observable<GitHubRepositories> in
//                print("发生错误：",error.localizedDescription)
//                return Observable<GitHubRepositories>.empty()
//        }
//    }
    
    //搜索资源数据
    func searchRepositories(query:String) -> Driver<GitHubRepositories> {
        return GitHubProvider.rx.request(.repositories(query))
            .filterSuccessfulStatusCodes()
            .mapObject(GitHubRepositories.self)
            .asDriver(onErrorDriveWith: Driver.empty())
    }
}
