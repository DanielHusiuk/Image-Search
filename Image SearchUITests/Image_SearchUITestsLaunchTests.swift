//
//  Image_SearchUITestsLaunchTests.swift
//  Image SearchUITests
//
//  Created by Daniel Husiuk on 05.10.2026.
//

import XCTest

final class ImageSearchUITestsLaunchTests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
