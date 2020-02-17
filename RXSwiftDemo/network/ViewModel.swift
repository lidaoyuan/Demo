//
//  ViewModel.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/17.
//  Copyright © 2020 NULL. All rights reserved.
//

import Foundation
import RxSwift
import Result
import RxCocoa
class ViewModel {
    
//    let networkService = GitHubNetworkService()
//
//    /**** 输入部分 ***/
//    //查询行为
//    fileprivate let searchAction: Observable<String>
//
//    /**** 输出部分 ***/
//    //所有的查询结果
//    let searchResult: Observable<GitHubRepositories>
//
//    //查询结果里的资源列表
//    let repositories: Observable<[GitHubRepository]>
//
//    //清空结果动作
//    let cleanResult: Observable<Void>
//
//    //导航栏标题
//    let navigationTitle: Observable<String>
//
//    init(searchAction: Observable<String>) {
//        self.searchAction = searchAction
//
//        self.searchResult = searchAction
//            .filter{ !$0.isEmpty }//如果输入为空则不发送请求了
//            .flatMapLatest(networkService.searchRepositories)
//            .share(replay: 1)
//
//         //生成清空结果动作序列
//        self.cleanResult = searchAction.filter{ $0.isEmpty }.map{ _ in Void() }
//
//        //生成查询结果里的资源列表序列（如果查询到结果则返回结果，如果是清空数据则返回空数组）
//        self.repositories = Observable.of(searchResult.map{ $0.items }, cleanResult.map{[]}).merge()
//
//        //生成导航栏标题序列（如果查询到结果则返回数量，如果是清空数据则返回默认标题）
//        self.navigationTitle = Observable.of(searchResult.map{ "共有 \($0.totalCount!) 个结果" }, cleanResult.map{ "hangge.com" }).merge()
//    }
    
    /**** 数据请求服务 ***/
       let networkService = GitHubNetworkService()
        
       /**** 输入部分 ***/
       //查询行为
       fileprivate let searchAction: Driver<String>
        
       /**** 输出部分 ***/
       //所有的查询结果
       let searchResult: Driver<GitHubRepositories>
        
       //查询结果里的资源列表
       let repositories: Driver<[GitHubRepository]>
        
       //清空结果动作
       let cleanResult: Driver<Void>
        
       //导航栏标题
       let navigationTitle: Driver<String>
        
       //ViewModel初始化（根据输入实现对应的输出）
       init(searchAction: Driver<String>) {
           self.searchAction = searchAction
            
           //生成查询结果序列
           self.searchResult = searchAction
               .filter { !$0.isEmpty } //如果输入为空则不发送请求了
               .flatMapLatest(networkService.searchRepositories)
            
           //生成清空结果动作序列
           self.cleanResult = searchAction.filter{ $0.isEmpty }.map{ _ in Void() }
            
           //生成查询结果里的资源列表序列（如果查询到结果则返回结果，如果是清空数据则返回空数组）
           self.repositories = Driver.merge(
               searchResult.map{ $0.items },
               cleanResult.map{[]}
           )
            
           //生成导航栏标题序列（如果查询到结果则返回数量，如果是清空数据则返回默认标题）
           self.navigationTitle = Driver.merge(
               searchResult.map{ "共有 \($0.totalCount!) 个结果" },
               cleanResult.map{ "hangge.com" }
           )
       }
}