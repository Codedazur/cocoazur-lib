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

public enum DropBoxResultType:String{
    case None
    case SingleLink
    case MultipleLinks
}
public class DropboxFile{
    public var id:String = "";
    public var path:String = "";
    public var folder:String = "";
    public var reupload:Bool = false;//TODO change to overwrite
    public var modifiedAt:NSDate = NSDate()
    
    public var name:String{
        get{
            return (path as NSString).lastPathComponent
        }
    }
    public var remotePath:String{
        get{
            return folder.stringByAppendingString("/").stringByAppendingString(name)
        }
    }
    public init() { }
}
public protocol DropboxProxyDelegate:class{
    
}
public class DropboxProxy{
    public var chunkSize = 150*1024*1024
    private var completedUploads = 0
    private var totalUplads = 0
    private var currentUploadProgress = 0.0
    private var shareableLinks:[String] = []
    private var completion:((shareableLinks: [String]) -> Void)?
    
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
    public init() { }
    public static func setup()->Void{
        guard let key = appKey() else{
            assert(false, "You need to provide Dropbox appkey in info.pilst")
        }
        Dropbox.setupWithAppKey(key)
    }
    public func upload(files:[DropboxFile], using context:UIViewController,to folder:String = "", returning type:DropBoxResultType = .None, completion: (shareableLinks: [String]) -> Void)->Void{
        shareableLinks = []
        totalUplads = files.count
        completedUploads = 0
        self.completion = completion
        
        
        if let client = Dropbox.authorizedClient {
            
            getFilesToUpload(files, client: client, completion: {[weak self] (files) in
                
                for file in files{
                    self?.upload(file, with: client, completion: {[weak self] (filePath) in
                        self?.getSharableLink(files, file: file, client: client, returning: type, completion: { (sharableLink) in
                            if let link = sharableLink{
                                self?.shareableLinks.append(link)
                            }
                            self?.completedUploads++
                            self?.checkUploadFinished()
                        })
                    })
                }
                });
            
        }else{
            Dropbox.authorizeFromController(context)
        }
    }
    func upload(file:DropboxFile, with client:DropboxClient, completion: (_: DropboxFile) -> Void)->Void{
        
        if(exceedsChunkSize(file.path)){
            self.uploadInChunks(file, client: client, completion: completion)
        }else{
            self.uploadCompleteFile(file, client: client, completion: completion)
        }
    }
    
    
    // Mark: helpers
    func checkUploadFinished()->Void{
        guard let _completion = completion else{
            return;
        }
        if(self.completedUploads == self.totalUplads){
            _completion(shareableLinks: shareableLinks)
        }
    }
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
            if(index == files.count){
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
    func getSharableLink(files:[DropboxFile], file:DropboxFile, client:DropboxClient, to folder:String = "", returning type:DropBoxResultType, completion: (_: String?) -> Void)->Void{
        
        if(type != .None){
            guard let remotePath = self.remoteShareablePath(type, current: file, all: files, to: folder) else{
                completion(nil)
                return
            }
            let shouldAsk = self.shouldAskForShareableLink(type)
            
            if(!shouldAsk){
                completion(nil)
            }else{
                client.sharing.createSharedLink(path: remotePath).response({ (linkMetadata, error) in
                    guard let link = linkMetadata?.url else{
                        completion(nil)
                        return
                    }
                    completion(link)
                })
            }
        }else{
            completion(nil)
        }
    }
    func uploadCompleteFile(file:DropboxFile, client:DropboxClient, completion: (_: DropboxFile) -> Void)->Void{
        let url = NSURL(fileURLWithPath: file.path, isDirectory: false)
        client.files.upload(path: file.remotePath, body: url).progress({[weak self] (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            self?.currentUploadProgress = Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)
            }).response({[weak self] (fileMetadata, error) in
                
                
                // TODO: do soemthing with error
                if let date = fileMetadata?.serverModified{
                    file.modifiedAt = date
                }
                completion(file)
                })
    }
    func uploadInChunks(file:DropboxFile, client:DropboxClient, completion: (_: DropboxFile) -> Void)->Void{
        let offset:UInt64 = 0
        //TODO: create the upload using session
        guard let chunk = dataChunk(file, offset: offset, chunkSize: chunkSize) else{
            //TODO: some error?
            return;
        }
        
        client.files.uploadSessionStart(body: chunk).progress({[weak self] (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            self?.currentUploadProgress = Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)
            }).response({[weak self] (sessionStartResult, error) in
                guard let s = self, let session = sessionStartResult else{ return;}//TODO: return if self released?
                self?.appendChunk(file, pOffset: offset + 1, chunkSize: s.chunkSize, sessionId: session.sessionId, client: client,completion: completion)
                })
    }
    func appendChunk(file:DropboxFile, pOffset:UInt64, chunkSize:Int, sessionId:String, client:DropboxClient, completion: (_: DropboxFile) -> Void)->Void{
        let offset = pOffset
        guard let chunk = self.dataChunk(file, offset: offset, chunkSize: chunkSize) else{
            //TODO: some error?
            //TODO: offset in cursor???
            client.files.uploadSessionFinish(cursor: Files.UploadSessionCursor(sessionId: sessionId, offset: 150/* !!! */),commit: Files.CommitInfo(path: file.remotePath),body:NSData()).response({ (metadata, error) in
                //TODO check error?
                if let metadata = metadata {
                    file.modifiedAt = metadata.serverModified
                }
                completion(file)
            })
            return;
        }
        
        client.files.uploadSessionAppend(sessionId: sessionId, offset: offset, body: chunk).response({[weak self] (success, error) in
            //TODO: check error
            //TODO: build in retries
            self?.appendChunk(file, pOffset: offset + 1, chunkSize: chunkSize, sessionId: sessionId, client: client, completion: completion)
            })
    }
    
    func dataChunk(file:DropboxFile, offset:UInt64, chunkSize:Int)->NSData?{
        guard let data = NSData(contentsOfFile: file.path) else{
            return nil
        }
        let length:Int = data.length
        let of:Int = Int(offset)
        
        let thisChunkSize = length - of > chunkSize ? chunkSize : length - of;
        let chunk = data.subdataWithRange(NSMakeRange(of, thisChunkSize))
        
        return chunk;
    }
    private static func appKey()->String?{
        guard let db = dbInfo() else{
            assert(false, "You need to provide Dropbox appkey in info.pilst")
            return nil
        }
        return db["app-key"]
    }
    private static func dbInfo()->[String : String]?{
        guard let info = NSBundle.mainBundle().infoDictionary else{
            assert(false, "You need to provide Dropbox appkey in info.pilst")
            return nil
        }
        return info["Dropbox"] as! [String : String]?
    }
}




