//
//  AppData.swift
//  TechStacksDesktop
//
//  Created by Demis Bellot on 2/9/15.
//  Copyright (c) 2015 ServiceStack LLC. All rights reserved.
//

import Foundation

open class AppData : NSObject
{
    var client = JsonServiceClient(baseUrl: "http://techstacks.io")
    
    struct Property {
        static let FilteredTechStacks = "filteredTechStacks"
        static let FilteredTechnologies = "filteredTechnologies"
    }
    
    open dynamic var search:String?
    open dynamic var filteredTechStacks:[TechnologyStack] = []
    open dynamic var filteredTechnologies:[Technology] = []
    
    open var autoQueryOperands = [
        ("=",  "%"),
        (">=", ">%"),
        (">",  "%>"),
        ("<=", "%<"),
        ("<",  "<%"),
        ("In", "%In"),
        ("Between", "%Between"),
        ("Starts With", "%StartsWith"),
        ("Contains", "%Contains"),
        ("Ends With", "%EndsWith"),
    ]
    
    lazy open var autoQueryOperandsMap:[String:String] = {
        var map = [String:String]()
        self.autoQueryOperands.forEach { map[$0] = $1 }
        return map
    }()
    
    func createAutoQueryParam(_ field:String, _ operand:String) -> String {
        let template = autoQueryOperandsMap[operand]!
        let mergedField = template.replace("%", withString:field)
        return mergedField
    }
    
    func searchTechStacks(_ query:String, field:String? = nil, operand:String? = nil) -> Promise<QueryResponse<TechnologyStack>> {
        self.search = query
        
        let queryString = query.count > 0 && field != nil && operand != nil
            ? [createAutoQueryParam(field!, operand!): query]
            : ["NameContains":query, "DescriptionContains":query]
        
        let request = FindTechStacks<TechnologyStack>()
        return client.getAsync(request, query:queryString)
            .then { r -> QueryResponse<TechnologyStack> in
                self.filteredTechStacks = r.results
                return r
            }
    }
    
    func searchTechnologies(_ query:String, field:String? = nil, operand:String? = nil) -> Promise<QueryResponse<Technology>> {
        self.search = query

        let queryString = query.count > 0 && field != nil && operand != nil
            ? [createAutoQueryParam(field!, operand!): query]
            : ["NameContains":query, "DescriptionContains":query]
        
        let request = FindTechnologies<Technology>()
        return client.getAsync(request, query:queryString)
            .then { r -> QueryResponse<Technology> in
                self.filteredTechnologies = r.results
                return r
            }
    }

    var observedProperties = [NSObject:[String]]()
    var ctx:AnyObject = 1 as AnyObject
    
    open func observe(_ observer: NSObject, properties:[String]) {
        for property in properties {
            self.observe(observer, property: property)
        }
    }
    
    open func observe(_ observer: NSObject, property:String) {
        self.addObserver(observer, forKeyPath: property, options: [.new, .old], context: &ctx)
        
        var properties = observedProperties[observer] ?? [String]()
        properties.append(property)
        observedProperties[observer] = properties
    }
    
    open func unobserve(_ observer: NSObject) {
        if let properties = observedProperties[observer] {
            for property in properties {
                self.removeObserver(observer, forKeyPath: property, context: &ctx)
            }
        }
    }
}
