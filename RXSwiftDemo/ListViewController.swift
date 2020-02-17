//
//  ListViewController.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/11.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
class ListViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView(frame: self.view.frame, style: .plain)
//        tableView.delegate = self
//        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
//        let item = Observable.just([
//            "文本输入框的用法",
//            "开关按钮的用法",
//            "进度条的用法",
//            "文本标签的用法"
//        ])
//        item.bind(to: tableView.rx.items(cellIdentifier: "cell")) { (index, element, tableViewCell) in
//            guard let cell = tableViewCell as? TableViewCell else { return }
//            cell.click = { (iconView: UIImageView) in
//
//            }
//        }.disposed(by: disposeBag)
//        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        let sections = Observable.just([
            MySection(header: "", items: [
                "UILable的用法",
                "UIText的用法",
                "UIButton的用法"
            ])
        ])
        
        let dataSource = RxTableViewSectionedReloadDataSource<MySection> (configureCell: { (dataS, tab, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
            
            return cell
        })
        
        sections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
}

extension ListViewController {
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.click = { (iconView: UIImageView) in
            var rect = tableView.rectForRow(at: indexPath)
            rect.origin.y = rect.origin.y - tableView.contentOffset.y
            var imageViewRect = iconView.frame
            imageViewRect.origin.x = rect.origin.x
            imageViewRect.origin.y = rect.origin.y + imageViewRect.origin.y
            BuyAnimationManager().startAnimation(view: iconView, rect: imageViewRect, finisnPoint: CGPoint(x: UIScreen.main.bounds.width , y: UIScreen.main.bounds.height - 83)) { (finished) in
//                BuyAnimationManager().shakeAnimation(cell)
            }
        }
        return cell
    }
    
}

//自定义Section
struct MySection {
    var header: String
    var items: [Item]
}

extension MySection: AnimatableSectionModelType {
    typealias Item = String

    var identity: String {
        return header
    }

    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}
