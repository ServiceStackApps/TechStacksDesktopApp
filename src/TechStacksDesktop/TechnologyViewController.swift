//
//  TechnologyViewController.swift
//  TechStacksDesktop
//
//  Created by Demis Bellot on 2/11/15.
//  Copyright (c) 2015 ServiceStack LLC. All rights reserved.
//

import AppKit
import Foundation

class TechnologyViewController : NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var cboField: NSComboBox!
    @IBOutlet weak var cboQueryType: NSComboBox!
    @IBOutlet weak var txtSearch: NSTextField!
    @IBOutlet weak var tblResults: NSTableView!
    @IBOutlet weak var lblError: NSTextField!
    
    @IBAction func onSearchChange(sender: NSTextField) {
        search()
    }
    
    @IBAction func search(sender: NSButton) {
        search()
    }
    
    func search() {
        lblError.stringValue = ""
        self.appData.searchTechnologies(txtSearch.stringValue,
            field: cboField.objectValueOfSelectedItem as? String,
            operand: cboQueryType.objectValueOfSelectedItem as? String)
            .error { (e:NSError) -> Void in
                self.lblError.stringValue = e.responseStatus.message ?? ""
            }
    }
    
    override func viewDidLoad() {
        tblResults.setDataSource(self)
        tblResults.setDelegate(self)
        populateComboBoxFields()
        
        self.appData.searchTechnologies(txtSearch.stringValue)
        self.appData.observe(self, properties: [AppData.Property.FilteredTechnologies])
    }
    
    func populateComboBoxFields() {
        let names = Technology.properties.map { $0.name.titleCase }
        cboField.addItemsWithObjectValues(names)
        cboQueryType.addItemsWithObjectValues(appData.autoQueryOperands.map { $0.0 })
        
        
        cboField.selectItemAtIndex(0)
        cboQueryType.selectItemAtIndex(0)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        tblResults.reloadData()
    }
    deinit { self.appData.unobserve(self) }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return appData.filteredTechnologies.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let name = tableColumn?.identifier {
            if let cell = tableView.makeViewWithIdentifier(name, owner: self) as? NSTableCellView {
                if let property = Technology.propertyMap[name.lowercaseString] {
                    let dto = appData.filteredTechnologies[row]
                    cell.textField?.stringValue = property.stringValueAny(dto) ?? ""
                    return cell
                }
            }
        }
        return nil
    }
    
}