//
//  BuyAnimationManager.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/11.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit

class BuyAnimationManager: NSObject {
    
    static let shared = BuyAnimationManager()
    
    var layer: CALayer?
    var animationFinished: ((_ finished: Bool) -> ())?
    
    func startAnimation(view: UIView, rect: CGRect, finisnPoint: CGPoint, finished: @escaping (_ finished: Bool) -> ()) {
        layer = CALayer()
        layer?.contents = view.layer.contents
        layer?.contentsGravity = .resizeAspectFill
        
        var re = rect
        re.size.width = 60
        re.size.height = 60
        
        layer?.bounds = re
        layer?.cornerRadius = re.size.width / 2
        layer?.masksToBounds = true
        
        // 获取window的最顶层视图控制器
//        var rootVC = UIApplication.shared.keyWindow?.rootViewController
//        let parentVC = rootVC?.presentingViewController
//
//        if let vc = parentVC {
//            rootVC = vc
//        }
//
//        while (rootVC?.isKind(of: UINavigationController.classForCoder())) ?? false {
//            guard let rootNav = rootVC as? UINavigationController else { return }
//            rootVC = rootNav.topViewController
//        }
//
//        rootVC?.view.layer.addSublayer(layer!)
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow?.layer.addSublayer(layer!)
        layer?.position = CGPoint(x: re.origin.x + view.frame.width / 2, y: re.midY)
        
        createAnimation(rect: re, finishPoint: finisnPoint)
        
        
        
        animationFinished = finished
    }
    
    func createAnimation(rect: CGRect, finishPoint: CGPoint) {
        // 路径动画
        let path = UIBezierPath()
        path.move(to: layer!.position)
        path.addQuadCurve(to: finishPoint, controlPoint: CGPoint(x: UIScreen.main.bounds.width / 2, y: rect.origin.y - 80))
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.path = path.cgPath
        // 旋转动画
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.isRemovedOnCompletion = true
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = 12
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        // 添加动画动画组合
        let groups = CAAnimationGroup()
        groups.animations = [pathAnimation, rotateAnimation]
        groups.duration = 1.2
        groups.isRemovedOnCompletion = false
        groups.fillMode = .forwards
        groups.delegate = self
        layer?.add(groups, forKey: "group")
    }
    
    func shakeAnimation(_ view: UIView) {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        shakeAnimation.duration = 0.25
        shakeAnimation.fromValue = -5
        shakeAnimation.toValue = 5
        shakeAnimation.autoreverses = true
        view.layer.add(shakeAnimation, forKey: nil)
    }
}

//MARK: CAAnimationDelegate
extension BuyAnimationManager: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == layer?.animation(forKey: "group") {
            layer?.removeFromSuperlayer()
            layer = nil
            
            if let finished = animationFinished {
                finished(true)
            }
        }
    }
}
