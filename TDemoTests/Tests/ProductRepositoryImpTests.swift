//
//  ProductRepositoryImpTests.swift
//  TDemo
//
//  Created by Arda Doğantemur on 1.05.2025.
//

import XCTest
@testable import TDemo


final class ProductRepositoryImpTests: XCTestCase {

    //
    // MARK: - fetchProducts() Test Coverage
    //
    // ✅ = Covered by Unit Tests
    //
    // Case | Internet | Network | JSON Decode | DB Save | Result                     | Covered?
    // -----|----------|---------|-------------|---------|----------------------------|----------
    //  1   | OFF      | —       | —           | —       | Load from DB               | ✅
    //  2   | ON       | FAIL    | —           | —       | Return network error       | ✅
    //  3   | ON       | OK      | FAIL        | —       | Return JSON error          | ✅
    //  4   | ON       | OK      | OK          | FAIL    | Return products (no save)  | ✅
    //  5   | ON       | OK      | OK          | OK      | Return products (saved)    | ✅
    //  6   | ON       | OK      | OK (empty)  | OK      | Return empty array         | ✅
    
    
    func test_fetchProducts_whenInternetIsOff_thenLoadsFromPersistence() {
        let mockNetwork = MockNetwork()
        let mockPersistence = MockPersistence()
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = false

        let expected = [Product(productID: "1", name: "Offline Apple", price: 100, urlString: nil, detail: nil)]
        mockPersistence.readResult = .success(expected)

        let sut = ProductRepositoryImp(network: mockNetwork, persistence: mockPersistence, reachability: mockReachability)

        let expectation = expectation(description: "load from DB")

        sut.fetchProducts { result, source in
            defer { expectation.fulfill() }

            switch result {
            case .success(let products):
                XCTAssertEqual(products.first?.name, "Offline Apple")
                XCTAssertEqual(source, .persistence)
            case .failure:
                XCTFail("Should not fail when loading from persistence")
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func test_fetchProducts_whenInternetIsOn_andNetworkFails_thenLoadsFromPersistence() {
        let mockNetwork = MockNetwork()
        mockNetwork.result = .failure(AppError.networkError("500"))

        let mockPersistence = MockPersistence()
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let expected = [Product(productID: "2", name: "Fallback Orange", price: 80, urlString: nil, detail: nil)]
        mockPersistence.readResult = .success(expected)

        let sut = ProductRepositoryImp(network: mockNetwork, persistence: mockPersistence, reachability: mockReachability)

        let expectation = expectation(description: "fallback after network failure")

        sut.fetchProducts { result, source in
            defer { expectation.fulfill() }

            switch result {
            case .success(_):
                XCTFail("Should error")
            case .failure(let error):
                XCTAssertEqual(error, AppError.networkError("500"))
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func test_fetchProducts_whenInternetIsOn_andJSONDecodeFails_thenLoadsFromPersistence() {
        let mockNetwork = MockNetwork()
        // Malformed JSON (not decodable into ProductResponse)
        let invalidJSON = "{ \"invalid\": true }".data(using: .utf8)!
        mockNetwork.result = .success(invalidJSON)

        let mockPersistence = MockPersistence()
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let expected = [Product(productID: "3", name: "DecodeFallback", price: 0, urlString: nil, detail: nil)]
        mockPersistence.readResult = .success(expected)

        let sut = ProductRepositoryImp(network: mockNetwork, persistence: mockPersistence, reachability: mockReachability)

        let expectation = expectation(description: "decode failure fallback")

        sut.fetchProducts { result, source in
            defer { expectation.fulfill() }

            switch result {
            case .success(_):
                XCTFail("Should return error")
            case .failure(let error):
                XCTAssertEqual(source, .backend)
                XCTAssertEqual(error, .invalidJSON)
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func test_fetchProducts_whenInternetIsOn_andDecodeSucceeds_andDBSaveFails_thenReturnsProducts() {
        let mockNetwork = MockNetwork()
        let validJSON = """
        {
          "products": [
            {
              "product_id": "4",
              "name": "Grapes",
              "price": 150,
              "image": "https://example.com/image.jpg"
            }
          ]
        }
        """.data(using: .utf8)!
        mockNetwork.result = .success(validJSON)

        let mockPersistence = MockPersistence()
        mockPersistence.insertShouldFail = true

        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let sut = ProductRepositoryImp(network: mockNetwork, persistence: mockPersistence, reachability: mockReachability)
        let expectation = expectation(description: "fallback to return products even if DB save fails")

        sut.fetchProducts { result,source in
            defer { expectation.fulfill() }

            switch result {
            case .success(let products):
                XCTAssertEqual(products.first?.name, "Grapes")
                XCTAssertEqual(source, .backend)
            case .failure:
                XCTFail("Should return products even if DB save fails")
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func test_fetchProducts_whenInternetIsOn_andDecodeSucceeds_andDBSaveSucceeds_thenReturnsProducts() {
        let mockNetwork = MockNetwork()
        let validJSON = """
        {
          "products": [
            {
              "product_id": "5",
              "name": "Peaches",
              "price": 75,
              "image": "https://example.com/image.jpg"
            }
          ]
        }
        """.data(using: .utf8)!
        mockNetwork.result = .success(validJSON)

        let mockPersistence = MockPersistence()
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let sut = ProductRepositoryImp(network: mockNetwork, persistence: mockPersistence, reachability: mockReachability)
        let expectation = expectation(description: "happy path")

        sut.fetchProducts { result,source in
            defer { expectation.fulfill() }

            switch result {
            case .success(let products):
                XCTAssertEqual(products.count, 1)
                XCTAssertEqual(products.first?.name, "Peaches")
                XCTAssertEqual(mockPersistence.savedProducts.first?.productID, "5")
                XCTAssertEqual(source, .backend)
            case .failure:
                XCTFail("Should return decoded products on success path")
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func test_fetchProducts_whenInternetIsOn_andResponseIsEmpty_thenReturnsEmptyArray() {
        let mockNetwork = MockNetwork()
        let emptyJSON = "{ \"products\": [] }".data(using: .utf8)!
        mockNetwork.result = .success(emptyJSON)

        let mockPersistence = MockPersistence()
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let sut = ProductRepositoryImp(network: mockNetwork, persistence: mockPersistence, reachability: mockReachability)
        let expectation = expectation(description: "empty response handled")

        sut.fetchProducts { result,source in
            defer { expectation.fulfill() }

            switch result {
            case .success(let products):
                XCTAssertTrue(products.isEmpty)
                XCTAssertEqual(source, .backend)
            case .failure:
                XCTFail("Should not fail on empty product array")
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    
    // MARK: - fetchProductDetails(productId:) Test Coverage
    //
    // ✅ = Covered by Unit Tests
    //
    // Case | Internet | Network  | JSON Decode | DB Save | DB Read | Result                        | Covered?
    // -----|----------|----------|-------------|---------|---------|-------------------------------|----------
    //  1   | OFF      | —        | —           | —       | OK      | Load product from DB          | ✅
    //  2   | OFF      | —        | —           | —       | FAIL    | Return read failure           | ✅
    //  3   | ON       | FAIL     | —           | —       | —       | Return failure                | ✅
    //  4   | ON       | OK       | FAIL        | —       | —       | Return failure                | ✅
    //  5   | ON       | OK       | OK          | FAIL    | —       | Return product anyway         | ✅
    //  6   | ON       | OK       | OK          | OK      | —       | Return product                | ✅
    
    
    func test_fetchProductDetails_whenInternetIsOff_thenLoadsFromPersistence() {
        let mockNetwork = MockNetwork()
        let mockPersistence = MockPersistence()
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = false

        let expected = Product(productID: "123", name: "Offline Banana", price: 10, urlString: nil, detail: "cached")
        mockPersistence.readResult = .success([expected])

        let sut = ProductRepositoryImp(network: mockNetwork, persistence: mockPersistence, reachability: mockReachability)

        let expectation = expectation(description: "load from persistence")

        sut.fetchProductDetails(productId: "123") { result,source in
            defer { expectation.fulfill() }

            switch result {
            case .success(let product):
                XCTAssertEqual(product.name, "Offline Banana")
                XCTAssertEqual(source, .persistence)
            case .failure:
                XCTFail("Should load from persistence")
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func test_fetchProductDetails_whenInternetIsOff_andDBReadFails_thenReturnsFailure() {
        let mockPersistence = MockPersistence()
        mockPersistence.readResult = .failure(.persistenceError)

        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = false

        let sut = ProductRepositoryImp(network: MockNetwork(), persistence: mockPersistence, reachability: mockReachability)

        let expectation = expectation(description: "fail from persistence")

        sut.fetchProductDetails(productId: "123") { result,source in
            defer { expectation.fulfill() }

            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, AppError.persistenceError)
                XCTAssertEqual(source, .persistence)
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func test_fetchProductDetails_whenInternetIsOn_andNetworkFails_thenReturnsFailure() {
        let mockNetwork = MockNetwork()
        mockNetwork.result = .failure(.networkError("500"))

        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let sut = ProductRepositoryImp(network: mockNetwork, persistence: MockPersistence(), reachability: mockReachability)

        let expectation = expectation(description: "network fail")

        sut.fetchProductDetails(productId: "456") { result, source in
            defer { expectation.fulfill() }

            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, .networkError("500"))
                XCTAssertEqual(source, .backend)
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func test_fetchProductDetails_whenInternetIsOn_andJSONDecodeFails_thenLoadsFromPersistence() {
        let mockNetwork = MockNetwork()
        let invalidJSON = "{ \"invalid\": true }".data(using: .utf8)!
        mockNetwork.result = .success(invalidJSON)

        let mockPersistence = MockPersistence()
        mockPersistence.readResult = .success([
            Product(productID: "123", name: "Fallback Kiwi", price: 15, urlString: nil, detail: "cached")
        ])

        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let sut = ProductRepositoryImp(network: mockNetwork, persistence: mockPersistence, reachability: mockReachability)

        let expectation = expectation(description: "decode fallback")

        sut.fetchProductDetails(productId: "123") { result,source in
            defer { expectation.fulfill() }

            switch result {
            case .success(_):
                XCTFail("Should give an error")
            case .failure(let error):
                XCTAssertEqual(error, .invalidJSON)
                XCTAssertEqual(source, .backend)
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func test_fetchProductDetails_whenInternetIsOn_andDecodeSucceeds_andDBSaveFails_thenReturnsProduct() {
        let validJSON = """
        {
          "product_id": "456",
          "name": "Strawberry",
          "price": 99,
          "image": "https://example.com/img.jpg",
          "description": "fresh"
        }
        """.data(using: .utf8)!

        let mockNetwork = MockNetwork()
        mockNetwork.result = .success(validJSON)

        let mockPersistence = MockPersistence()
        mockPersistence.insertShouldFail = true

        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let sut = ProductRepositoryImp(network: mockNetwork, persistence: mockPersistence, reachability: mockReachability)

        let expectation = expectation(description: "DB save fails but returns product")

        sut.fetchProductDetails(productId: "456") { result, source in
            defer { expectation.fulfill() }

            switch result {
            case .success(let product):
                XCTAssertEqual(product.name, "Strawberry")
                XCTAssertEqual(source, .backend)
            case .failure:
                XCTFail("Should return product even if save fails")
            }
        }

        waitForExpectations(timeout: 1)
    }
    
    func test_fetchProductDetails_whenInternetIsOn_andDecodeSucceeds_andDBSaveSucceeds_thenReturnsProduct() {
        let validJSON = """
        {
          "product_id": "789",
          "name": "Mango",
          "price": 129,
          "image": "https://example.com/img.jpg",
          "description": "juicy"
        }
        """.data(using: .utf8)!

        let mockNetwork = MockNetwork()
        mockNetwork.result = .success(validJSON)

        let mockPersistence = MockPersistence()
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true

        let sut = ProductRepositoryImp(network: mockNetwork, persistence: mockPersistence, reachability: mockReachability)

        let expectation = expectation(description: "happy path")

        sut.fetchProductDetails(productId: "789") { result,source in
            defer { expectation.fulfill() }

            switch result {
            case .success(let product):
                XCTAssertEqual(product.name, "Mango")
                XCTAssertEqual(source, .backend)
            case .failure:
                XCTFail("Should return decoded and saved product")
            }
        }

        waitForExpectations(timeout: 1)
    }
    


    
    
}
