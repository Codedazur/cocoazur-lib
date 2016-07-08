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
    public var fileSize:UInt64 = 0
    
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
    public var chunkSize:UInt64 = 150*1024*1024
    public var maxFileSize:UInt64 = 150*1024*1024
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
        
        if(exceedsFileSize(file.fileSize)){
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
    func exceedsFileSize(fileSize:UInt64)->Bool{
        return fileSize > maxFileSize
    }
    func getFileSize(file:String)->UInt64{
        let attr:NSDictionary?
        do {
            attr = try NSFileManager.defaultManager().attributesOfItemAtPath(file)
        } catch _ {
            attr = nil
        }
        var fileSize:UInt64 = 0
        if let _attr = attr{
            fileSize = _attr.fileSize()
        }
        return fileSize;
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
            dbFile.fileSize = getFileSize(dbFile.path)
            
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
                
                self?.appendChunk(file,
                    pOffset: offset + UInt64(chunk.length),
                    chunkSize: s.chunkSize,
                    sessionId: session.sessionId,
                    client: client,
                    completion: completion)
            })
    }
    func appendChunk(file:DropboxFile, pOffset:UInt64, chunkSize:UInt64, sessionId:String, client:DropboxClient, completion: (_: DropboxFile) -> Void)->Void{
        let offset = pOffset
        guard let chunk = self.dataChunk(file, offset: offset, chunkSize: chunkSize) else{
            //TODO: error????
            return;
        }
        if(offset < file.fileSize){
            client.files.uploadSessionAppend(sessionId: sessionId, offset: offset, body: chunk).response({[weak self] (success, error) in
                //TODO: check error
                //TODO: build in retries
                self?.appendChunk(file, pOffset: offset + UInt64(chunk.length), chunkSize: chunkSize, sessionId: sessionId, client: client, completion: completion)
                })
        }else{
            client.files.uploadSessionFinish(cursor: Files.UploadSessionCursor(sessionId: sessionId, offset: offset),commit: Files.CommitInfo(path: file.remotePath),body:NSData()).response({ (metadata, error) in
                //TODO check error?
                if let metadata = metadata {
                    file.modifiedAt = metadata.serverModified
                }
                completion(file)
            })

        }
    }
    
    func dataChunk(file:DropboxFile, offset:UInt64, chunkSize:UInt64)->NSData?{
        guard let data = NSData(contentsOfFile: file.path) else{
            return nil
        }
        let length:UInt64 = UInt64(data.length)
        
        let thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        let chunk = data.subdataWithRange(NSMakeRange(Int(offset), Int(thisChunkSize)))
        
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




