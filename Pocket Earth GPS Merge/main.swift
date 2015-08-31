//
//  main.swift
//  Pocket Earth GPS Merge
//
//  Created by Robert Carlsen on 8/30/15.
//  Copyright © 2015 Robert Carlsen. All rights reserved.
//

import Foundation
import Cocoa

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
        "Export the track and cuepoint route separately, then merge with this utility.\n\n" +
        "Version: \(Version.buildVersionString)\n\n"
        fputs(description, stderr)
        cli.printUsage()
    }
    else {
        cli.printUsage(error)
    }
    exit(EX_USAGE)
}

var loggingLevel = LogLevel(rawValue:verbosity.value) ?? LogLevel.None

let trackURL = NSURL(fileURLWithPath: trackFilePath.value ?? "")
let routeURL = NSURL(fileURLWithPath: cuepointFilePath.value ?? "")

if loggingLevel >= .Info {
    print("gpx track file path:\t\(trackURL.absoluteString)")
    print("gpx route file path:\t\(routeURL.absoluteString)")
}

do {
    if let merge = GPXDocumentMerge(trackURL: trackURL, routeURL: routeURL) {
        merge.loggingLevel = loggingLevel

        // this does all the work:
        if let mergedDoc = merge.mergedDocument {
            let outputString = mergedDoc.XMLStringWithOptions(NSXMLNodePrettyPrint)

            if let outputPath = outputFilePath.value {
                try outputString.writeToFile(outputPath, atomically: false, encoding: NSUTF8StringEncoding)
                if loggingLevel >= .Info {
                    print("wrote merged GPX file:\t\(outputPath)")
                }
            }
            else {
                print(outputString)
            }
        }
        else {
            print("unable to merge the documents")
        }
    }
}
catch {
    print("error merging file(s):\n\(error)")
}

exit(EX_OK)
