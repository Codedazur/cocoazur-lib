//
//  Example2Theme.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 20/07/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Cocoazur_Core
//import Cocoazur_Core


class Example2Theme: Themeable {
    
    // MARK: Themeable functions
    
    func styleLabel(label: UILabel, withStyle style: String) {
        guard let textStyle = TextStyleExample2(rawValue: style) else {
            return;
        }
        switch textStyle {
            
        case .Header:
            label.textColor = ColorExample2.Primary.colorValue();
            
        case .Body:
            label.textColor = ColorExample2.Secondary.colorValue();
            
        case .ThumbnailSubtitle:
            label.textColor = ColorExample2.Tertiary.colorValue();
            
        case .Link:
            label.textColor = ColorExample2.Secondary.colorValue();
            
        case .LinkActive:
            label.textColor = ColorExample2.Primary.colorValue();
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
        guard let textStyle = TextStyleExample2(rawValue: style) else {
            return nil;
        }
        
        switch textStyle {
        case .Header, .Link, .LinkActive:
            return self.boldFontWithSize(17);
            
        case .Body:
            return self.regularFontWithSize(14);
            
        case .ThumbnailSubtitle:
            return self.boldFontWithSize(11);
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
    
    private func regularFontWithSize(size: CGFloat) -> UIFont? {
        return UIFont(name: "Kailasa", size: size);
    }
    
    private func boldFontWithSize(size: CGFloat) -> UIFont? {
        return UIFont(name: "Kailasa-Bold", size: size);
    }
}

enum ColorExample2: Int, EnumColorable {
    case Primary = 0xff5555;
    case Secondary = 0x333333;
    case Tertiary = 0x55ff55;
    case Accessory = 0xffffff;
}

enum TextStyleExample2: String {
    case Header;
    case Body;
    case ThumbnailSubtitle;
    case Link;
    case LinkActive;
}