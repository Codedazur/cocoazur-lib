//
//  ImplementationError.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 05/07/16.
//  Copyright © 2016 Code d'Azur. All rights reserved.
//

import Foundation

enum ImplementationError: ErrorType {
    case Abstract
    
    static func abstract () {
        assert(false, "Abstract class: this function needs to be implemented, not called directly");
    }
}
