//
//  AbstractService.swift
//  Pods
//
//  Created by Tamara Bernad on 02/08/16.
//
//

import Foundation

public class AbstractService:Service{
    public var baseUrl: String! = ""
    public var resource: String! = ""
    public var connector: Connector!
    public var parser: Parser?
    public var cache: Cache?
    
    init(baseUrl:String, resource:String, connector:Connector, parser:Parser? = nil, cache:Cache? = nil){
        self.baseUrl = baseUrl
        self.resource = resource
        self.connector = connector
        self.parser = parser
        self.cache = cache
    }
    
    public func create(params: [String : AnyObject], result: ((response: AnyObject, error: ErrorType?) -> Void)) {
        self.connector.create(baseUrl, resource: resource, params: params) {[weak self] (response, error) in
            self?.handleConnectorResponse(response, error: error, result: result)
        }
    }
    public func read(params: [String : AnyObject], result: ((response: AnyObject, error: ErrorType?) -> Void)) {
        self.connector.read(baseUrl, resource: resource, params: params) {[weak self] (response, error) in
            guard let _ = error else{
                guard let _cache = self?.cache, let _resource = self?.resource else{
                    result(response: response, error: error)
                    return;
                }
                
                _cache.get(_resource, params: params, result: { (response, error) in
                    self?.parse(response, result: result)
                })
                return;
            }
            self?.parse(response, result: result)
        }
    }
    public func update(params: [String : AnyObject], result: ((response: AnyObject, error: ErrorType?) -> Void)) {
        self.connector.update(baseUrl, resource: resource, params: params) {[weak self] (response, error) in
            self?.handleConnectorResponse(response, error: error, result: result)
        }
    }
    public func delete(params: [String : AnyObject], result: ((response: AnyObject, error: ErrorType?) -> Void)) {
        self.connector.delete(baseUrl, resource: resource, params: params) {[weak self] (response, error) in
            self?.handleConnectorResponse(response, error: error, result: result)
        }
    }
    
    // MARK: helpers
    private func handleConnectorResponse(response:AnyObject, error:ErrorType?, result: ((response: AnyObject, error: ErrorType?) -> Void))->Void{
        guard let _error = error else{
            result(response: response, error: error)
            return;
        }
        guard let _parser = self.parser else{
            result(response: response, error: nil)
            return;
        }
        
        self.parse(response, result: result)
    }
    private func parse(inputData:AnyObject, result:((response:AnyObject, error:ErrorType?) -> Void))->Void{
        guard let _parser = self.parser else{
            result(response: inputData, error: nil)
            return;
        }
        _parser.parse(inputData) { (response, error) in
            result(response: response, error: error)
        }
    }
    
}