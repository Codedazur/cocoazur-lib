//
//  EnumColorable.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 06/07/16.
//  Copyright © 2016 Code d'Azur. All rights reserved.
//

import UIKit


/**
 Gives the ability to create a UIColor from the raw value (in case of enum int)
 */
protocol EnumColorable : RawRepresentable {}
extension EnumColorable {
    func colorValue() -> UIColor? {
        if let hex: Int = self.rawValue as? Int {
            return UIColor(hex: hex);
        }
        else {
            return nil;
        }
    }
}
