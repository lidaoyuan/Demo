//
//  DetailViewController.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/12.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let starview = StarView.init(frame: CGRect.init(x: (UIScreen.main.bounds.width - 320)/2, y: 100, width: 320, height: 100), starCount: 8, currentStar: 0, rateStyle: .half) { (current) -> (Void) in
//        //            print(current)
//                }
//            self.view.addSubview(starview)
        
        let starView = StarRateView(frame: CGRect(x: 0, y: 100, width: 414, height: 100), numberOfStars: 5, currentStarCount: 1.5)
        starView.userPanEnabled = true
        starView.isUserInteractionEnabled = false
        self.view.addSubview(starView)
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let narrowedModalView = SemiModalView(size:  CGSize(width: UIScreen.main.bounds.width, height: 300), baseViewController: navigationController!)
//        narrowedModalView.contentView.backgroundColor = UIColor.white
//
//        let label = UILabel.init(frame: CGRect(x: 100, y: 100, width: 100, height: 20))
//        label.textColor = UIColor.black
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.text = "暂无内容"
//        narrowedModalView.contentView.addSubview(label)
//
//        narrowedModalView.open()
    }

}
