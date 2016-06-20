//
//  BundleManager.swift
//  SyntaxKit
//
//  Created by Alexander Hedges on 15/02/16.
//  Copyright © 2016 Alexander Hedges. All rights reserved.
//

public class BundleManager {
    
    // MARK: - Types
    
    public typealias BundleLocationCallback = (identifier: String, isLanguage: Bool) -> (NSURL?)
    
    
    // MARK: - Properties
    
    public static var defaultManager: BundleManager?
    
    private var bundleCallback: BundleLocationCallback
    private var dependencies: [Language] = []
    private var cachedThemes: [String: Theme] = [:]
    
    
    // MARK: - Initializers
    
    public class func initializeDefaultManagerWithLocationCallback(callback: BundleLocationCallback) {
        defaultManager = BundleManager(callback: callback)
    }
    
    init(callback: BundleLocationCallback) {
        self.bundleCallback = callback
    }
    
    
    // MARK: - Public
    
    public func languageWithIdentifier(identifier: String) -> Language? {
        self.dependencies = []
        var language = self.getUnvalidatedLanguageWithIdentifier(identifier)!
        language.validateWithHelperLanguages(self.dependencies)
        
        return language
    }
    
    public func themeWithIdentifier(identifier: String) -> Theme? {
        guard let dictURL = self.bundleCallback(identifier: identifier, isLanguage: false),
            plist = NSDictionary(contentsOfURL: dictURL),
            newTheme = Theme(dictionary: plist as [NSObject : AnyObject]) else {
                return nil
        }
        
        cachedThemes[identifier] = newTheme
        return newTheme
    }
    
    
    // MARK: - Internal Interface
    
    func getUnvalidatedLanguageWithIdentifier(identifier: String) -> Language? {
        guard let dictURL = self.bundleCallback(identifier: identifier, isLanguage: true),
            plist = NSDictionary(contentsOfURL: dictURL),
            newLanguage = Language(dictionary: plist as [NSObject : AnyObject]) else {
                return nil
        }
        
        self.dependencies.append(newLanguage)
        return newLanguage
    }
}
