//
//  ExampleTheme.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 20/07/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Cocoazur_Core
//import Cocoazur_Core


class ExampleTheme: Themeable {
    
    // MARK: Themeable functions
    
    func styleLabel(label: UILabel, withStyle style: String) {
        let textStyle = TextStyleExample(rawValue: style);
        switch textStyle {
            
        case .Header:
            label.textColor = ColorExample.Primary.colorValue();
            break;
            
        case .Body:
            label.textColor = ColorExample.Secondary.colorValue();
            break;
            
        case .ThumbnailSubtitle:
            label.textColor = ColorExample.Tertiary.colorValue();
            break;
            
        case .Link:
            label.textColor = ColorExample.Secondary.colorValue();
            break;
            
        case .LinkActive:
            label.textColor = ColorExample.Primary.colorValue();
            break;
            
        default:
            // Do nothing
            break;
        }
        
        guard let font = self.getFontForTextStyle(style) else {
            return;
        }
        
        label.font = font;
    }
    
    func styleTextView(textView: UITextView, withStyle style: String) {
        
    }
    
    func styleTextField(textField: UITextField, withStyle style: String) {
        
    }
    
    func styleButton(button: UIButton, withStyle style: String) {
        
    }
    
    func getFontForTextStyle(style: String) -> UIFont? {
        let textStyle = TextStyleExample(rawValue: style);
        switch textStyle {
            case .Header, .Link, .LinkActive:
                return self.verdanaBoldFontWithSize(13);
                
            case .Body:
                return self.verdanaRegularFontWithSize(13);
                
            case .ThumbnailSubtitle:
                return self.verdanaBoldFontWithSize(9);
                
            default:
                return nil;
        }
    }
    
    func attributedStringForStyle(style: String, withText text: String) -> NSAttributedString? {
        
    }
    
    func attributedStringForStyle(style: String, withText text: String, withRange: NSRange) -> NSAttributedString? {
        
    }
    
    
    // MARK: Private functions
    
    private func verdanaRegularFontWithSize(size: CGFloat) -> UIFont? {
        return UIFont(name: "Verdana", size: size);
    }
    
    private func verdanaBoldFontWithSize(size: CGFloat) -> UIFont? {
        return UIFont(name: "Verdana-Bold", size: size);
    }
}

enum ColorExample: Int, EnumColorable {
    case Primary = 0x171717;
    case Secondary = 0x6e6e6e;
    case Tertiary = 0xffffff;
    case Accessory = 0xe0e0e0;
}

enum TextStyleExample: String {
    case Header;
    case Body;
    case ThumbnailSubtitle;
    case Link;
    case LinkActive;
}