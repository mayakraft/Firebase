//
//  Fire.swift
//  Browse
//
//  Created by Robby on 8/11/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import Firebase

class Fire {
	
	static let shared = Fire()
	
	let database : FIRDatabaseReference = FIRDatabase.database().reference()
	
	// snapshot from the last call to "loadData"
	var data: AnyObject?

	private init() { }
	
	// childURL = nil returns the root of the database
	// childURL can contain multiple subdirectories separated with a slash: "one/two/three"
	func loadData(childURL:String?, completionHandler: (AnyObject?) -> ()) {
		var reference = database
		if(childURL != nil){
			reference = database.child(childURL!)
		}
		reference.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil)
			} else {
				self.data = snapshot.value
				completionHandler(snapshot.value)
			}
		}
	}
}