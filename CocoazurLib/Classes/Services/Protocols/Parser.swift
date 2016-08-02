//
//  Parser.swift
//  Pods
//
//  Created by Tamara Bernad on 02/08/16.
//
//

import Foundation

public protocol Parser{

    func parse(inputData:AnyObject, result:((response:AnyObject, error:ErrorType?) -> Void))->Void
}