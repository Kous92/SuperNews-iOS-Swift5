//
//  SuperNewsUITests.swift
//  SuperNewsUITests
//
//  Created by Koussaïla Ben Mamar on 08/04/2021.
//

import XCTest

// UI tests must launch the application that they test.
// Use recording to get started writing UI tests.
// Use XCTAssert and related functions to verify your tests produce the correct results.
class SuperNewsUITests: XCTestCase {
    
    // Les tests UI doivent lancer l'application qu'ils testent avec app.launch().
    var app: XCUIApplication!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHome() throws {
        app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Accueil"].tap()
        
        XCTAssert(app.staticTexts["Bienvenue"].exists)
    }
    
    // En cliquant sur "News", on s'assure que les cellules apparaissent. Test de type asynchrone (étant donné le téléchargement asynchrone des données).
    func testNews() throws {
        app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["News"].tap()
        
        // XCTAssert(app.staticTexts["Bienvenue"].exists)
        XCTAssert(app.images["magnifyingglass"].exists, "Le logo de recherche (loupe) existe.")
        XCTAssert(app.textFields["newsSearchBar"].exists, "La barre de recherche existe.")
        
        // Le TableView existe
        let articleTableView = app.tables["articleTableView"]
        XCTAssertTrue(articleTableView.exists, "Le TableView des articles existe")
        
        // On vérifie l'existence des cellules
        let tableCells = articleTableView.cells
        
        if tableCells.count > 0 {
            let promise = expectation(description: "En attente des TableViewCells")
            
            for i in 0 ..< tableCells.count {
                // Grab the first cell and verify that it exists and tap it
                let tableCell = tableCells.element(boundBy: i)
                XCTAssertTrue(tableCell.exists, "La cellule \(i) existe")
         
                if i == (tableCells.count - 1) {
                    promise.fulfill()
                }
            }
            waitForExpectations(timeout: 40, handler: nil)
            XCTAssertTrue(true, "Finished validating the table cells")
         
        } else {
            XCTAssert(false, "Was not able to find any table cells")
        }
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
