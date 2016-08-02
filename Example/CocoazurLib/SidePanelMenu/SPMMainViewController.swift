//
//  SPMMainViewController.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 02/08/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Cocoazur_SidePanelMenu

class SPMMainViewController: UIViewController, MenuPresentable {
    
    let transitionManager = MenuTransitionManager<SPMMainViewController, SPMMenuViewController>(withInteractionAt: .Right);
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.transitionManager.mainViewController = self;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentMenu" {
            self.transitionManager.menuViewController = segue.destinationViewController as? SPMMenuViewController;
        }
    }

    func showMenu() {
        self.performSegueWithIdentifier("PresentMenu", sender: self);
    }
    
    @IBAction func unwindSegue(sender: UIStoryboardSegue) {
        
    }
    
}
