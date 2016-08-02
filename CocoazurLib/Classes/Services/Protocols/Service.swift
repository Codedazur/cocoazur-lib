//
//  Service.swift
//  Pods
//
//  Created by Tamara Bernad on 02/08/16.
//
//

import Foundation

public protocol Service{
    var baseUrl:String!{get set}
    var resource:String!{get set}
    var connector:Connector!{get set}
    var parser:Parser?{get set}
    var cache:Cache?{get set}
    
    func create(params:[String:AnyObject], result:((response:AnyObject, error:ErrorType?) -> Void))->Void
    func read(params:[String:AnyObject], result:((response:AnyObject, error:ErrorType?) -> Void))->Void
    func update(params:[String:AnyObject], result:((response:AnyObject, error:ErrorType?) -> Void))->Void
    func delete(params:[String:AnyObject], result:((response:AnyObject, error:ErrorType?) -> Void))->Void
    
}