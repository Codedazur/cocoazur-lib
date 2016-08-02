//
//  MenuDismissable.swift
//  SidePanelMenu
//
//  Created by Gerardo Garrido on 28/07/16.
//  Copyright © 2016 Code d'Azur. All rights reserved.
//

import UIKit

public protocol MenuDismissable {
    var contentView: UIView? { get }
    
    func hideMenu();
}