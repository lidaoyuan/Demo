//
//  StarView.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/14.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit

/// 星星计算单位
///
/// - all: 一星计算
/// - half: 半星计算
/// - custom: 随意
public enum rateStyle: Int {
    case  all = 0
    case  half = 1
    case  custom = 2
}

//计算显示完回调方法
public typealias CountCompleteBackBlock = (_ currentCount:Float) -> ()


class StarView: UIView {
    
    //星星的总量,默认是5星
    var numberOfStar: UInt = 5
    //当前选中的数量，默认不选中
    var selectNumberOfStar: Float = 0 {
        didSet {
            //不重复刷新
            if oldValue == selectNumberOfStar {
                return
            }
            //越界处理
            if selectNumberOfStar < 0 {
                 selectNumberOfStar = 0
            } else if selectNumberOfStar > Float(numberOfStar) {
                 selectNumberOfStar = Float(numberOfStar)
            }
            
            if let currentStarBack = callback {
                currentStarBack(selectNumberOfStar)
            }

        }
    }
    // 是否支持动画
    var isAnimation: Bool = true
    // 是否支持手势
    var isSupportGesture: Bool = true
    
    // 回调函数
    var callback: CountCompleteBackBlock?
    //选择单位 默认全选
    var selectStarUnit: rateStyle = .all
    // 背景view
    fileprivate var backgroundView: UIView!
    // 选择view
    fileprivate var foreView: UIView!
    // 星星的宽度
    fileprivate var starWidth: CGFloat!

    fileprivate var starIndex = 100
    fileprivate var oldSelectNumber: Int = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    ///  遍历初始函数
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - starCount: 背景星星个数
    ///   - currentStar: 当前星星个数
    ///   - rateStyle:选择单位 默认全选
    ///   - isAnimation: 是否支持动画
    convenience init(frame: CGRect,starCount: UInt?,currentStar: Float?, rateStyle: rateStyle?, isAnimation: Bool? = true, complete: @escaping CountCompleteBackBlock) {
        self.init(frame: frame)
        callback = complete
        numberOfStar = starCount ?? 5
        selectNumberOfStar = currentStar ?? 0
        selectStarUnit = rateStyle ?? .all
        self.isAnimation = isAnimation!
        setupUI()
    }
    
    //xib使用初始化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
}


//MARK:- UI
extension StarView {
    
    
    //重新设置属性刷新
    func update() {
        setupUI()
    }
    
    //UI初始化
    fileprivate func setupUI() {
    
        clearAll()
        // 星星宽度
        starWidth =  self.bounds.size.width / CGFloat(numberOfStar)
        // 背景view
        backgroundView = creatStarView(image: UIImage(named: "b27_icon_star_gray")!)
        // 选择view
        foreView = creatStarView(image: UIImage(named: "b27_icon_star_yellow")!)
        
        foreView.frame = CGRect(x: 0, y: 0, width: starWidth * CGFloat(selectNumberOfStar), height: self.bounds.size.height)
        self.addSubview(backgroundView)
        self.addSubview(foreView)
        setGesture()
            
    }
    
   fileprivate func setGesture() {
        if isSupportGesture {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapStar(_:)))
            self.addGestureRecognizer(tap)
            
            let pan = UIPanGestureRecognizer(target: self,action: #selector(tapStar(_:)))
            self.addGestureRecognizer(pan)
        }
    }
    
    //创建StarView
    fileprivate func creatStarView(image: UIImage) -> UIView {
        
        let view =  UIView(frame:self.bounds)
        view.clipsToBounds = true
        view.backgroundColor = .clear
        
        for i in 0...numberOfStar {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x:CGFloat(i) * starWidth, y: 0, width: starWidth, height: self.bounds.size.height)
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            imageView.tag = Int(i + 100)
            view.addSubview(imageView)
        }
        
        return view
    }
    
    //清除所有视图和手势
    func clearAll(){
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        if let taps = self.gestureRecognizers {
            for tap in taps{
                self.removeGestureRecognizer(tap)
            }
        }
       
    }
    
    func showStarRate() {
        let animationTimeInterval = isAnimation ? 0.2 : 0
//        UIView.animate(withDuration: animationTimeInterval) {
            self.foreView.frame = CGRect(x: 0, y: 0, width: self.starWidth * CGFloat(self.selectNumberOfStar), height: self.bounds.size.height)
//        }
    }
    
    
    @objc func starAnimation() {

        let view = foreView.viewWithTag(starIndex)
        view?.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.1, animations: {
            view?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (finished) in
            view?.transform = .identity
            
            self.starIndex += 1
            
            if UInt(ceil(self.selectNumberOfStar)) == self.numberOfStar {
                self.yanh()
            }
            
            if (self.starIndex - 100) > Int(ceil(self.selectNumberOfStar)) {
                self.starIndex = 100
                return
            }
            self.starAnimation()
            
        }
        
    }
}

//MARK:- 事件
extension StarView {
    
    @objc func tapStar(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: self)
        let offset = tapPoint.x
        let selctCount = offset / starWidth
        switch selectStarUnit {
            case .all:
                selectNumberOfStar = ceilf(Float(selctCount))
                break
            case .half:
                selectNumberOfStar = roundf(Float(selctCount)) > Float(selctCount) ? ceilf(Float(selctCount)) : ceilf(Float(selctCount)) - 0.5
                break
            default:
                selectNumberOfStar = Float(selctCount)
                break
        }
        
