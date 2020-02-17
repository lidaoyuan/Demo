//
//  GridViewLayout.swift
//  RXSwiftDemo
//
//  Created by NULL on 2020/2/13.
//  Copyright © 2020 NULL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
@objc protocol GridLayoutDelegate: NSObjectProtocol {
    func gridFlowLayout(layout: GridViewLayout, indexPath: NSIndexPath, itemWidth: CGFloat) -> CGFloat
    @objc optional func gridFlowLayout(columnCountInGridFlowLayout layout: GridViewLayout) -> Int
    @objc optional func gridFlowLayout(columnMarginInGridFlowLayout layout: GridViewLayout) -> CGFloat
    @objc optional func gridFlowLayout(rowMarginInGridFlowLayout layout: GridViewLayout) -> CGFloat
    @objc optional func gridFlowLayout(edgeInsetsInGridFlowLayout layout: GridViewLayout) -> UIEdgeInsets
}

class GridViewLayout: UICollectionViewFlowLayout {
    
    weak var delegate: GridLayoutDelegate?
    
    fileprivate let defaultColumnCount: Int = 2
    fileprivate let defaultColumnMargin: CGFloat = 10
    fileprivate let defaultRowMargin: CGFloat = 10
    fileprivate let defaultEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    /*懒加载创建存放属性的数组*/
    fileprivate lazy var attrs: [UICollectionViewLayoutAttributes] = []
    fileprivate lazy var columnHeights: [CGFloat] = []
    fileprivate var contentHeight: CGFloat?
    
    override func prepare() {
        super.prepare()
        
        if self.collectionView == nil {
            return
        }
        
        self.columnHeights.removeAll()
        self.contentHeight = 0
        
        for  _ in 0 ..< self.columnCount() {
            self.columnHeights.append(self.edgeInsets().top)
        }
        
        self.attrs.removeAll()
        let section = self.collectionView?.numberOfSections
//        let count = (self.collectionView?.numberOfItems(inSection: section!))!
        let count = 2
        let width = (self.collectionView?.frame.size.width)!
        let colMagin = (CGFloat)(self.columnCount() - 1) * self.columnMargin()

        let cellWidth = (width - self.edgeInsets().left - self.edgeInsets().right - colMagin) / CGFloat(self.columnCount())

        for i in 0 ..< count {
            let indexPath = NSIndexPath(item: i, section: 0)
            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
            
            //获取高度
            let cellHeight =  (self.delegate?.gridFlowLayout(layout: self, indexPath: indexPath as NSIndexPath, itemWidth: cellWidth))!

            var minColumnHeight = self.columnHeights[0]
            var minColumn = 0
            for i in 1 ..< self.columnCount() {
                let colHeight = self.columnHeights[i]

                if colHeight < minColumnHeight {
                    minColumnHeight = colHeight
                    minColumn = i
                }
            }
            
            let cellX = self.edgeInsets().left + CGFloat(minColumn) * (self.columnMargin() + cellWidth)
            var cellY = minColumnHeight
            if cellY != self.edgeInsets().top {
                cellY = self.rowMargin() + cellY
            }

            attr.frame = CGRect(x: cellX, y: cellY, width: cellWidth, height: cellHeight)
            let maxY = cellY + cellHeight

            
            self.columnHeights[minColumn] = maxY
            let maxContentHeight = self.columnHeights[minColumn]
            if CGFloat(self.contentHeight!) < CGFloat(maxContentHeight) {
                self.contentHeight = maxContentHeight
            }
            self.attrs.append(attr)
        }
        
    }
    
    
    private func columnCount() -> Int {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(self.delegate?.gridFlowLayout(columnCountInGridFlowLayout:))))!{
            return (self.delegate?.gridFlowLayout!(columnCountInGridFlowLayout: self))!
        } else {
            return defaultColumnCount
        }
    }

    private func columnMargin() -> CGFloat {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(self.delegate?.gridFlowLayout(columnMarginInGridFlowLayout:))))!{
            return (self.delegate?.gridFlowLayout!(columnMarginInGridFlowLayout: self))!
        } else {
            return defaultColumnMargin
        }
    }

    private func rowMargin() -> CGFloat {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(self.delegate?.gridFlowLayout(rowMarginInGridFlowLayout:))))!{
            return (self.delegate?.gridFlowLayout!(rowMarginInGridFlowLayout: self))!
        } else {
            return defaultRowMargin
        }
    }

    private func edgeInsets() -> UIEdgeInsets {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(self.delegate?.gridFlowLayout(edgeInsetsInGridFlowLayout:))))!{
            return (self.delegate?.gridFlowLayout!(edgeInsetsInGridFlowLayout: self))!
        } else {
            return defaultEdgeInsets
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attrs
    }
    
    override var collectionViewContentSize: CGSize{
        get {
            return CGSize(width: 0, height: CGFloat(self.contentHeight!) + CGFloat(self.edgeInsets().bottom))
        }
        set {
            self.collectionViewContentSize = newValue
        }
    }
}


