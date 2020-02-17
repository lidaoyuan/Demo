//
//  ViewController.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/10.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

class ViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    var tableView:UITableView!
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeStart()

    }

    
    
    //纯代码
    func codeStart() {
        let starview = StarView.init(frame: CGRect.init(x: (UIScreen.main.bounds.width - 320)/2, y: 100, width: 320, height: 100), starCount: 8, currentStar: 0, rateStyle: .half) { (current) -> (Void) in
            print(current)
        }
        self.view.addSubview(starview)
//        let starView = StarRateView(frame: CGRect(x: 0, y: 100, width: 414, height: 100), numberOfStars: 5, currentStarCount: 1.5)
//        starView.userPanEnabled = true
////        starView.isUserInteractionEnabled = false
//        self.view.addSubview(starView)
        
    }
   
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let tapPoint = touch.location(in: self.view)
//            let offset = tapPoint.x
//            let starOffset = offset / (self.bounds.size.width / self.starCount)
//            
//        }
//        print("111111111111111")
    }
    
}

