//
//  UIColor+Hex.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 01/07/16.
//  Copyright © 2016 Code d'Azur. All rights reserved.
//

import UIKit


extension UIColor {
    /**
     Adds the ability to create a Colour from an hexadecimal code
    */
    convenience init(hex: Int) {
        
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
}