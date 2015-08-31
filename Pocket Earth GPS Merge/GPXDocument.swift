//
//  GPXDocument.swift
//  Pocket Earth GPS Merge
//
//  Created by Robert Carlsen on 8/31/15.
//  Copyright © 2015 Robert Carlsen. All rights reserved.
//

import Foundation

public class GPXDocumentMerge {
    private(set) var trackDocument: NSXMLDocument?
    private(set) var routeDocument: NSXMLDocument?
    var loggingLevel = LogLevel.None

    init?(trackURL track: NSURL, routeURL route: NSURL) {
        do {
            trackDocument = try NSXMLDocument(contentsOfURL: track, options: 0)
            routeDocument = try NSXMLDocument(contentsOfURL: route, options: 0)
        }
        catch let error as NSError {
            print("unable to parse xml file: \(error.localizedDescription)")
            return nil
        }
    }
}

extension GPXDocumentMerge {
    // returns a copy of the passed in elements
    internal class func convertRoutePointsToWaypoints(routePoints: [NSXMLElement], logLevel: LogLevel = .None) -> [NSXMLElement] {
        if logLevel >= .Info {
            print("processing route points...")
        }
        var convertedPoints = [NSXMLElement]()
        for routePoint in routePoints {
            let waypoint: NSXMLElement = routePoint.copy() as! NSXMLElement
            waypoint.name = "wpt"
            convertedPoints.append(waypoint)
            if logLevel >= .Debug {
                print("converted route point to waypoint: \(waypoint.description)")
            }
        }
        return convertedPoints
    }

    // mutates the passed in element
    internal class func convertCommentToDescription(waypointElement: NSXMLElement, logLevel: LogLevel = .None) -> NSXMLElement {
        if logLevel >= .Debug {
            print("converting waypoint comment to description...")
        }
        if let commentElement = waypointElement.elementsForName("cmt").first {
            commentElement.name = "desc"
        }
        return waypointElement
    }

    // mutates the track document
    internal class func spliceWaypoints(waypoints: [NSXMLNode], trackDoc: NSXMLDocument, logLevel: LogLevel = .None) -> NSXMLDocument {
        if logLevel >= .Info {
            print("splicing waypoints into track file...")
        }
        if let root = trackDoc.rootElement() {
            root.insertChildren(waypoints, atIndex: (root.childCount > 0) ? root.childCount - 1 : 0)
        }
        if logLevel >= .Info {
            print("...finished!")
        }
        return trackDoc
    }

    var mergedDocument: NSXMLDocument? {
        if let routePoints = routeDocument?.rootElement()?.elementsForName("rte").first?.elementsForName("rtept") {
            let waypoints = GPXDocumentMerge.convertRoutePointsToWaypoints(routePoints, logLevel:loggingLevel)
            if loggingLevel >= .Info {
                print("modifying waypoint comments...")
            }
            for waypoint in waypoints {
                GPXDocumentMerge.convertCommentToDescription(waypoint, logLevel: loggingLevel)
            }

            return GPXDocumentMerge.spliceWaypoints(waypoints, trackDoc: trackDocument!, logLevel: loggingLevel)
        }
        return nil
    }
}