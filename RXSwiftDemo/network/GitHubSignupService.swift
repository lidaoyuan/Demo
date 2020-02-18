//
//  GitHubSignupService.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/17.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit
import RxSwift

class GitHubSignupService {
    //密码最少位数
    let minPasswordCount = 5
    
    lazy var networkService = {
        return GitHubNetworkService()
    }()
    
    //验证用户名
    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        //判断用户名是否为空
        if username.isEmpty {
            return .just(.empty)
        }
        
        //判断用户名是否只有数字和字母
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "用户名只能包含数字和字母"))
        }
        
        //发起网络请求检查用户名是否已存在
        return networkService.usernameAvailable(username).map { available in
            if available {
                return .ok(message: "用户名可用")
            } else {
                return .failed(message: "用户名已存在")
            }
        }
            .startWith(.validating) //在发起网络请求前，先返回一个“正在检查”的验证结果
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.count
         
        //判断密码是否为空
        if numberOfCharacters == 0 {
            return .empty
        }
         
        //判断密码位数
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "密码至少需要 \(minPasswordCount) 个字符")
        }
         
        //返回验证成功的结果
        return .ok(message: "密码有效")
    }
    
    //验证二次输入的密码
    func validateRepeatedPassword(_ password: String, repeatedPassword: String)
        -> ValidationResult {
        if repeatedPassword.count == 0 {
            return .empty
        }
        
        if repeatedPassword == password {
            return .ok(message: "密码有效")
        } else {
            return .failed(message: "两次输入的密码不一致")
        }
    }
}
