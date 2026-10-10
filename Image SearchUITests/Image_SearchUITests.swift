//
//  Image_SearchUITests.swift
//  Image SearchUITests
//
//  Created by Daniel Husiuk on 05.10.2026.
//

import XCTest

final class ImageSearchUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