@objc protocol LayoutDelegate : NSObjectProtocol {
    // 返回高度
    func setCellNormalSize(in collectionView: UICollectionView) -> CGSize
    // 返回行数
    @objc optional func columnCountInWaterFlowLayout(in collectionView: UICollectionView) -> Int
    // 返回列间距
    @objc optional func defaultColumnMarginInWaterFlowLayout(in collectionView: UICollectionView) -> CGFloat
    // 返回行间距
    @objc optional func rowMarginInWaterFlowLayout(in collectionView: UICollectionView) -> CGFloat
    //内边距
    @objc optional func edgeInsetsInWaterFlowLayout(in collectionView: UICollectionView) -> UIEdgeInsets
    //组数
    @objc optional func numberOfSections(in collectionView: UICollectionView) -> Int
    //特殊的cell在哪个Indexpath
    @objc optional func specialCellIndexpath(in collectionView:UICollectionView) -> IndexPath
    //特殊的cell的对应size
    @objc optional func specialCellSize(in collectionView:UICollectionView, numberOfItemsInSection section: Int) -> CGSize

}

class Layout: UICollectionViewLayout {
    weak var delegate: LayoutDelegate?
    
    /** 默认列数 */

    private var DefaultColumnCount: Int = 5
    private var DefaultSize:CGSize = CGSize(width: 50, height: 50)
    private var SpecialSize:CGSize = CGSize(width: 50, height: 50)
    private var SpecialIndex:IndexPath = IndexPath.init(item: 0, section: 0) //这个后续再支持
    // 记录 collectionView 的 content 可滑动的范围
    fileprivate var contentScope: CGFloat = 0
    /** 每一列之间的间距 垂直 */
    private var DefaultColumnMargin : CGFloat = 0.0
    /** 每一行之间的间距 水平方向 */
    private var DefaultRowMargin : CGFloat = 0.0
    /** 边缘间距 */
    private var DefaultEdgeInsets : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private var LastSectionMaxHeight: CGFloat = 0
    //懒加载
    //存放所有cell的布局属性
    fileprivate lazy var attrsArrayArray = [UICollectionViewLayoutAttributes]()
    //存放所有列的当前高度
    fileprivate lazy var columnHeightsAry = [CGFloat]()
    //    fileprivate lazy var SectionItemHeightArray: [CGFloat] = []
    
    //第一步 ：初始化
    override func prepare() {
        super.prepare()
        //清除高度
        columnHeightsAry.removeAll()
        self.contentScope = 0.0
        self.getconfigData()
        for _ in 0 ..< DefaultColumnCount {
            columnHeightsAry.append(DefaultEdgeInsets.top)
        }
        
        //清除所有的布局属性
        attrsArrayArray.removeAll()
        
        let sections : Int = (self.collectionView?.numberOfSections)!
     
        for num in 0 ..< sections {
            let count : Int = (self.collectionView?.numberOfItems(inSection: num))!//获取分区0有多少个item
            if self.delegate != nil && self.delegate?.responds(to: #selector(LayoutDelegate.specialCellSize(in:numberOfItemsInSection:))) ?? false {
                if let contentView = self.collectionView {
                    self.SpecialSize =  self.delegate?.specialCellSize?(in: contentView, numberOfItemsInSection: num) ?? CGSize.init(width: self.DefaultSize.width, height: self.DefaultSize.height)
                    
                }
                
            }
            for i in 0 ..< count {
                let indexpath : NSIndexPath = NSIndexPath.init(item: i, section: num)
                let attrsArray = self.layoutAttributesForItem(at: indexpath as IndexPath)!
                attrsArrayArray.append(attrsArray)
            }
            let (_, maximumInteritemHeight) = maximumInteritemForSection(heightArray: columnHeightsAry)
            self.LastSectionMaxHeight = maximumInteritemHeight
            columnHeightsAry.removeAll()
            for _ in 0 ..< DefaultColumnCount {
                columnHeightsAry.append(DefaultEdgeInsets.top)
            }
        }
    }
    
    /**
     * 第二步 ：返回indexPath位置cell对应的布局属性
     */
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrsArray = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        let _ItemWidth = DefaultSize.width
        var _ItemHeight = DefaultSize.height
        
        if self.SpecialSize.height != DefaultSize.height {
            if let nums = self.collectionView?.numberOfItems(inSection: indexPath.section){
                let mutiple = SpecialSize.height / DefaultSize.height
                if indexPath.row % nums == 0 {
                    _ItemHeight = SpecialSize.height + DefaultRowMargin * mutiple
                }else{
                    _ItemHeight = DefaultSize.height
                }
            }else{
                _ItemHeight = DefaultSize.height
            }
        }else{
            _ItemHeight = DefaultSize.height
        }
        
        

        let (minimumInteritemNumber, minimumInteritemHeight) = minimumInteritemForSection(heightArray: columnHeightsAry)
        let itemX = DefaultEdgeInsets.left + CGFloat(minimumInteritemNumber) * (_ItemWidth + DefaultColumnMargin)
        var itemY = minimumInteritemHeight
        let (_, maximumInteritemHeight) = maximumInteritemForSection(heightArray: columnHeightsAry)
        if indexPath.item < self.DefaultColumnCount {
            itemY = itemY + self.DefaultEdgeInsets.top + LastSectionMaxHeight
        }

