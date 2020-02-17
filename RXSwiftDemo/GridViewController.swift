//
//  GridViewController.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/13.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class GridViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "瀑布流"
//        let layout = GridViewLayout()
//        layout.delegate = self
//        collectionView.collectionViewLayout = layout
//        let flowLayout = UICollectionViewFlowLayout()     
//        collectionView.collectionViewLayout = flowLayout
        
        let luaLayout = Layout()
        luaLayout.delegate = self
        collectionView.collectionViewLayout = luaLayout
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        let items = Observable.just([
            SectionModel(model: "", items: [
                "Swift",
                "PHP",
//                "Python",
//                "Java",
//                "javascript",
//                "C#",
                
                ]),
            SectionModel(model: "", items: [
            "Swift",
            "PHP",
//            "Python",
//            "Java",
//            "javascript",
//            "C#",
            ])

        ])
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: { (dataSource, collectionView, indexPath, element) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            
            return cell
            
        })
        
        items.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
    }
}

extension GridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let cellWidth = (width - 30) / 2 //每行显示4个单元格
        return CGSize(width: cellWidth, height: CGFloat((arc4random() % 200 + 150))) //单元格宽度为高度1.5倍
    }
}

extension GridViewController: GridLayoutDelegate {
    func gridFlowLayout(layout: GridViewLayout, indexPath: NSIndexPath, itemWidth: CGFloat) -> CGFloat {
        return CGFloat((arc4random() % 200 + 150))
    }
}

extension GridViewController: LayoutDelegate {
    func setCellNormalSize(in collectionView: UICollectionView) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 30) / 2, height: CGFloat((arc4random() % 200 + 150)))
    }
}
