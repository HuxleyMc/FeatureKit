//
//  FeatureKit.swift
//  FeatureKit
//
//  Created by Huxley McGuffin on 27/5/2023.
//

import Foundation
import Version

struct FeatureStore {
    // Used for internal filtering
    private let id = UUID()
    /// Used for adding priority to the feature flag check
    ///
    /// Example a order of 1 would be checked before 2
    ///
    /// This useful for the case where you might have default which could be order 99
    /// and at a later stage you fetch client feature flags which should take priority over the defaults
    var order: Float
    var name: String
    var flags: [String: StringOrBool] = [:]
}

func parseAppVersion(_ bundleVersion: String) -> Version {
    let appVersion = Version(bundleVersion) ?? .null
    return appVersion
}

class FeatureKit {
    private var fallbackValue: Bool = false
    private var v2Cache: [String: Bool] = [:]
    private var appVersion: Version = .null
    private var flagStores: [FeatureStore] = []
   
    var logger: Bool = false
    
    var shouldCache: Bool = true
    
    init(bundleVersion: String) {
        self.appVersion = parseAppVersion(bundleVersion)
    }
    
    func stores() -> [FeatureStore] {
        self.flagStores
    }
    
    func isCacheEmpty() -> Bool {
        self.v2Cache.isEmpty
    }
    
    private func log(_ items: Any...) {
        if self.logger == false {
            return
        }
        print("[FeatureKit]", items)
    }
    
    /// Add a new feature store or update an existing one
    ///
    /// Note: All feature flag will be removed from the cache
    func addFeatureFlags(_ featureFlags: FeatureStore) {
        self.v2Cache.removeAll()
        
        let currentStoreIndex = self.flagStores.firstIndex(where: { store in
            store.name == featureFlags.name
        })
        
        if currentStoreIndex != nil {
            self.flagStores.remove(at: currentStoreIndex!)
        }
        
        self.flagStores.append(featureFlags)
        self.flagStores.sort { storeA, storeB in
            storeA.order < storeB.order
        }
    }
    
    /// Remove all feature flag checks from the cache
    func flushCache() {
        self.v2Cache.removeAll()
    }
    
    private func cacheFlag(key: String, value: Bool) {
        if self.shouldCache == false {
            return
        }
        log("Caching \(key) with value \(value)")
        self.v2Cache[key] = value
    }
    
    /// Check if a feature flag is enabled or disabled
    func feature(_ flagKey: String, _ fallback: Bool = false) -> Bool {
        var enabled: Bool = fallback
        
        if self.shouldCache {
            let cachedValue = self.v2Cache[flagKey]
            
            if cachedValue != nil {
                return cachedValue!
            }
        }
        
        for store in self.flagStores {
            self.log("Checking for \(flagKey) in \(store.name) with order \(store.order)")
            let flagValue = store.flags[flagKey]
            if flagValue != nil {
                let value = flagValue!
                
                if value.bool() != nil {
                    enabled = value.bool()!
                    
                    self.cacheFlag(key: flagKey, value: enabled)
                    
                    return enabled
                }
                    
                if value.string() != nil {
                    let parsedVer = Version(value.string()!) ?? .null
                    enabled = self.appVersion <= parsedVer
                    
                    self.cacheFlag(key: flagKey, value: enabled)
                    
                    return enabled
                }
                
                return enabled
            }
        }
        
        return enabled
    }
}
