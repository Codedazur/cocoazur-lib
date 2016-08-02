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
        guard let textStyle = TextStyleExample(rawValue: style) else {
            return;
        }
        switch textStyle {
            
        case .Header:
            label.textColor = ColorExample.Primary.colorValue();
            
        case .Body:
            label.textColor = ColorExample.Secondary.colorValue();
            
        case .ThumbnailSubtitle:
            label.textColor = ColorExample.Tertiary.colorValue();
            
        case .Link:
            label.textColor = ColorExample.Secondary.colorValue();
            
        case .LinkActive:
            label.textColor = ColorExample.Primary.colorValue();
        }
        
        guard let font = self.getFontForTextStyle(style) else {
            return;
        }
        
        label.font = font;
    }
    
    func styleTextView(textView: UITextView, withStyle style: String) {
        guard let font = self.getFontForTextStyle(style) else {
            return;
        }
        
        textView.font = font;
    }
    
    func styleTextField(textField: UITextField, withStyle style: String) {
        guard let font = self.getFontForTextStyle(style) else {
            return;
        }
        
        textField.font = font;
    }
    
    func styleButton(button: UIButton, withStyle style: String) {
        guard let font = self.getFontForTextStyle(style), let titleLabel = button.titleLabel else {
            return;
        }
        
        titleLabel.font = font;
    }
    
    func getFontForTextStyle(style: String) -> UIFont? {
        guard let textStyle = TextStyleExample(rawValue: style) else {
            return nil;
        }
        
        switch textStyle {
            case .Header, .Link, .LinkActive:
                return self.verdanaBoldFontWithSize(13);
                
            case .Body:
                return self.verdanaRegularFontWithSize(13);
                
            case .ThumbnailSubtitle:
                return self.verdanaBoldFontWithSize(9);
        }
    }
    
    func attributedStringForStyle(style: String, withText text: String) -> NSAttributedString? {
        let wholeTextRange = NSMakeRange(0, text.characters.count);
        return attributedStringForStyle(style, withText: text, withRange: wholeTextRange);
    }
    
    func attributedStringForStyle(style: String, withText text: String, withRange: NSRange) -> NSAttributedString? {
        guard let font = self.getFontForTextStyle(style) else {
            return nil;
        }
        
        let attributedString = NSMutableAttributedString(string: text);
        let paragraphStyle = NSMutableParagraphStyle();
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: withRange);
        attributedString.addAttribute(NSFontAttributeName, value: font, range: withRange);
        
        return attributedString;
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
    case Tertiary = 0xe0e0e0;
    case Accessory = 0xffffff;
}

enum TextStyleExample: String {
    case Header;
    case Body;
    case ThumbnailSubtitle;
    case Link;
    case LinkActive;
}