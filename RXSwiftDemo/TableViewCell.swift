//
//  TableViewCell.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/11.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    var click: ((UIImageView) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.backgroundColor = UIColor(red: CGFloat(arc4random() % 256) / 255.0, green: CGFloat(arc4random() % 256) / 255.0, blue: CGFloat(arc4random() % 256) / 255.0, alpha: 1.0)
        iconView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(iconTap))
        iconView.addGestureRecognizer(tap)
    }

    @objc func iconTap() {

        if let click = click {
            click(iconView)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
