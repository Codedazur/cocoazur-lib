//
//  AlamofireConnector.swift
//  Pods
//
//  Created by Tamara Bernad on 04/08/16.
//
//

import Foundation
import Cocoazur_Services
import Alamofire

public class AlamofireConnector:Connector{
    public func create(baseUrl: String, resource: String, params: [String : AnyObject], result: ((response: AnyObject, error: ErrorType?) -> Void)) {
        
    }
    public func read(baseUrl: String, resource: String, params: [String : AnyObject], result: ((response: AnyObject, error: ErrorType?) -> Void)) {
        Alamofire.request(.GET, baseUrl+resource, parameters: params)
            .validate()
            .responseJSON { response in
                var resultError:ErrorType? = nil
                switch response.result {
                
                case .Failure(let error):
                    
                }
        }
    }
    public func delete(baseUrl: String, resource: String, params: [String : AnyObject], result: ((response: AnyObject, error: ErrorType?) -> Void)) {
        
    }
    public func update(baseUrl: String, resource: String, params: [String : AnyObject], result: ((response: AnyObject, error: ErrorType?) -> Void)) {
        
    }
}