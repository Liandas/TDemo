//
//  FeatureGatekeeper.swift
//  TDemo
//
//  Created by Arda Doğantemur on 2.05.2025.
//


final class FeatureGatekeeper {
    static let shared = FeatureGatekeeper()

    private init() {}

    var isProductDetailEnabled: Bool { true}
}
