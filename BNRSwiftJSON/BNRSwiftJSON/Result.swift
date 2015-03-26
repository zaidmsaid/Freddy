//
//  Result.swift
//  Test
//
//  Created by Matthew D. Mathias on 3/25/15.
//  Copyright (c) 2015 BigNerdRanch. All rights reserved.
//

import Foundation

/**
    A `Box` to hold generic values.
*/
public final class Box<T> {
    public let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

/**
    A `Result` enum containing either a `Box` in the `.Success` case or an `NSError` in the `.Failure` case.
*/
public enum Result<T> {
    case Success(Box<T>)
    case Failure(NSError)
    
    /**
        A function to `map` from one value to another.
    
        :param: f A closure to perform the mapping between values.
    
        :returns: A `Result` with either an `NSError` or a `Box` with a value.
    */
    public func map<U>(f: T -> U) -> Result<U> {
        switch self {
        case let .Failure(error):
            return .Failure(error)
        case let .Success(value):
            return .Success(Box(f(value.value)))
        }
    }
    
    /**
        A function to `bind` generic values to an instance of the `Result` enum.
    
        :param: f A closure to perform the binding.
    
        :returns: An instance of the `Result` type with the given value bound to it.
    */
    public func bind<U>(f: T -> Result<U>) -> Result<U> {
        switch self {
        case let .Failure(error):
            return .Failure(error)
        case let .Success(value):
            return f(value.value)
        }
    }
}