import XCTest
@testable import MLCardForm

final class MLCardFormCustomMaskTests: XCTestCase {
    func testCardMask() {
        let value = "4222123456789123"
        let sut = MLCardFormCustomMask(mask: "$$$$ $$$$ $$$$ $$$$")
        
        XCTAssertEqual(sut.applyMask(to: value), "4222 1234 5678 9123")
        XCTAssertEqual(sut.value, "4222 1234 5678 9123")
        XCTAssertEqual(sut.unmaskedText, value)
    }
    
    func testValidThruMask() {
        let value = "4222123456789123"
        let sut = MLCardFormCustomMask(mask: "$$/$$")
        
        XCTAssertEqual(sut.applyMask(to: value), "42/22")
        XCTAssertEqual(sut.value, "42/22")
        XCTAssertEqual(sut.unmaskedText, "4222")
    }
    
    func testCVVMask() {
        let value = "1234"
        let sut = MLCardFormCustomMask(mask: "$$$")
        
        XCTAssertEqual(sut.applyMask(to: value), "123")
        XCTAssertEqual(sut.value, "123")
        XCTAssertEqual(sut.unmaskedText, "123")
    }
    
    func testDNIMask() {
        let value = "12 345 678"
        let sut = MLCardFormCustomMask(mask: "$$.$$$.$$$")
        
        XCTAssertEqual(sut.applyMask(to: value), "12.345.678")
        XCTAssertEqual(sut.value, "12.345.678")
        XCTAssertEqual(sut.unmaskedText, "12345678")
    }
    
    func testBackSpaceWithMask() {
        let value = "12 345 678"
        let sut = MLCardFormCustomMask(mask: "$$.$$$.$$$")
        
        XCTAssertEqual(sut.applyMask(to: value), "12.345.678")

        sut.shouldChangeCharactersIn(.init(location: 9, length: 1), with: "")
        
        XCTAssertEqual(sut.value, "12.345.67")
        XCTAssertEqual(sut.unmaskedText, "1234567")
        
        sut.shouldChangeCharactersIn(.init(location: 2, length: 1), with: "")
        
        XCTAssertEqual(sut.value, "12.345.67")
        XCTAssertEqual(sut.unmaskedText, "1234567")
        
        sut.shouldChangeCharactersIn(.init(location: 1, length: 1), with: "")
        
        XCTAssertEqual(sut.value, "13.456.7")
        XCTAssertEqual(sut.unmaskedText, "134567")
        
        sut.shouldChangeCharactersIn(.init(location: 1, length: 1), with: "2")
        
        XCTAssertEqual(sut.value, "12.456.7")
        XCTAssertEqual(sut.unmaskedText, "124567")
    }
    
    func testLettersNotAllowedInMask() {
        let value = "12a34b"
        let sut = MLCardFormCustomMask(mask: "$$$")
        
        XCTAssertEqual(sut.applyMask(to: value), "123")
        XCTAssertEqual(sut.value, "123")
        XCTAssertEqual(sut.unmaskedText, "123")
        
        sut.shouldChangeCharactersIn(.init(location: 2, length: 1), with: "a")
        
        XCTAssertEqual(sut.value, "12")
        XCTAssertEqual(sut.unmaskedText, "12")
    }
}
