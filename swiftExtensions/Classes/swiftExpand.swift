//
//  swiftExpand.swift
//  swiftEx
//
//  Created by zyfMac on 2022/10/29.
//

import Foundation
import UIKit
import AVFoundation
import CommonCrypto

extension UIView {
    var currVC : UIViewController?{
        for view in sequence(first: superview, next: { $0?.superview}) {
            if let responder = view?.next , responder.isKind(of: UIViewController.self) {
                return responder as? UIViewController
            }
        }
        return nil
    }
}

extension UITableViewCell {
    private func _tableView() ->UITableView?{
        if let tableView = self.superview as? UITableView {
            return tableView
        }
        if let tableView = self.superview?.superview as? UITableView {
            return tableView
        }
        return nil
    }
    func cellSeparatorAligning() {
        if(self.responds(to: #selector(setter: UITableViewCell.separatorInset))) {
            self.separatorInset = UIEdgeInsets.zero
        }
        if(self.responds(to: #selector(setter: UIView.layoutMargins))) {
            self.layoutMargins = UIEdgeInsets.zero
        }
    }
    //画圆角
    func addSectionCorner(indexPath : IndexPath, radius : CGFloat = 10 , headerView : UIView? = nil) {
        let tableView  = self._tableView()!
        //每个区多少行
        let sectionNum = tableView.numberOfRows(inSection: indexPath.section)
        //遮罩实现
        let shapeLayer = CAShapeLayer()
        self.layer.mask = nil
        if sectionNum > 1 { //当前分区有多行数据时
            if indexPath.row == 0 {
                //如果是第一行,左上、右上角为圆角
                var bounds = self.bounds
                bounds.origin.y += 1.0 //这样每一组首行顶部分割线不显示
                var bezierPath : UIBezierPath?
                if headerView == nil {
                    bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize.init(width: radius, height: radius))
                }else{
                    bezierPath = UIBezierPath.init(rect: bounds)
                }
                shapeLayer.path = bezierPath?.cgPath
                self.layer.mask = shapeLayer
            }else if indexPath.row == sectionNum - 1 {
                var bounds =  self.bounds
                bounds.size.height -= 1.0  //这样每一组尾行底部分割线不显示
                let bezierPath = UIBezierPath(roundedRect: bounds,byRoundingCorners: [.bottomLeft,.bottomRight],cornerRadii: CGSize(width: radius,height: radius))
                shapeLayer.path = bezierPath.cgPath
                self.layer.mask = shapeLayer
            }else{
                //中间为矩形
                var bounds =  self.bounds
                bounds.size.height -= 1.0
                let bezierPath = UIBezierPath.init(rect: bounds)
                shapeLayer.path = bezierPath.cgPath
                self.layer.mask = shapeLayer
            }
        }else { //分区只有一行数据的时候
            
            //四个角都为圆角（同样设置偏移隐藏首、尾分隔线）
            //            let bezierPath = UIBezierPath(roundedRect:
            //                                            self.bounds.insetBy(dx: 0.0, dy: 2.0),
            //                                          cornerRadius: radius)
            var bezierPath : UIBezierPath?
            if headerView != nil {
                bezierPath = UIBezierPath(roundedRect: bounds,
                                          byRoundingCorners: [.bottomLeft,.bottomRight],
                                          cornerRadii: CGSize(width: radius,height: radius))
            }else{
                bezierPath = UIBezierPath(roundedRect:
                                            self.bounds.insetBy(dx: 0.0, dy: 2.0),
                                          cornerRadius: radius)
            }
            
            shapeLayer.path = bezierPath?.cgPath
            self.layer.mask = shapeLayer
            
        }
        
    }
    
    
}
extension Array where Element : Equatable {
    
    mutating func remove(_ value: Element) {
        if let index = firstIndex(of: value) {
            remove(at: index)
        }
    }
    
    mutating func remove(_ values: [Element]) {
        for item in values {
            remove(item)
        }
    }
}


public extension UITableView {
    
