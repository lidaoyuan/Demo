//
//  SemiModalView.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/12.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit

class SemiModalView: UIView {

    
    var narrowedOff: Bool = false
    var baseViewController: UIViewController?
    var viewWillClose: (() ->())?
    var viewDidClose: (() ->())?
    let screenW = UIScreen.main.bounds.width
    let screenH = UIScreen.main.bounds.height
    
    lazy var contentView: UIView = {
        let contentView = UIView(frame: CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: self.frame.height))
        contentView.backgroundColor = .white
        return contentView
    }()
    
    lazy var closeControl: UIControl = {
        let closeControl = UIControl(frame: self.frame)
        closeControl.isUserInteractionEnabled = false
        closeControl.backgroundColor = .clear
        closeControl.addTarget(self, action: #selector(close), for: .touchUpInside)
        return closeControl
    }()

    lazy var maskImageView: UIImageView = {
        let maskImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        return maskImageView
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    convenience init(size: CGSize, baseViewController: UIViewController) {
        
        self.init()
        self.frame = UIScreen.main.bounds
        self.backgroundColor = .black
        self.addSubview(maskImageView)
        self.addSubview(closeControl)
        self.addSubview(contentView)
    
        contentView.frame = self.contentView(frameWithSize: size)
        self.baseViewController = baseViewController
        baseViewController.view.insertSubview(self, at: 0)
        baseViewController.view.sendSubviewToBack(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SemiModalView {
        
    func open() {

        if !narrowedOff {
            var t = CATransform3DIdentity
            t.m34 = -0.004
            maskImageView.layer.transform = t
            maskImageView.layer.zPosition = -10000
            maskImageView.image = snapshotWithWindow()
            
            guard let baseViewController = baseViewController else { return }
            baseViewController.view.bringSubviewToFront(self)
            
            closeControl.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.25) {
                self.maskImageView.alpha = 0.5
                self.contentView.frame = CGRect(x: 0, y: self.screenH - self.contentView.bounds.height, width: self.contentView.frame.width, height: self.contentView.frame.height)
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                self.maskImageView.layer.transform = CATransform3DRotate(t, 7 / 90 * .pi / 2, 1, 0, 0)
                if let _ = baseViewController.navigationController {
                    self.transNavigationBar(toHidden: true)
                }
            }) { (finished) in
                UIView.animate(withDuration: 0.25) {
                    self.maskImageView.layer.transform = CATransform3DTranslate(t, 0, -50, -50)
                }
            }
        } else {
            maskImageView.image = self.snapshotWithWindow()
            guard let baseViewController = baseViewController else { return }
            baseViewController.view.bringSubviewToFront(self)
            closeControl.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.25) {
                self.maskImageView.alpha = 0.25
                self.contentView.frame = CGRect(x: 0, y: self.screenH - self.contentView.bounds.height, width: self.contentView.frame.width, height: self.contentView.frame.height)
                if let nav = baseViewController.navigationController {
                    nav.isNavigationBarHidden = true
                }
            }
        }
    }
    
    @objc func close() {
        if let willClose = viewWillClose {
            willClose()
        }
        guard let baseViewController = baseViewController else { return }
        if !narrowedOff {
            var t = CATransform3DIdentity
            t.m34 = -0.004
            maskImageView.layer.transform = t
            closeControl.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 0.5, animations: {
                self.maskImageView.alpha = 1
                self.contentView.frame = CGRect(x: 0, y: self.frame.height, width: self.contentView.frame.width, height: self.contentView.frame.height)
                
            }) { (finished) in
                if let didClose = self.viewDidClose {
                    didClose()
                }
                
                if let _ = baseViewController.navigationController {
                    self.transNavigationBar(toHidden: false)
                }
                baseViewController.view.sendSubviewToBack(self)
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                self.maskImageView.layer.transform = CATransform3DTranslate(t, 0, -50, -50)
                self.maskImageView.layer.transform = CATransform3DRotate(t, 7 / 90 * .pi / 2, 1, 0, 0)
            }) { (finished) in
                UIView.animate(withDuration: 0.25) {
                    self.maskImageView.layer.transform = CATransform3DTranslate(t, 0, 0, 0)
                }
            }
        } else {
            closeControl.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.25, animations: {
                self.maskImageView.alpha = 1
                self.maskImageView.frame = CGRect(x: 0, y: self.frame.height, width: self.contentView.frame.width, height: self.contentView.frame.height)
            }) { (finished) in
                if let didClose = self.viewDidClose {
                    didClose()
                }
                
                baseViewController.view.sendSubviewToBack(self)
                if let nav = baseViewController.navigationController {
                    nav.isNavigationBarHidden = true
                }
            }
        }
    }
    
    
    func transNavigationBar(toHidden hidden: Bool) {
        if hidden {
            let frame = baseViewController?.navigationController?.navigationBar.frame
            setNavigationBar(originY: -frame!.height, animated: false)
        } else {
            setNavigationBar(originY: statusBarHeight(), animated: false)
        }
    }
    
    func setNavigationBar(originY y: CGFloat, animated: Bool) {
        let statusBarH = statusBarHeight()
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        guard let baseView = keyWindow.rootViewController?.view else { return }
        let viewControllerFrame = baseView.convert(baseView.bounds, to: keyWindow)
        let overwrapStatusBarH = statusBarH - viewControllerFrame.origin.y
        var frame = baseViewController!.navigationController!.navigationBar.frame
        frame.origin.y = y
        let navBarHiddenRatio = overwrapStatusBarH > 0 ? (overwrapStatusBarH - frame.origin.y) / overwrapStatusBarH : 0
        let alpha = max(1 - navBarHiddenRatio, 0.000001)
        
        UIView.animate(withDuration: animated ? 0.1 : 0) {
            self.baseViewController!.navigationController!.navigationBar.frame = frame
            var index = 0
            for view in self.baseViewController!.navigationController!.navigationBar.subviews {
                index += 1
                if index == 1 || view.isHidden || view.alpha <= 0 {
                    continue
                }
                view.alpha = alpha
                
                let navTintColor = self.baseViewController!.navigationController!.navigationBar.tintColor
                self.baseViewController!.navigationController!.navigationBar.tintColor = navTintColor?.withAlphaComponent(alpha)
            }
            
        }
    }
    
    func statusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return min(statusBarSize.width, statusBarSize.height)
    }
    
    func contentView(frameWithSize size: CGSize) -> CGRect {
        var height = size.height
    
        if height > screenH {
            height = screenH
        }
    
        return CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: height)
    }
    
    func snapshotWithWindow() -> UIImage {
        guard let keyWindow = UIApplication.shared.keyWindow else { return UIImage() }
        UIGraphicsBeginImageContextWithOptions(keyWindow.bounds.size, true, 2)
        keyWindow.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
