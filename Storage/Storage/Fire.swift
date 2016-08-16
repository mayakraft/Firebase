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
	let storage = FIRStorage.storage().reference()
	
	// snapshot of the database
	var data: AnyObject?
	
	// can monitor, pause, resume the current upload task
	var currentUpload:FIRStorageUploadTask?

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
				completionHandler(snapshot.value)
			}
		}
	}
	
	// successful image upload returns
	func uploadImage(data:NSData, completionHandler: (filename:String?, uploadURL:NSURL?) -> ()) {
		let imageName:String = NSUUID.init().UUIDString + ".jpg"
		let path = "images/" + imageName
		print("trying to upload image: \(path)")
		let riversRef = storage.child(path)
		currentUpload = riversRef.putData(data, metadata: nil) { metadata, error in
			if (error != nil) {
				print(error)
				completionHandler(filename: nil, uploadURL: nil)
			} else {
				// Metadata contains file metadata such as size, content-type, and download URL.
				let downloadURL = metadata!.downloadURL()
				completionHandler(filename: imageName, uploadURL: downloadURL)
				self.saveImageNameToDatabase(imageName)
			}
		}
	}
	func saveImageNameToDatabase(filename:String){
		print("UPLOAD SUCCESS: copying \(filename) into images database")
		let key = database.child("images").childByAutoId().key
		database.child("images").updateChildValues([key:filename])
	}
}

