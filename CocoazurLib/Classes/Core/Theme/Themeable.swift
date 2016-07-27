
//
//  Themeable.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 30/06/16.
//  Copyright © 2016 Code d'Azur. All rights reserved.
//

import UIKit


public protocol Themeable {
    func styleLabel(label: UILabel, withStyle style: String);
    func styleTextView(textView: UITextView, withStyle style: String);
    func styleTextField(textField: UITextField, withStyle style: String);
    func styleButton(button: UIButton, withStyle style: String);
    func getFontForTextStyle(style: String) -> UIFont?;
    func attributedStringForStyle(style: String, withText text: String) -> NSAttributedString?;
    func attributedStringForStyle(style: String, withText text: String, withRange: NSRange) -> NSAttributedString?;
}


