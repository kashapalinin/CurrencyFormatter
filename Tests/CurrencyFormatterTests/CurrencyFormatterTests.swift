import XCTest
@testable import CurrencyFormatter

final class CurrencyFormatterTests: XCTestCase {
    var formatter: CBCurrencyFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = CBCurrencyFormatter()
    }
    
    @MainActor func testXMLParsing() throws {
        let xmlString = """
        <ValCurs Date="29.11.2025" name="Foreign Currency Market">
            <Valute ID="R01010">
                <NumCode>036</NumCode>
                <CharCode>AUD</CharCode>
                <Nominal>1</Nominal>
                <Name>Австралийский доллар</Name>
                <Value>51,1066</Value>
                <VunitRate>51,1066</VunitRate>
            </Valute>
        </ValCurs>
        """
        
        let parser = CurrencyXMLParser()
        let expectation = self.expectation(description: "XML Parsing")
        var result: Result<CurrencyResponse, Error>?
        
        parser.parse(data: xmlString.data(using: .utf8)!) { parsingResult in
            result = parsingResult
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let response = try XCTUnwrap(try result?.get())
        XCTAssertEqual(response.date, "29.11.2025")
        XCTAssertEqual(response.currencies.count, 1)
        
        let currency = response.currencies.first
        XCTAssertEqual(currency?.charCode, "AUD")
        XCTAssertEqual(currency?.value, 51.1066)
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
        
        let formatted = formatter.formatAmount(100, for: currency)
        XCTAssertNotNil(formatted)
    }
}
