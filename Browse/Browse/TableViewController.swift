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

	var data: AnyObject?// : Dictionary<String, AnyObject>?
//	{
//		get{
//			return self.data
//		}
//		set{
//			self.data = newValue
//			keyArray = Array(self.data!.keys)
//		}
//	}

	var keyArray : Array<String>?

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if(self.data != nil){
			return 1
		}
		return 0
	}
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if(self.data is [String:AnyObject]){
			if(self.keyArray != nil){
				return self.keyArray!.count
			}
		}
		else if(self.data is [AnyObject]){
			return (self.data?.count)!
		}
		return 0
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		var text: String = ""
		if(self.data is [String:AnyObject]){
			text = String(self.keyArray![indexPath.row])
		}
		else if(self.data is [AnyObject]){
//			let arr = self.data as! Array<AnyObject>
			text = String(indexPath.row)//arr[indexPath.row] as! String
		}
		cell.textLabel?.text = text
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let vc: TableViewController = TableViewController()
		if(self.data is [AnyObject]){
			let d = self.data! as! Array<AnyObject>
			if(d[indexPath.row] is [AnyObject]){
				print("next view is a ARRAY")
				let nextData: Array = (d[indexPath.row] as? Array<AnyObject>)!
				vc.data = nextData
				self.navigationController?.pushViewController(vc, animated: true)
			}
			if(d[indexPath.row] is [String:AnyObject]){
				print("next view is a DICTIONARY")
				let nextData: Dictionary = (d[indexPath.row] as? Dictionary<String, AnyObject>)!
				vc.data = nextData
				vc.keyArray = Array(nextData.keys)
				self.navigationController?.pushViewController(vc, animated: true)
			}
		}
		if(self.data is [String:AnyObject]){
			let key: String = keyArray![indexPath.row]
			let d = self.data![key]
			let type = String(d.dynamicType)
			print(type)
			if(self.data![key] is [AnyObject]){
				print("next view is an ARRAY")
				let nextData: Array = (self.data![key] as? Array<AnyObject>)!
				vc.data = nextData
				self.navigationController?.pushViewController(vc, animated: true)
			}
			if(self.data![key] is [String:AnyObject]){
				print("next view is a DICTIONARY")
				let nextData: Dictionary = (self.data![key] as? Dictionary<String, AnyObject>)!
				vc.data = nextData
				vc.keyArray = Array(nextData.keys)
				self.navigationController?.pushViewController(vc, animated: true)
			}
		}
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
}

