//
//  PeopleViewModel.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/10.
//  Copyright © 2020 NULL. All rights reserved.
//

import Foundation
import RxSwift

struct Person {
    var name: String
    var age: Int
    
}

struct PeopleListModel {
    let data = Observable.just([
    ])
    
}
