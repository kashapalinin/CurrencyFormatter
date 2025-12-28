import XCTest
@testable import CurrencyFormatter

final class CurrencyFormatterTests: XCTestCase {
    var formatter: CBCurrencyFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = CBCurrencyFormatter()
    }
    
    func testCurrencyFormatting() {
        let currency = Currency(
            id: "R01010",
            numCode: "036",
            charCode: "AUD",
            nominal: 1,
            name: "Австралийский доллар",
            value: 51.1066,
            vunitRate: 51.1066
        )
        
        let symbol = formatter.getCurrencySymbol(code: currency.charCode)
        XCTAssertEqual(symbol, "$")
    }
}
