//
//  iOSExtention.swift
//  AiToolbox
//
//  Created by 黄龙 on 2023/4/18.
//

import Foundation
import UIKit

let screen_W = UIScreen.main.bounds.width
let screen_H = UIScreen.main.bounds.height
//以375*667为基数的宽高比例
let _SCALE_HEIGHT_UNIT =  screen_H/667
let _SCALE_WIDTH_UNIT  =   screen_W/375


extension UIColor{
    public convenience init(_ hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }

    public convenience init(hexString: String, alpha: Float = 1.0) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var mAlpha: CGFloat = CGFloat(alpha)
        var minusLength = 0

        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
            minusLength = 1
        }
        if hexString.hasPrefix("0x") {
            scanner.scanLocation = 2
            minusLength = 2
        }
        var hexValue: UInt64 = 0
        scanner.scanHexInt64(&hexValue)
        switch hexString.count - minusLength {
        case 3:
            red = CGFloat((hexValue & 0xF00) >> 8) / 15.0
            green = CGFloat((hexValue & 0x0F0) >> 4) / 15.0
            blue = CGFloat(hexValue & 0x00F) / 15.0
        case 4:
            red = CGFloat((hexValue & 0xF000) >> 12) / 15.0
            green = CGFloat((hexValue & 0x0F00) >> 8) / 15.0
            blue = CGFloat((hexValue & 0x00F0) >> 4) / 15.0
            mAlpha = CGFloat(hexValue & 0x000F) / 15.0
        case 6:
            red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(hexValue & 0x0000FF) / 255.0
        case 8:
            red = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
            mAlpha = CGFloat(hexValue & 0x000000FF) / 255.0
        default:
            break
        }
        self.init(red: red, green: green, blue: blue, alpha: mAlpha)
    }
}

extension String {
    
    public var color: UIColor {
        return UIColor(hexString: self)
    }
    
    public func base64DecodeUrlSafe() -> String? {
        if let _ = self.range(of: ":")?.lowerBound {
            return self //如果已有:，表示该str已为明文，无需再decode
        }
        let base64String = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        let padding = base64String.count + (base64String.count % 4 != 0 ? (4 - base64String.count % 4) : 0)
        if let decodedData = Data(base64Encoded: base64String.padding(toLength: padding, withPad: "=", startingAt: 0), options: NSData.Base64DecodingOptions(rawValue: 0)), let decodedString = NSString(data: decodedData, encoding: String.Encoding.utf8.rawValue) {
            return decodedString as String
        }
        return nil
    }
    
    public func base64DecodeStr() -> String?{
        let base64String = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        let padding = base64String.count + (base64String.count % 4 != 0 ? (4 - base64String.count % 4) : 0)
        if let decodedData = Data(base64Encoded: base64String.padding(toLength: padding, withPad: "=", startingAt: 0), options: NSData.Base64DecodingOptions(rawValue: 0)), let decodedString = NSString(data: decodedData, encoding: String.Encoding.utf8.rawValue) {
            return decodedString as String
        }
        return nil
    }
}

extension UIColor{
//默认白色背景，在黑暗模式下为黑色
    public class var whiteBackColor:  UIColor {
        get{
            if #available(iOS 13.0, *){
                return .systemBackground
            }else{
                return .white
            }
        }
    }
    
//暗灰背景
    public class var grayBackColor:  UIColor {
        get{
            if #available(iOS 13.0, *){
                return .secondarySystemBackground
            }else{
                return .systemGray
            }
        }
    }
    
//默认黑色字体，在黑暗模式下为白色字体
    public class var blackTextColor:  UIColor {
        get{
            if #available(iOS 13.0, *){
                return .label
            }else{
                return .black
            }
        }
    }
    
}


extension UIDevice {
    static func autoSacle_Width(_ width:CGFloat)->CGFloat{
        return width * _SCALE_WIDTH_UNIT
    }
    static func autoSacle_Height(_ height:CGFloat)->CGFloat{
        return height * _SCALE_HEIGHT_UNIT
    }
    
    /// 顶部安全区高度
    static func ui_safeDistanceTop() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else {
                guard let statusBarManager = windowScene.statusBarManager else { return 0 }
                return statusBarManager.statusBarFrame.height //在SenceDelegate里创建window时，xR亦为48
            }
            return window.safeAreaInsets.top
            //xr上safeAreaInsets(t=48,l=0,b=34,r=0)(prefersStatusBarHidden=true隐藏状态栏情况下亦是),
            //但前提是在didFinishLaunchingWithOptions里创建window
            //如果是在SenceDelegate里创建window,xr上safeAreaInsets(t=0,l=0,b=0,r=0)
        } else{
            guard let window = UIApplication.shared.windows.first else { return 0 }
            var _top = window.safeAreaInsets.top
            //iphone6.iOS12下：safeAreaInsets(t=20,l=0,b=0,r=0),
            //但prefersStatusBarHidden=true隐藏状态栏情况下：safeAreaInsets(t=0,l=0,b=0,r=0)
            if _top<1 {
                _top = 34.0
            }
            return _top
        }
    }
    
    /// 底部安全区高度
    static func ui_safeDistanceBottom() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        } else {//if #available(iOS 11.0, *)
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        }
//        return 0;
    }
    
    /// 顶部状态栏高度（包括安全区）
    static func ui_statusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let statusBarManager = windowScene.statusBarManager else { return 0 }
            statusBarHeight = statusBarManager.statusBarFrame.height
            //xr=48 (即使是prefersStatusBarHidden=true隐藏状态栏情况下,也=48)
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
            //iphone6.iOS12下=20，但prefersStatusBarHidden=true隐藏状态栏情况下=0
        }
        return statusBarHeight
    }
    
