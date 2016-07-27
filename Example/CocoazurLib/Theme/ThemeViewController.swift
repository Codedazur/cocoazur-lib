//
//  ThemeViewController.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 27/07/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Cocoazur_Core

class ThemeViewController: UIViewController {
    @IBOutlet weak var btChangeStyle: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // I don't know why but XCode doesn't let me create a IBAction for the button
        self.btChangeStyle.addTarget(self, action: #selector(ThemeViewController.onChangeStyleTap), forControlEvents: .TouchUpInside);
        
        self.changeTheme();
    }
    
    
    // MARK: Actions
    
    func onChangeStyleTap() {
        self.changeTheme();
    }
    
    
    // MARK: Private
    
    private func changeTheme() {
        if Theme.currentTheme is ExampleTheme {
            Theme.currentTheme = Example2Theme();
        }
        else {
            Theme.currentTheme = ExampleTheme();
        }
        self.setStyles();
    }
    
    private func setStyles() {
        for view in self.view.subviews {
            if let styleableView = view as? ThemeStyleable {
                styleableView.setStyles();
            }
        }
    }
    
}
