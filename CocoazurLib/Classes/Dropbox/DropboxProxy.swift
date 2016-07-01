//
//  DropboxProxy.swift
//  Pods
//
//  Created by Tamara Bernad on 01/07/16.
//
//

import Foundation
import SwiftyDropbox
import UIKit

class DropboxFile{
    var id:String = "";
    var path:String = "";
    var folder:String = "";
    var reupload:Bool = false;
    var name:String{
        get{
            return (path as NSString).lastPathComponent
        }
    }
    
//    init(path:, check)
//    class func makeFile(with path:String){
//        return DropboxFile(path, false)
//    }
}
protocol DropboxProxyDelegate:class{
    func dropboxProxy(_:DropboxProxy, hasChangedSinceDate:NSDate)->Bool
}
class DropboxProxy{
    var check:Bool = false;
    weak var delegate:DropboxProxyDelegate?
    /*
 
     - shareable link per uploaded file
     - shareable link to uploaded folder
     - upload to folder
     - upload to root
 */
    
//    func upload(files:[DropboxFile], using context:UIViewController, folder:String = "")->Void{
//    }
    func upload(files:[DropboxFile], using context:UIViewController, folder:String = "")->Void{
        if let client = Dropbox.authorizedClient {
            
            let filesToUpload = getFilesToUpload(files, client: client, completion: { (files) in
                let req:BabelUploadRequest = client.files.uploadSessionStart(body: NSURL())
                
            });
            
            
            
        }else{
            Dropbox.authorizeFromController(context)
        }
    }

    // Mark: helpers
    func getFilesToUpload(files:[DropboxFile], client:DropboxClient, completion: (_: [DropboxFile]) -> Void)->Void{
        var filesToUpload:[DropboxFile] = []
        var index = 0
        let checkFinished = {
            if(index == files.count - 1){
                completion(filesToUpload)
            }
        }
        for dbFile in files {
            
            if(!dbFile.reupload){
                let destination = dbFile.folder.stringByAppendingString(dbFile.name)
                client.files.getMetadata(path: destination).response { response, error in
                    if let metadata = response {
                        if let file = metadata as? Files.FileMetadata {
                            if((self.delegate?.dropboxProxy(self, hasChangedSinceDate: file.serverModified)) != nil){
                                filesToUpload.append(dbFile)
                            }
                        }
                    } else {
                        print(error!)
                        filesToUpload.append(dbFile)
                    }
                    index++
                    checkFinished()
                }
            }else{
                filesToUpload.append(dbFile)
                index++
                checkFinished()
            }
        }
    }

}