    /// Register UITableViewCell
    func register<T: UITableViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: name))
    }
    
    /// dequeue reusable UITableViewCell using class name
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: name)) as? T else {
            fatalError("Couldn't find UITableViewCell for \(String(describing: name)), make sure the cell is registered with table view")
        }
        return cell
    }
    
    /// dequeue reusable UITableViewCell using class name for indexPath
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError("Couldn't find UITableViewCell for \(String(describing: name)), make sure the cell is registered with table view")
        }
        return cell
    }
}

public extension UICollectionView {
    
    func register(_ cellClass: AnyClass?, for identifier: String) {
        register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    func register(_ cellClass: AnyClass) {
        register(cellClass, for: "\(cellClass)")
    }
    
//    func registerSectionHeader(_ viewClass: AnyClass?, identifier: String) {
//        register(viewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
//    }
//
//    func registerSectionHeader(_ viewClass: AnyClass) {
//        registerSectionHeader(viewClass, identifier: "\(viewClass)")
//    }
//
//    func registerSectionFooter(_ viewClass: AnyClass?, identifier: String) {
//        register(viewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
//    }
//
//    func registerSectionFooter(_ viewClass: AnyClass) {
//        registerSectionFooter(viewClass, identifier: "\(viewClass)")
//    }
//
//    func reusableView(ofKind elementKind: String, for indexPath: IndexPath) -> UICollectionReusableView {
//        return dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: "UICollectionReusableView", for: indexPath)
 //   }
}

public extension UICollectionView {
    
    func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, identifier: String, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionViewCell for \(identifier), make sure the cell is registered with collection view")
        }
        return cell
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionViewCell for \(String(describing: name)), make sure the cell is registered with collection view")
        }
        return cell
    }
    
//    func dequeueSectionHeader<T: UICollectionReusableView>(withClass name: T.Type, identifier: String, for indexPath: IndexPath) -> T {
//        guard let cell = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier, for: indexPath) as? T else {
//            fatalError("Couldn't find UICollectionReusableView for \(identifier), make sure the view is registered with collection view")
//        }
//        return cell
//    }
//
//    func dequeueSectionHeader<T: UICollectionReusableView>(withClass name: T.Type, for indexPath: IndexPath) -> T {
//        guard let cell = dequeueReusableSupplementaryView(ofKind:  UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: name), for: indexPath) as? T else {
//            fatalError("Couldn't find UICollectionReusableView for \(String(describing: name)), make sure the view is registered with collection view")
//        }
//        return cell
//    }
//
//    func dequeueSectionFooter<T: UICollectionReusableView>(withClass name: T.Type, identifier: String, for indexPath: IndexPath) -> T {
//        guard let cell = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier, for: indexPath) as? T else {
//            fatalError("Couldn't find UICollectionReusableView for \(identifier), make sure the view is registered with collection view")
//        }
//        return cell
//    }
//
//    func dequeueSectionFooter<T: UICollectionReusableView>(withClass name: T.Type, for indexPath: IndexPath) -> T {
//        guard let cell = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: name), for: indexPath) as? T else {
//            fatalError("Couldn't find UICollectionReusableView for \(String(describing: name)), make sure the view is registered with collection view")
//        }
//        return cell
//    }
//
//    func defaultReusableView(ofKind elementKind: String, for indexPath: IndexPath) -> UICollectionReusableView {
//        return dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: "UICollectionReusableView", for: indexPath)
//    }
}

extension String {
    var image : UIImage?{
        return UIImage(named: self)
    }
    
    var urlEncoding: String {
        if isEmpty { return "" }
        let urlDecod = urlDecoding // 先解码，防止链接二次编码导致链接打不开
        guard let encodeUrlString = urlDecod.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ""
        }
        return encodeUrlString
    }
    
    var urlDecoding: String {
        if isEmpty { return "" }
        guard let decodingUrl = self.removingPercentEncoding else { return "" }
        return decodingUrl
    }
