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

enum DropBoxResultType:String{
    case None
    case SingleLink
    case MultipleLinks
}
class DropboxFile{
    var id:String = "";
    var path:String = "";
    var folder:String = "";
    var reupload:Bool = false;
    var modifiedAt:NSDate = NSDate()
    var name:String{
        get{
            return (path as NSString).lastPathComponent
        }
    }
    var remotePath:String{
        get{
            return path.stringByAppendingString("/").stringByAppendingString(name)
        }
    }
}
protocol DropboxProxyDelegate:class{
    
}
class DropboxProxy{
    private var completedUploads = 0
    private var totalUplads = 0
    private var currentUploadProgress = 0.0
    
    
    public var progress:Double{
        get{
            return (Double(completedUploads) + currentUploadProgress)/Double(totalUplads)
        }
    }
    public weak var delegate:DropboxProxyDelegate?
    /*
 
     - shareable link per uploaded file
     - shareable link to uploaded folder
     - upload to folder
     - upload to root
 */
    
    func upload(files:[DropboxFile], using context:UIViewController,to folder:String = "", returning type:DropBoxResultType = .None, completion: (shareableLinks: [String]) -> Void)->Void{
        totalUplads = files.count
        let checkFinished = {[weak self] in
            guard let completed = self?.completedUploads, let total = self?.totalUplads else{
                return;
            }
            if(completed == total-1){
                completion(shareableLinks: [])
            }
        }
        if let client = Dropbox.authorizedClient {
            
            var shareableLinks:[String] = []
            getFilesToUpload(files, client: client, completion: {[weak self] (files) in
                
                for file in files{
                    self?.upload(file, with: client, completion: {[weak self] (filePath) in
                        
                        if(type != .None){
                            
                            guard let remotePath = self?.remoteShareablePath(type, current: file, all: files, to: folder), let ask = self?.shouldAskForShareableLink(type) else{
                                self?.completedUploads++
                                checkFinished()
                                return;
                            }

                            if(!ask){
                                self?.completedUploads++
                            }else{
                                client.sharing.createSharedLink(path: remotePath).response({ (linkMetadata, error) in
                                    if let link = linkMetadata?.url{
                                        shareableLinks.append(link)
                                    }
                                    self?.completedUploads++
                                    checkFinished()
                                })
                            }
                            
                        }else{
                            self?.completedUploads++;
                            checkFinished()
                        }
                    })
                }
            });
            
        }else{
            Dropbox.authorizeFromController(context)
        }
    }
    func upload(file:DropboxFile, with client:DropboxClient, completion: (_: DropboxFile) -> Void)->Void{
        let url = NSURL(fileURLWithPath: file.path, isDirectory: false)
        if(exceedsChunkSize(file.path)){
            //TODO: create the upload using session
            client.files.uploadSessionStart(body: url).progress({[weak self] (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                self?.currentUploadProgress = Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)
            }).response({ (sessionStartResult, error) in
                if let session = sessionStartResult {
                    client.files.uploadSessionAppend(sessionId: session, offset: 0 , body: url)
                }
            })
        }else{
            
            client.files.upload(path: file.folder, body: url).progress({[weak self] (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                self?.currentUploadProgress = Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)
            }).response({[weak self] (fileMetadata, error) in
                
                // TODO: do soemthing with error
                if let date = fileMetadata?.serverModified{
                    file.modifiedAt = date
                }
                completion(file)
            })
        }
    }
    // Mark: helpers
    func remoteShareablePath(type:DropBoxResultType, current file:DropboxFile, all files:[DropboxFile], to folder:String)->String?{
        var remotePath:String?;
        if(type == .MultipleLinks){
            remotePath = file.remotePath
        }else{
            remotePath = files.count == 1 ? files.first?.remotePath : folder
        }
        return remotePath
    }
    func shouldAskForShareableLink(type:DropBoxResultType)->Bool{
        return type == .MultipleLinks || (type == .SingleLink && self.completedUploads == totalUplads-1)
    }
    func exceedsChunkSize(file:String)->Bool{
        let attr:NSDictionary?
        do {
            attr = try NSFileManager.defaultManager().attributesOfItemAtPath(file)
        } catch _ {
            attr = nil
        }
        return attr?.fileSize() > 150 * 1024
    }
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
                client.files.getMetadata(path: destination).response {[weak self] response, error in
                    if let metadata = response {
                        if let file = metadata as? Files.FileMetadata, let s = self {
                            if(!dbFile.modifiedAt.isEqualToDate(file.serverModified)){
                                filesToUpload.append(dbFile);
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
    
    func chunk(file:DropboxFile, offset:Int, chunkSize:Int)->NSData?{
        guard let data = NSData(contentsOfFile: file.path) else{
            return nil
        }
        let length = data.length

        let thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
    
        var chunk = NSData(bytesNoCopy: data.bytes + offset, length: thisChunkSize, freeWhenDone: false)
        
        return chunk;
    }

}




