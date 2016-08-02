//
//  SPMMenuViewController.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 02/08/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Cocoazur_SidePanelMenu

class SPMMenuViewController: UIViewController, MenuDismissable {
    
    @IBOutlet var contentView: UIView?

    func hideMenu() {
        self.performSegueWithIdentifier("DismissMenu", sender: self);
    }
    
}
