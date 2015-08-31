//
//  gpxmerge_tests.swift
//  gpxmerge tests
//
//  Created by Robert Carlsen on 8/31/15.
//  Copyright © 2015 Robert Carlsen. All rights reserved.
//

import XCTest

class gpxmerge_tests: XCTestCase {
    var trackURL: NSURL!
    var routeURL: NSURL!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        trackURL = NSBundle(forClass: self.dynamicType).URLForResource("Central_Park_Lap", withExtension: "gpx")
        routeURL = NSBundle(forClass: self.dynamicType).URLForResource("Central_Park_Lap_Cues", withExtension: "gpx")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGPXDocumentMergeShouldFailInit() {
        // if the urls can't be found or parsed, init should fail
        let trackURL = NSURL(fileURLWithPath:"file:///tmp/track")
        let routeURL = NSURL(fileURLWithPath:"file:///tmp/route")

        let merge = GPXDocumentMerge(trackURL: trackURL, routeURL: routeURL)
        XCTAssertNil(merge)
    }

    func testGPXDocumentMergeShouldInit() {
        // when passed valid XML documnent URLs, init should succeed
        let merge = GPXDocumentMerge(trackURL: trackURL, routeURL: routeURL)
        XCTAssertNotNil(merge)
    }

    func testGPXDocumentMergeShouldMerge() {
        let merge = GPXDocumentMerge(trackURL: trackURL, routeURL: routeURL)
        let mergedDocument = merge?.mergedDocument
        XCTAssertNotNil(mergedDocument)
    }

    func testConvertRoutePoints() {
        let rteptElement = NSXMLElement(name: "rtept")
        let result = GPXDocumentMerge.convertRoutePointsToWaypoints([rteptElement])
        XCTAssertEqual(result.count, 1)
    }

    func testConvertComment() {
        let wptElement = NSXMLElement(name: "wpt")
        wptElement.addChild(NSXMLElement(name: "cmt"))

        let result = GPXDocumentMerge.convertCommentToDescription(wptElement)
        XCTAssertNotNil(result.elementsForName("desc").first)
    }

    func testSplice() {
        let gpxElement = NSXMLElement(name: "gpx")
        let gpxDoc = NSXMLDocument(rootElement: gpxElement)
        let wptElement = NSXMLElement(name: "wpt")

        let result = GPXDocumentMerge.spliceWaypoints([wptElement], trackDoc: gpxDoc)
        XCTAssertNotNil(result)
        XCTAssertEqual(result.rootElement()?.childCount, 1)
    }
}
