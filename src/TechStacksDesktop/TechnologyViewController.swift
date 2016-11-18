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
    
    @IBAction func onSearchChange(_ sender: NSTextField) {
        search()
    }
    
    @IBAction func search(_ sender: NSButton) {
        search()
    }
    
    func search() {
        lblError.stringValue = ""
        self.appData.searchTechnologies(txtSearch.stringValue,
            field: cboField.objectValueOfSelectedItem as? String,
            operand: cboQueryType.objectValueOfSelectedItem as? String)
            .catch { e in
                self.lblError.stringValue = e.responseStatus.message ?? ""
            }
    }
    
    override func viewDidLoad() {
        tblResults.dataSource = self
        tblResults.delegate = self
        populateComboBoxFields()
        
        self.appData.searchTechnologies(txtSearch.stringValue)
        self.appData.observe(self, properties: [AppData.Property.FilteredTechnologies])
    }
    
    func populateComboBoxFields() {
        let names = Technology.properties.map { $0.name.titleCase }
        cboField.addItems(withObjectValues: names)
        cboQueryType.addItems(withObjectValues: appData.autoQueryOperands.map { $0.0 })
        
        
        cboField.selectItem(at: 0)
        cboQueryType.selectItem(at: 0)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        tblResults.reloadData()
    }
    deinit { self.appData.unobserve(self) }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return appData.filteredTechnologies.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let name = tableColumn?.identifier {
            if let cell = tableView.make(withIdentifier: name, owner: self) as? NSTableCellView {
                if let property = Technology.propertyMap[name.lowercased()] {
                    let dto = appData.filteredTechnologies[row]
                    cell.textField?.stringValue = property.stringValueAny(instance: dto) ?? ""
                    return cell
                }
            }
        }
        return nil
    }
    
}
