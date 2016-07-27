//
//  EnumListable.swift
//  CocoazurLib
//
//  Created by Gerardo Garrido on 06/07/16.
//  Copyright © 2016 Code d'Azur. All rights reserved.
//

import Foundation

/**
 Gives an enum the ability to list all its cases and raw values
 Thansk to Kametrixom @ http://stackoverflow.com/a/32429125/1387646
 */
protocol EnumListable : Hashable, RawRepresentable {}
extension EnumListable {
    
    static func cases() -> AnySequence<Self> {
        typealias S = Self
        return AnySequence { () -> AnyGenerator<S> in
            var raw = 0
            return AnyGenerator {
                let current : Self = withUnsafePointer(&raw) { UnsafePointer($0).memory }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current
            }
        }
    }
    
    static func rawValues() -> AnySequence<Self.RawValue> {
        typealias S = Self
        return AnySequence { () -> AnyGenerator<S.RawValue> in
            var raw = 0
            return AnyGenerator {
                let current : Self = withUnsafePointer(&raw) { UnsafePointer($0).memory }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current.rawValue
            }
        }
    }
}