        showStarRate()
        
        
        if oldSelectNumber != Int(ceil(selectNumberOfStar)) {
            print("======")
            starIndex = 100
            starAnimation()
//            starIndex = 100
        } else {
//            for view in foreView.subviews {
//                view.layer.removeAllAnimations()
//            }
                
             
        }
//        starAnimation()
        oldSelectNumber = Int(ceil(selectNumberOfStar))


    }
    
    @objc func panStar(_ sender: UIPanGestureRecognizer) {

        let tapPoint = sender.location(in: self)
        let offset = tapPoint.x
        let selctCount = offset / starWidth
        switch selectStarUnit {
            case .all:
                selectNumberOfStar = ceilf(Float(selctCount))
                break
            case .half:
                selectNumberOfStar = roundf(Float(selctCount)) > Float(selctCount) ? ceilf(Float(selctCount)) : ceilf(Float(selctCount)) - 0.5
                break
            default:
                selectNumberOfStar = Float(selctCount)
                break
        }
        
        showStarRate()
    
    }

}

extension StarView {
    func yanh() {
        //创建发射器
        let emitter = CAEmitterLayer()
        
        //发射器中心点
        emitter.emitterPosition = CGPoint(x: foreView.bounds.size.width / 2.0, y: foreView.bounds.size.height)
        
        //发射器尺寸
        emitter.emitterSize = CGSize(width: foreView.bounds.size.width, height: 0.0)
        
        //发射器发射模式
        emitter.emitterMode = .outline
        
        //发射器形状
        //        NSString * const kCAEmitterLayerPoint;//点的形状，粒子从一个点发出
        //        NSString * const kCAEmitterLayerLine;//线的形状，粒子从一条线发出
        //        NSString * const kCAEmitterLayerRectangle;//矩形形状，粒子从一个矩形中发出
        //        NSString * const kCAEmitterLayerCuboid;//立方体形状，会影响Z平面的效果
        //        NSString * const kCAEmitterLayerCircle;//圆形，粒子会在圆形范围发射
        //        NSString * const kCAEmitterLayerSphere;//球型
        emitter.emitterShape = .line
        
        //发射器粒子渲染效果
        //        NSString * const kCAEmitterLayerUnordered;//粒子无序出现
        //        NSString * const kCAEmitterLayerOldestFirst;//声明久的粒子会被渲染在最上层
        //        NSString * const kCAEmitterLayerOldestLast;//年轻的粒子会被渲染在最上层
        //        NSString * const kCAEmitterLayerBackToFront;//粒子的渲染按照Z轴的前后顺序进行
        //        NSString * const kCAEmitterLayerAdditive;//粒子混合
        emitter.renderMode = .additive
        
        //创建烟花子弹
        let bullet = CAEmitterCell()
        
        //子弹诞生速度,每秒诞生个数
        bullet.birthRate = 1.0
        
        //子弹的停留时间,即多少秒后消失
        bullet.lifetime = 1.3
        
        //子弹的样式,可以给图片
        bullet.contents = self.imageWithColor(.yellow).cgImage
        
        //子弹的发射弧度
        bullet.emissionRange = 0.15 * .pi
        
        //子弹的速度
        bullet.velocity = foreView.bounds.size.height - 50
        //随机速度范围
        bullet.velocityRange = 10
        //y轴加速度
        bullet.yAcceleration = 0
        //自转角速度
        bullet.spin = .pi / 2
        
        //三种随机色
        bullet.redRange = 1.0
        bullet.greenRange = 1.0
        bullet.blueRange = 1.0
        
        //开始爆炸
        let burst = CAEmitterCell()
        //属性同上
        burst.birthRate = 1.0
        burst.velocity = 0
        burst.scale = 2.5
        burst.redSpeed = -1.5
        burst.blueSpeed = 1.5
        burst.greenSpeed = 1.0
        burst.lifetime = 0.35
//        burst.emissionLongitude = 30
        
        //爆炸后的烟花
        let spark = CAEmitterCell()
        //属性设置同上
        spark.birthRate = 6
        spark.lifetime = 3
        spark.velocity = 125
        spark.velocityRange = 100
        spark.emissionRange = 2 * .pi
        
        spark.contents = UIImage(named: "fire.png")?.cgImage
        spark.scale = 0.1
        spark.scaleRange = 0.05
        
        spark.greenSpeed = -0.1
        spark.redSpeed = 0.4
        spark.blueSpeed = -0.1
        spark.alphaSpeed = -0.5
        spark.spin = 2 * .pi
        spark.spinRange = 2 * .pi
        
        //这里是重点,先将子弹添加给发射器
        emitter.emitterCells = [bullet]
        
        //子弹发射后,将爆炸cell添加给子弹cell
        bullet.emitterCells = [burst]
        
        //将烟花cell添加给爆炸效果cell
        burst.emitterCells = [spark]

        //最后将发射器附加到主视图的layer上
        foreView.layer.addSublayer(emitter)
    }
    
    fileprivate func imageWithColor(_ color: UIColor) -> UIImage {

        let rect = CGRect(x: 0.0, y: 0.0, width: 5.0, height: 5.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
