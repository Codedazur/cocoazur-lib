//
//  UILabel+Theme.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 06/07/16.
//  Copyright © 2016 Code d'Azur. All rights reserved.
//

import UIKit


extension UILabel: ThemeStyleable {
    
    private struct AssociatedKeys {
        static var Style = "cda_StyleString";
    }
    
    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0;
        }
        
        // make sure this isn't a subclass
        if self !== UILabel.self {
            return;
        }
        
        dispatch_once(&Static.token) {
            let originalSelector = Selector("setText:");
            let swizzledSelector = #selector(UILabel.cda_setText(_:));
            
            let originalMethod = class_getInstanceMethod(self, originalSelector);
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    }
    
    @IBInspectable var style: String {
        get {
            guard let objc = objc_getAssociatedObject(self, &AssociatedKeys.Style), let valueString: String = objc as? String else {
                objc_setAssociatedObject(self, &AssociatedKeys.Style, "", objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);
                return "";
            }
            return valueString;
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.Style, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }
    
    convenience init(withStyle style: String) {
        self.init();
        self.style = style;
        self.setStyles();
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib();
        self.setStyles();
    }
    
    public func setStyles() {
        Theme.currentTheme?.styleLabel(self, withStyle: style);
    }
    
    
    // MARK: Method Swizzling
    
    @objc func cda_setText(newValue: NSString?) {
        let string: String = newValue == nil ? "" : newValue as! String;
        
        guard let attributedString = Theme.currentTheme?.attributedStringForStyle(self.style, withText: string) else {
            self.cda_setText(newValue)
            return;
        }
        
        self.attributedText = attributedString;
    }
}
//extension UILabel: ThemeStyleable {
//    
//}