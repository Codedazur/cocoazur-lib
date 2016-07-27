//
//  UITextField+Theme.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 06/07/16.
//  Copyright © 2016 Code d'Azur. All rights reserved.
//

import UIKit

public extension UITextField {
    
    private struct AssociatedKeys {
        static var Style = "cda_StyleString";
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
    
    func setStyles() {
        Theme.currentTheme?.styleTextField(self, withStyle: style);
    }
}
