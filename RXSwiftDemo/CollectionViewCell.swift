//
//  CollectionViewCell.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/13.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit


class CollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(red: CGFloat(arc4random() % 256) / 255.0, green: CGFloat(arc4random() % 256) / 255.0, blue: CGFloat(arc4random() % 256) / 255.0, alpha: 1.0)
    }

}
