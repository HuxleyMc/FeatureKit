//
//  FeatureKitTests.swift
//  FeatureKitTests
//
//  Created by Huxley McGuffin on 27/5/2023.
//

@testable import FeatureKit
import XCTest

let defaultStore: FeatureStore = .init(
    order: 99,
    name: "Default",
    flags: [
        "flag-1": true,
        "flag-1-disabled": false,
        "flag-2": "5.27.0",
        "flag-2-major": "6.48.0",
        "flag-2-disabled": "1.0.1",
        "flag-invalid": "1,0.0"
    ]
)

let asyncStore: FeatureStore = .init(
    order: 1,
    name: "AsyncStore",
    flags: [
        "flag-1": false,
        "flag-2": "5.0.2",
        "flag-invalid": "lol",
        "flag-async": true
    ]
)

final class FeatureKitTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddFeatureFlags() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")

        features.addFeatureFlags(defaultStore)
        features.addFeatureFlags(asyncStore)

        if features.stores().isEmpty {
            XCTFail("Failed to add stores")
        }

        if features.stores().count != 2 {
            XCTFail("Store count doesn't match")
        }

        debugPrint(features.stores())
    }

    func testAddFeatureFlagsAddingSameStore() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")

        features.addFeatureFlags(defaultStore)
        features.addFeatureFlags(asyncStore)

        if features.stores().count != 2 {
            XCTFail("Store count doesn't match")
        }

        features.addFeatureFlags(defaultStore)

        if features.stores().count != 2 {
            XCTFail("Store was added again instead of replacing")
        }
    }

    func testIsFeatureEnabledForBoolExpectedTrue() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")
        features.addFeatureFlags(defaultStore)

        let enabled = features.feature("flag-1")

        if enabled != true {
            XCTFail("Didn't return true for bool feature flag")
        }
    }

    func testIsFeatureEnabledForBoolExpectedFalse() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")
        features.addFeatureFlags(defaultStore)

        let enabled = features.feature("flag-1-disabled")

        if enabled != false {
            XCTFail("Didn't return false for bool feature flag")
        }
    }

    func testIsFeatureEnabledForStringExpectedTrue() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")
        features.addFeatureFlags(defaultStore)

        if features.feature("flag-2") != true {
            XCTFail("Didn't return true for string feature flag")
        }

        if features.feature("flag-2-major") != true {
            XCTFail("Didn't return true for string feature flag")
        }
    }

    func testIsFeatureEnabledForStringExpectedFalse() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")
        features.addFeatureFlags(defaultStore)

        let enabled = features.feature("flag-2-disabled")

        if enabled != false {
            XCTFail("Didn't return false for string feature flag")
        }
    }

    func testIsFeatureEnabledDefaultValueExpectedFalse() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")
        features.addFeatureFlags(defaultStore)

        let enabled = features.feature("flag-that-doesnt-exist")

        if enabled != false {
            XCTFail("Return true when should have been false")
        }
    }

    func testIsFeatureEnabledShouldUseOverriddenValue() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")
        features.addFeatureFlags(defaultStore)

        let enabled = features.feature("flag-1")

        if enabled != true {
            XCTFail("Didn't return true for bool feature flag")
        }

        features.addFeatureFlags(asyncStore)

        if features.isCacheEmpty() != true {
            XCTFail("Cache didn't clear")
        }

        let overridden = features.feature("flag-1")

        if overridden != false {
            XCTFail("Didn't return overridden value")
        }
    }

    func testAddingNewFeatureStoreShouldClearTheCache() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")
        features.addFeatureFlags(defaultStore)

        _ = features.feature("flag-1")

        if features.isCacheEmpty() == true {
            XCTFail("Cache is empty")
        }

        features.addFeatureFlags(asyncStore)

        if features.isCacheEmpty() == false {
            XCTFail("Cache didn't clear when adding new store")
        }
    }

    func testPerformanceAddFeatureFlags() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")

        self.measure {
            features.addFeatureFlags(defaultStore)
            features.addFeatureFlags(asyncStore)
        }
    }

    func testPerformanceIsEnabledForBool() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")
        features.addFeatureFlags(defaultStore)
        self.measure {
            if features.feature("flag-1") == false {
                XCTFail("Didn't return true for feature flag")
            }
        }
    }

    func testPerformanceIsEnabledForString() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")
        features.addFeatureFlags(defaultStore)
        self.measure {
            if features.feature("flag-2") == false {
                XCTFail("Didn't return true for feature flag")
            }
        }
    }

    func testPerformanceIsEnabledCachedChecks() throws {
        let features = FeatureKit(bundleVersion: "5.27.0")
        features.addFeatureFlags(defaultStore)
        let nonCached = features.feature("flag-2")
        if nonCached == false {
            XCTFail("Didn't return true for feature flag")
        }
        self.measure {
            let cached = features.feature("flag-2")
            if cached == false {
                XCTFail("Didn't return true for feature flag")
            }
        }
    }
}
