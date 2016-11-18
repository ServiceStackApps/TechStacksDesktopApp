//
//  UIExtensions.swift
//  TechStacksDesktop
//
//  Created by Demis Bellot on 2/9/15.
//  Copyright (c) 2015 ServiceStack LLC. All rights reserved.
//

import AppKit
import Foundation

extension NSView
{
    var appData:AppData {
        return (NSApplication.shared().delegate as! AppDelegate).appData
    }
}

extension NSViewController
{
    var appData:AppData {
        return (NSApplication.shared().delegate as! AppDelegate).appData
    }
}

extension NSTableView
{
    func addTableColumns(_ properties: [PropertyType]) {
        for property in properties {
            let column = NSTableColumn(identifier: property.name)
            
            self.addTableColumn(column)
        }
    }
}

extension String {
    var titleCase:String {
        return String(self[0]).uppercased() + self[1..<self.count]
    }
    var count:Int {
        return self.characters.count
    }
}
