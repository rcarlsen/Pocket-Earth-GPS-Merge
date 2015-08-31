//
//  GPXDocument.swift
//  Pocket Earth GPS Merge
//
//  Created by Robert Carlsen on 8/31/15.
//  Copyright © 2015 Robert Carlsen. All rights reserved.
//

import Foundation

class GPXDocumentMerge {
    var trackDocument: NSXMLDocument?
    var routeDocument: NSXMLDocument?
    var loggingLevel = LogLevel.None

    init?(trackURL track: NSURL, routeURL route: NSURL) {
        do {
            trackDocument = try NSXMLDocument(contentsOfURL: track, options: 0)
            routeDocument = try NSXMLDocument(contentsOfURL: route, options: 0)
        }
        catch let error as NSError {
            print("unable to parse xml file: \(error.localizedDescription)")
        }
    }
}


extension GPXDocumentMerge {
    // returns a copy of the passed in elements
    private func convertRoutePointsToWaypoints (routePoints: [NSXMLElement]) -> [NSXMLElement] {
        if loggingLevel >= .Info {
            print("processing route points...")
        }
        var convertedPoints = [NSXMLElement]()
        for routePoint in routePoints {
            let waypoint: NSXMLElement = routePoint.copy() as! NSXMLElement
            waypoint.name = "wpt"
            convertedPoints.append(waypoint)
            if loggingLevel >= .Debug {
                print("converted route point to waypoint: \(waypoint.description)")
            }
        }
        return convertedPoints
    }

    // mutates the passed in element
    private func convertCommentsToDescription (waypointElement: NSXMLElement) -> NSXMLElement {
        if loggingLevel >= .Debug {
            print("converting waypoint comment to description...")
        }
        if let commentElement = waypointElement.elementsForName("cmt").first {
            commentElement.name = "desc"
        }
        return waypointElement
    }

    // mutates the track document
    private func spliceWaypoints (waypoints: [NSXMLNode], trackDoc: NSXMLDocument) -> NSXMLDocument {
        if loggingLevel >= .Info {
            print("splicing waypoints into track file...")
        }
        if let root = trackDocument?.rootElement() {
            root.insertChildren(waypoints, atIndex: (root.childCount > 0) ? root.childCount - 1 : 0)
        }
        if loggingLevel >= .Info {
            print("...finished!")
        }
        return trackDoc
    }

    var mergedDocument: NSXMLDocument? {
        if let routePoints = routeDocument?.rootElement()?.elementsForName("rte").first?.elementsForName("rtept") {
            let waypoints = convertRoutePointsToWaypoints(routePoints)
            if loggingLevel >= .Info {
                print("modifying waypoint comments...")
            }
            for waypoint in waypoints {
                convertCommentsToDescription(waypoint)
            }

            return spliceWaypoints(waypoints, trackDoc: trackDocument!)
        }
        return nil
    }
}