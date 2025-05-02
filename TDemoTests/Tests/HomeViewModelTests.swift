//
//  HomeViewModelTests.swift
//  TDemo
//
//  Created by Arda Doğantemur on 2.05.2025.
//

import XCTest
@testable import TDemo


final class HomeViewModelTests: XCTestCase {
    
    
    // MARK: - HomeViewModel Test Coverage
    //
    // ✅ = Covered by Unit Tests
    //
    // Case | Repository Result     | ViewModel Callback       | Description                        | Covered?
    // -----|------------------------|---------------------------|------------------------------------|----------
    //  1   | Success ([Product])    | onProductsUpdated         | Updates product list               | ✅
    //  2   | Failure (Error)        | onError                   | Triggers error handling            | ✅

    
    func test_HomeViewModel_whenFetchSucceeds_thenUpdatesProducts() {
        let repo = MockProductRepository()
        repo.productsToReturn = [Product(productID: "1", name: "Test", price: 100, urlString: nil, detail: nil)]
        let vm = HomeViewModel(repository: repo)
        
        var captured: [Product] = []
        let expectation = expectation(description: "products updated")
        vm.onProductsUpdated = { products,source in
            captured = products
            expectation.fulfill()
        }

        vm.getProducts()

        waitForExpectations(timeout: 1)
        XCTAssertEqual(captured.count, 1)
    }
    
    func test_HomeViewModel_whenFetchFails_thenCallsOnError() {
        let mockRepo = MockProductRepository()
        mockRepo.errorToReturn = AppError.networkError("501")

        let vm = HomeViewModel(repository: mockRepo)
        let expectation = expectation(description: "onError called")

        vm.onError = { error,source in
            XCTAssertEqual(error, AppError.networkError("501"))
            expectation.fulfill()
        }

        vm.getProducts()
        waitForExpectations(timeout: 1)
    }
}
