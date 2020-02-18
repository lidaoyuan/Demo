//
//  Validation.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/17.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit

enum ValidationResult {
    case validating  //正在验证中
    case empty  //输入为空
    case ok(message: String) //验证通过
    case failed(message: String)  //验证失败
}

//扩展ValidationResult，对应不同的验证结果返回验证是成功还是失败
extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

//扩展ValidationResult，对应不同的验证结果返回不同的文字描述
extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case .validating:
            return "正在验证..."
        case .empty:
            return ""
        case let .ok(message):
            return message
            
        case let .failed(message):
            return message
        }
    }
}

//扩展ValidationResult，对应不同的验证结果返回不同的文字颜色
extension ValidationResult {
    var textColor: UIColor {
        switch self {
        case .validating:
            return .gray
        case .empty:
            return .black
        case .ok:
            return UIColor(red: 0 / 255, green: 130 / 255, blue: 0 / 255, alpha: 1)
        case .failed:
            return .red
        }
    }
}
