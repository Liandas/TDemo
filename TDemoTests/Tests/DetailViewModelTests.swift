//
//  DetailViewModelTests.swift
//  TDemo
//
//  Created by Arda Doğantemur on 2.05.2025.
//

import XCTest
@testable import TDemo


final class DetailViewModelTests: XCTestCase {
    
    
    // MARK: - DetailViewModel Test Coverage
    //
    // ✅ = Covered by Unit Tests
    //
    // Case | Repository Result     | ViewModel Callback   | Description                      | Covered?
    // -----|------------------------|-----------------------|----------------------------------|----------
    //  1   | Success (Product)      | onProductUpdated      | Updates description              | ✅
    //  2   | Failure (Error)        | onError               | Triggers error handling          | ✅
    
    func test_DetailViewModel_whenFetchSucceeds_thenUpdatesProduct() {
        let mockRepo = MockProductRepository()
        let initial = Product(productID: "1", name: "Apple", price: 0, urlString: nil, detail: nil)
        let updated = Product(productID: "1", name: "Apple", price: 100, urlString: nil, detail: "apples are awesome")

        mockRepo.productDetailToReturn = updated

        let vm = DetailViewModel(repository: mockRepo, product: initial)

        let expectation = expectation(description: "onProductUpdated called")

        vm.onProductUpdated = { product, source in
            XCTAssertEqual(product.name, "Apple")
            XCTAssertEqual(vm.product.name, "Apple")
            XCTAssertEqual(vm.product.detail, "apples are awesome")
            expectation.fulfill()
        }

        vm.getProduct()
        waitForExpectations(timeout: 1)
    }
    
    func test_DetailViewModel_whenFetchFails_thenCallsOnError() {
        let mockRepo = MockProductRepository()
        mockRepo.errorToReturn = AppError.networkError("501")

        let vm = DetailViewModel(repository: mockRepo, product: Product(productID: "1", name: "X", price: 0, urlString: nil, detail: nil))

        let expectation = expectation(description: "onError called")

        vm.onError = { error, source in
            XCTAssertEqual(error, AppError.networkError("501"))
            expectation.fulfill()
        }

        vm.getProduct()
        waitForExpectations(timeout: 1)
    }
}
