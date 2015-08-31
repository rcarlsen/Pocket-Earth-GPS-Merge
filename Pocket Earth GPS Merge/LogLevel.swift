//
//  LogLevel.swift
//  Pocket Earth GPS Merge
//
//  Created by Robert Carlsen on 8/31/15.
//  Copyright © 2015 Robert Carlsen. All rights reserved.
//

// operators for the log level enum:
func < <T: RawRepresentable where T.RawValue: Comparable>(lhs: T, rhs: T) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
func <= <T: RawRepresentable where T.RawValue: Comparable>(lhs: T, rhs: T) -> Bool {
    return lhs.rawValue <= rhs.rawValue
}
func > <T: RawRepresentable where T.RawValue: Comparable>(lhs: T, rhs: T) -> Bool {
    return lhs.rawValue > rhs.rawValue
}
func >= <T: RawRepresentable where T.RawValue: Comparable>(lhs: T, rhs: T) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}

enum LogLevel: Int {
    case None, Info, Debug, Error
}
