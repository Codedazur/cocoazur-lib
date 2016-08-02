//
//  Connector.swift
//  Pods
//
//  Created by Tamara Bernad on 02/08/16.
//
//

import Foundation

public protocol Connector{    
    
    func create(baseUrl:String, resource:String, params:[String:AnyObject], result:((response:AnyObject, error:ErrorType?) -> Void))->Void
    func read(baseUrl:String, resource:String, params:[String:AnyObject], result:((response:AnyObject, error:ErrorType?) -> Void))->Void
    func update(baseUrl:String, resource:String, params:[String:AnyObject], result:((response:AnyObject, error:ErrorType?) -> Void))->Void
    func delete(baseUrl:String, resource:String, params:[String:AnyObject], result:((response:AnyObject, error:ErrorType?) -> Void))->Void
}