//    func getVideoFirstIcon() -> UIImage? {
//        guard let videoUrl = URL(string: self) else { return nil }
//        let asset = AVURLAsset(url: videoUrl, options: nil)
//        let assetGen = AVAssetImageGenerator(asset: asset)
//        assetGen.appliesPreferredTrackTransform = true
//        //let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 1)
//
//        let time = CMTimeMake(0, 600)
//
//        do {
//            let image = try assetGen.copyCGImage(at: time, actualTime: nil)
//            return UIImage(cgImage: image)
//        } catch {
//            return nil
//        }
//    }
    
    func getContentHeight(_ font : UIFont , _ width : CGFloat) -> CGFloat {
        let contentH  = NSString.init(string: self).boundingRect(with: CGSize.init(width: width, height: CGFloat(MAXFLOAT)), options: [.usesFontLeading,.usesLineFragmentOrigin], attributes: [.font : font], context: nil).size.height
        return  ceil(contentH)
    }
}

extension UIScrollView {
    //截屏
    func snapshotScreen()-> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.contentSize, false, UIScreen.main.scale)
        let savedContentOffset = self.contentOffset
        let savedFrame = self.frame
        let contentSize = self.contentSize
        let oldBounds = self.layer.bounds
        if #available(iOS 13.0, *) {
            self.layer.bounds = CGRect.init(x: oldBounds.origin.x, y: oldBounds.origin.y, width: contentSize.width, height: contentSize.height + 20)
        }
        self.contentOffset = .zero
        self.frame = CGRect.init(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height + 20)
        
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        if #available(iOS 13.0, *) {
            self.layer.bounds = oldBounds
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.contentOffset = savedContentOffset
        self.frame = savedFrame
        self.contentOffset = savedContentOffset
        
        return image!
    }
    //滑动到最底部
    
    func scrollToBottom() {
        let offset = contentSize.height - bounds.size.height
        setContentOffset(CGPoint(x: 0, y: offset > 0 ? offset : 0), animated: true)
    }
    
}


extension UIApplication {
    
    
    /// 获取状态栏高度
    var statusBarHeight: CGFloat {
        return statusBarFrame.size.height
    }
    
    /// 获取导航栏 + 状态栏高度
    var navigationBarHeight: CGFloat {
        return statusBarFrame.size.height + 44.0
    }
    
    
    
    
    var currentWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            if let window = connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first{
                return window
            }else if let window = UIApplication.shared.delegate?.window{
                return window
            }else{
                return nil
            }
        } else {
            if let window = UIApplication.shared.delegate?.window{
                return window
            }else{
                return nil
            }
        }
    }
}
extension String {
    var md5: String {
        get {
            let ccharArray = self.cString(using: String.Encoding.utf8)
            var uint8Array = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(ccharArray, CC_LONG(ccharArray!.count - 1), &uint8Array)
            return uint8Array.reduce("") { $0 + String(format: "%02x", $1)}
        }
    }
}


// MARK: - 字符串截取
extension String {
    /// String使用下标截取字符串
    /// string[index] 例如："abcdefg"[3] // c
    subscript (i:Int)->String{
        let startIndex = self.index(self.startIndex, offsetBy: i)
        let endIndex = self.index(startIndex, offsetBy: 1)
        return String(self[startIndex..<endIndex])
    }
    /// String使用下标截取字符串
    /// string[index..<index] 例如："abcdefg"[3..<4] // d
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }
    /// String使用下标截取字符串
    /// string[index,length] 例如："abcdefg"[3,2] // de
    subscript (index:Int , length:Int) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(startIndex, offsetBy: length)
            return String(self[startIndex..<endIndex])
        }
    }
    // 截取 从头到i位置
    func substring(to:Int) -> String{
        return self[0..<to]
    }
    // 截取 从i到尾部
    func substring(from:Int) -> String{
        return self[from..<self.count]
    }
    
}

