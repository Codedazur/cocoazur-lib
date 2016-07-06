//
//  ViewController.swift
//  CocoazurLib
//
//  Created by Tamara Bernad on 06/30/2016.
//  Copyright (c) 2016 Tamara Bernad. All rights reserved.
//

import UIKit
import Cocoazur_Dropbox

class ViewController: UIViewController {

    var dbProxy:DropboxProxy = DropboxProxy()
    override func viewDidLoad() {
        super.viewDidLoad()
        DropboxProxy.setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onDropboxTap(sender: AnyObject) {
        dbProxy = DropboxProxy()
        guard let path = NSBundle.mainBundle().pathForResource("code-dazur-logo", ofType: "svg") else {return}
        
        let f = DropboxFile()
        f.path = path
        f.reupload = true
        
        dbProxy.upload([f], using: self, to: "", returning: DropBoxResultType.None) { (shareableLinks) in
            
        }
    }
}

