//
//  main.swift
//  Pocket Earth GPS Merge
//
//  Created by Robert Carlsen on 8/30/15.
//  Copyright © 2015 Robert Carlsen. All rights reserved.
//

import Foundation
import Cocoa

//import CommandLine

enum LogLevel: Int {
    case None = 0
    case Info
    case Debug
    case Error
}

let cli = CommandLine()

let trackFilePath = StringOption(shortFlag: "t",
    longFlag: "track",
    required: true,
    helpMessage: "Path to the GPX track file.")
let cuepointFilePath = StringOption(shortFlag: "c",
    longFlag: "cuepoints",
    required: true,
    helpMessage: "Path to the GPX cuepoints file.")
let outputFilePath = StringOption(shortFlag: "f",
    longFlag: "file",
    helpMessage: "Path to the output file.")
let helpFlag = BoolOption(shortFlag: "h",
    longFlag: "help",
    helpMessage: "Show help information.")
let verbosity = CounterOption(shortFlag: "v",
    longFlag: "verbose",
    helpMessage: "Print verbose messages. Specify multiple times to increase verbosity.")

cli.addOptions(trackFilePath, cuepointFilePath, outputFilePath, helpFlag, verbosity)

do {
    // pass boolean for "strict" parsing..reject any invalid args
    try cli.parse(true)
} catch {
    if helpFlag.value {
        let description = "Merges GPX files from Ride With GPS for use with Pocket Earth.\n" +
        "Basic account with Ride With GPS does not export track and cuepoints together.\n" +
        "Export the track and cuepoint route separately, then merge with this utility.\n\n"
        fputs(description, stderr)
        cli.printUsage()
    }
    else {
        cli.printUsage(error)
    }
    exit(EX_USAGE)
}

var loggingLevel = LogLevel(rawValue:verbosity.value) ?? LogLevel.None

// do the processing and stuff.
// let's try to brute force this the first time.
do {
    var waypointString: String?
    var trackString: String?
    
    if let cuepointPath = cuepointFilePath.value {
        if loggingLevel.rawValue >= LogLevel.Info.rawValue {
            print("reading cuepoint file:\t\t\(cuepointPath)")
        }
        let cuepointString = try String(contentsOfFile: cuepointPath)
            .stringByReplacingOccurrencesOfString("<rtept", withString: "<wpt")
            .stringByReplacingOccurrencesOfString("</rtept", withString:"</wpt")
            .stringByReplacingOccurrencesOfString("<cmt", withString: "<desc")
            .stringByReplacingOccurrencesOfString("</cmt", withString: "</desc")
        
        if loggingLevel.rawValue >= LogLevel.Debug.rawValue {
            print("replaced route points with waypoints...")
        }
        
        let startIndex = cuepointString.rangeOfString("<wpt")?.startIndex
        let endIndex = cuepointString.rangeOfString("</wpt>", options: NSStringCompareOptions.BackwardsSearch)?.endIndex
        
        if startIndex != nil && endIndex != nil {
            waypointString = cuepointString.substringWithRange(Range(start: startIndex!, end: endIndex!))
            if waypointString == nil {
                throw NSError(domain: "net.robertcarlsen.gpsmerge", code: 100, userInfo: nil)
            }
            if loggingLevel.rawValue >= LogLevel.Debug.rawValue {
                print("found waypoints in transformed cuepoints file...")
            }
        }
    }
    
    if let trackPath = trackFilePath.value {
        if loggingLevel.rawValue >= LogLevel.Info.rawValue {
            print("reading track file:\t\t\(trackPath)")
        }
        trackString = try String(contentsOfFile: trackPath)
        let endIndex = trackString!.rangeOfString("</trk>", options:.BackwardsSearch)?.endIndex
        if endIndex != nil {
            trackString!.splice("\n\t\(waypointString!)".characters, atIndex: endIndex!)
        }
        if loggingLevel.rawValue >= LogLevel.Debug.rawValue {
            print("spliced waypoints into track file...")
        }
    }
    
    if let output = trackString {
        if let outputPath = outputFilePath.value {
            if loggingLevel.rawValue >= LogLevel.Info.rawValue {
                print("writing merged GPX file:\t\(outputPath)")
            }
            try output.writeToFile(outputPath, atomically: false, encoding: NSUTF8StringEncoding)
        }
        else {
            print(output)
        }
    }
    
    if loggingLevel.rawValue >= LogLevel.Info.rawValue {
        print("...finished!")
    }
}
catch {
    print("error merging file(s):\n\(error)")
}

exit(EX_OK)