//!!!!所以发现通过系统参数获取，情况太多，还不如能过机型来判断更可靠？
    
    /// 导航栏高度
    static func ui_navigationBarHeight() -> CGFloat {
        return 44.0
    }
    
    /// 状态栏+导航栏的高度
    static func ui_navigationFullHeight() -> CGFloat {
        return UIDevice.ui_statusBarHeight() + UIDevice.ui_navigationBarHeight()
    }
    
    /// 底部导航栏高度
    static func ui_tabBarHeight() -> CGFloat {
        return 49.0
    }
    
    /// 底部导航栏高度（包括安全区）
    static func ui_tabBarFullHeight() -> CGFloat {
        return UIDevice.ui_tabBarHeight() + UIDevice.ui_safeDistanceBottom()
    }
}

/*
 button点击事件封装
 */
extension UIButton {
      // 定义关联的Key
      private struct UIButtonKeys {
         static var clickKey = "UIButton+Extension+ActionKey"
      }
      
      func addActionWithBlock(_ closure: @escaping (_ sender:UIButton)->()) {
//把闭包作为一个值 先保存起来;
//@escaping定义逃逸类型的闭包，
//如果一个闭包被作为一个参数传递给一个函数，并且在函数return之后才被唤起执行，那么这个闭包是逃逸闭包。
/*
 关联是指把两个对象相互关联起来，使得其中的一个对象作为另外一个对象的一部分。
 其本质是在类的定义之外为类增加额外的存储空间。
 
 使用关联，我们可以不用修改类的定义而为其对象增加存储空间。
 这在我们无法访问到类的源码的时候，或者是考虑到二进制兼容性的时候，非常有用。
 关联是基于关键字的，因此，我们可以为任何对象增加任意多的关联，每个都使用不同的关键字即可。
 关联是可以保证被关联的对象在关联对象的整个生命周期都是可用的（在垃圾自动回收环境下也不会导致资源不可回收）。
 
 objc_setAssociatedObject为OC的运行时函数
 void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
 id object                     :表示关联者，是一个对象，变量名理所当然也是object
 const void *key               :获取被关联者的索引key
 id value                      :被关联者，这里是一个block
 objc_AssociationPolicy policy :关联时采用的协议，有assign，retain，copy等协议，一般使用OBJC_ASSOCIATION_RETAIN_NONATOMIC
 关键字 : 是一个void类型的指针。每一个关联的关键字必须是唯一的。通常都是会采用静态变量来作为关键字。
 关联策略表明了相关的对象是通过赋值(assign)，保留引用(retain)还是复制(copy)的方式进行关联的；
 还有这种关联是原子的还是非原子的。这里的关联策略和声明属性时的很类似。这种关联策略是通过使用预先定义好的常量来表示的。
*/
         objc_setAssociatedObject(self, &UIButtonKeys.clickKey, closure, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
/*
1、  OBJC_ASSOCIATION_ASSIGN              相当于weak
2 、 OBJC_ASSOCIATION_RETAIN_NONATOMIC    相当于strong和nonatomic
3、  OBJC_ASSOCIATION_COPY_NONATOMIC      相当于copy和nonatomic
4、  OBJC_ASSOCIATION_RETAIN              相当于strong和atomic
5、  OBJC_ASSOCIATION_COPY                相当于copy和atomic
 */
        
//给按钮添加传统的点击事件，调用写好的方法
         self.addTarget(self, action: #selector(my_ActionForTapGesture), for: .touchUpInside)
      }
    
      @objc private func my_ActionForTapGesture() {
         //获取闭包值
         let obj = objc_getAssociatedObject(self, &UIButtonKeys.clickKey)
         if let action = obj as? (_ sender:UIButton)->() {
             //调用闭包
             action(self)
         }
      }
}

extension UIView{
//任意角的圆角
     func easyRoundRect(bounds: CGRect,corner: UIRectCorner, radii: CGSize)-> CALayer{
       let maskPath = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: radii)
       let maskLayer = CAShapeLayer.init()
       maskLayer.frame = bounds
       maskLayer.path = maskPath.cgPath
       return maskLayer
    }
// 使用eg：label.layer.mask = easyRoundRect(...)
}

extension String {
    
    var totoImage: UIImage? {
        return UIImage(named: self)
    }
    
    var totoTemplateImage: UIImage? {
        return UIImage(named: self)?.withRenderingMode(.alwaysTemplate)
    }
    
    var totoOriginalImage: UIImage? {
        return UIImage(named: self)?.withRenderingMode(.alwaysOriginal)
    }

}

extension UIScrollView{
    func removeTopBlankHeadArea(){
//消除顶部空白行
        if #available(iOS 13.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
    }
    
}


/// 打印异常
public func printError(_ modelName:String, _ description: String) {
    #if DEBUG
        print("ERROR: \(modelName) catch an error '\(description)' \n")
    #endif
}
/// 打印日志
public func printMsg(_ modelName:String, _ description: String) {
    #if DEBUG
        print("\(modelName).info: '\(description)' \n")
    #endif
}