        attrsArray.frame = CGRect(x: itemX, y: itemY, width: _ItemWidth, height: CGFloat(_ItemHeight))
        columnHeightsAry[minimumInteritemNumber] = attrsArray.frame.maxY
        if contentScope < maximumInteritemHeight {
            self.contentScope = maximumInteritemHeight
            self.contentScope = contentScope + DefaultEdgeInsets.bottom
        }
        return attrsArray
    }
    
    //第三步 ：重写  返回所有列的高度
    override var collectionViewContentSize: CGSize {
        return CGSize.init(width: 0, height: self.contentScope + DefaultEdgeInsets.bottom)
    }
    
    //第四步 ：返回collection的item的frame
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        return attrsArrayArray
    }
    
    private func getconfigData()  {
        guard let contentView = self.collectionView else { return }
        if self.delegate != nil && (self.delegate?.responds(to: #selector(LayoutDelegate.setCellNormalSize(in:))) ?? false) {
            self.DefaultSize = self.delegate?.setCellNormalSize(in: contentView) ?? CGSize.init(width: 50, height: 50)
        }
        if self.delegate != nil && (self.delegate?.responds(to: #selector(LayoutDelegate.rowMarginInWaterFlowLayout(in:))) ?? false){
            self.DefaultColumnCount = self.delegate?.columnCountInWaterFlowLayout?(in: contentView) ?? 0
        }
        if self.delegate != nil && (self.delegate?.responds(to: #selector(LayoutDelegate.defaultColumnMarginInWaterFlowLayout(in:))) ?? false) {
            self.DefaultRowMargin = self.delegate?.defaultColumnMarginInWaterFlowLayout?(in: contentView) ?? 0
        }
        if self.delegate != nil && (self.delegate?.responds(to: #selector(LayoutDelegate.rowMarginInWaterFlowLayout(in:))) ?? false) {
            self.DefaultRowMargin = self.delegate?.rowMarginInWaterFlowLayout?(in: contentView) ?? 0
        }
        
        if self.delegate != nil && (self.delegate?.responds(to: #selector(LayoutDelegate.edgeInsetsInWaterFlowLayout(in:))) ?? false) {
            self.DefaultEdgeInsets = self.delegate?.edgeInsetsInWaterFlowLayout?(in: contentView) ?? UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        if self.delegate != nil && (self.delegate?.responds(to: #selector(LayoutDelegate.specialCellIndexpath(in:))) ?? false ) {
            self.SpecialIndex = self.delegate?.specialCellIndexpath?(in: contentView) ?? IndexPath.init(item: 0, section: 0)
        }
    }
    
    /*
     *  竖向布局: 计算高度最大的是哪一列                 / 横向布局：计算宽度最大的是哪一行
     *
     *  @param  heightArray: 缓存 section 高度的数组  / 缓存 section 宽度的数组
     *  return  返回最大列的列号和高度值                / 返回最大行的行号和宽度值
     */
    fileprivate func maximumInteritemForSection(heightArray: [CGFloat]) -> (Int, CGFloat) {
        if heightArray.count <= 0 {
            return (0, 0.0)
        }
        // 默认第0列的高度最小
        var maximumInteritemNumber = 0
        // 从缓存高度数组中取出第一个元素，作为最小的那一列的高度
        var maximumInteritemHeight = heightArray[0]
        // 遍历数组，查找出最小的列号和最小列的高度值
        for i in 1..<heightArray.count {
            let tempMaximumInteritemHeight = heightArray[i]
            if maximumInteritemHeight < tempMaximumInteritemHeight {
                maximumInteritemHeight = tempMaximumInteritemHeight
                maximumInteritemNumber = i
            }
        }
        return (maximumInteritemNumber, maximumInteritemHeight)
    }
    /*
     *  竖向布局: 计算高度最小的是哪一列                 / 横向布局：计算宽度最小的是哪一行
     *
     *  @param  heightArray: 缓存 section 高度的数组  / 缓存 section 宽度的数组
     *  return  返回最小列的列号和高度值                / 返回最小行的行号和高度值
     */
    fileprivate func minimumInteritemForSection(heightArray: [CGFloat]) -> (Int, CGFloat) {
        if heightArray.count <= 0 {
            return (0, 0.0)
        }
        // 默认第0列的高度最小
        var minimumInteritemNumber = 0
        // 从缓存高度数组中取出第一个元素，作为最小的那一列的高度
        var minimumInteritemHeight = heightArray[0]
        // 遍历数组，查找出最小的列号和最小列的高度值
        for i in 1..<heightArray.count {
            let tempMinimumInteritemHeight = heightArray[i]
            if minimumInteritemHeight > tempMinimumInteritemHeight {
                minimumInteritemHeight = tempMinimumInteritemHeight
                minimumInteritemNumber = i
            }
        }
        return (minimumInteritemNumber, minimumInteritemHeight)
    }
    
}
