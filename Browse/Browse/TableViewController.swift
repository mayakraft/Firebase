//
//  ViewController.swift
//  Browse
//
//  Created by Robby on 8/10/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

class TableViewController: UITableViewController {
	
	// if tableview's datasource is a DICTIONARY:
	//    it populates its rows with its KEYS
	// if datasource is ARRAY
	//    it populates with array (indexPath row numbers)
	
	var keyArray : Array<String>?  // only used if dataSource is a DICTIONARY
	
	// the DATA SOURCE
	var data: AnyObject? {
		didSet{
			if(self.data is [String:AnyObject]){
				let d:[String:AnyObject] = self.data as! [String:AnyObject]
				keyArray = Array(d.keys)
			}
		}
	}
	
	var address: URL?
	
	func showingArray() -> Bool {
		return self.data is [AnyObject]
	}
	func showingDictionary() -> Bool {
		return self.data is [String:AnyObject]
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if(self.data != nil){
			return 1
		}
		return 0
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(showingArray()){
			return (self.data?.count)!
		}
		if(showingDictionary()){
			if(self.keyArray != nil){
				return self.keyArray!.count
			}
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if(address != nil){
			return String(describing: address!)
		}
		return nil
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "tableCell")
		var text: String = ""
		var detailText: String = ""
		var nextObject: AnyObject?
		
		if(showingArray()){
			text = String(indexPath.row)
			let dataArray = self.data! as! [AnyObject]
			nextObject = dataArray[indexPath.row]
		}
		if(showingDictionary()){
			text = String(self.keyArray![indexPath.row])
			let dataDictionary = self.data! as! [String:AnyObject]
			nextObject = dataDictionary[ self.keyArray![indexPath.row] ]
		}
		
		if(nextObject is [String:AnyObject]){
			detailText = "Dictionary"
		}
		if(nextObject is [AnyObject]){
			detailText = "Array"
		}
		if(nextObject is String || nextObject is Int || nextObject is Float || nextObject is Bool){
			detailText = String(describing: nextObject!)
		}
		
		cell.textLabel?.text = text
		cell.detailTextLabel?.text = detailText
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var nextObject:AnyObject?
		var nextTitle:String = ""
		
		// depending on DICTIONARY or ARRAY, let's grab the next object to show
		if(showingArray()){
			let dataArray = self.data! as! [AnyObject]
			nextObject = dataArray[indexPath.row]
			nextTitle = String(indexPath.row)
		}
		if(showingDictionary()){
			let key: String = keyArray![indexPath.row]
			let dataDictionary = self.data! as! [String:AnyObject]
			nextObject = dataDictionary[ key ]
			nextTitle = String(self.keyArray![indexPath.row])
		}
		
		// if this element is the leaf (last level down)
		if(nextObject is String || nextObject is Int || nextObject is Float || nextObject is Bool){
			let vc: ObjectViewController = ObjectViewController()
			vc.data = nextObject
//			vc.title = nextTitle
			self.navigationController?.pushViewController(vc, animated: true)
		}
			// if there are more levels below
		else{
			let vc: TableViewController = TableViewController()
			vc.data = nextObject
			vc.title = nextTitle
			vc.address = self.address?.appendingPathComponent(nextTitle)
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
}

