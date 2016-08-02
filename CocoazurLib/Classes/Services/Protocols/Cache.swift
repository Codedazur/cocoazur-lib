//
//  Cache.swift
//  Pods
//
//  Created by Tamara Bernad on 02/08/16.
//
//

import Foundation

public protocol Cache{
    
    func get(resource:String, params:[String:AnyObject], result:((response:AnyObject, error:ErrorType?) -> Void))->Void
}