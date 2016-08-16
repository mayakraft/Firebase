//
//  Fire.swift
//  Browse
//
//  Created by Robby on 8/11/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import Firebase

enum StorageFileType {
	case IMAGE_JPG, IMAGE_PNG, DOCUMENT_PDF
}

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
	
	func uploadFileAndMakeRecord(data:NSData, fileType:StorageFileType, completionHandler: (filename:String?, downloadURL:NSURL?) -> ()) {
		
		var path:String
		var filename:String = NSUUID.init().UUIDString

		switch fileType {
			case .IMAGE_JPG:
				filename = filename + ".jpg"
				path = "files/images/" + filename
				break
			case .IMAGE_PNG:
				filename = filename + ".png"
				path = "files/images/" + filename
				break
			case .DOCUMENT_PDF:
				filename = filename + ".pdf"
				path = "files/documents/" + filename
				break
		}
		
		// TODO: make currentUpload an array, if upload in progress add this to array
		currentUpload = storage.child(path).putData(data, metadata: nil) { metadata, error in
			if (error != nil) {
				print(error)
				completionHandler(filename: nil, downloadURL: nil)
			} else {
				// Metadata contains file metadata such as size, content-type, and download URL.
				let downloadURL = metadata!.downloadURL()
				completionHandler(filename: filename, downloadURL: downloadURL)
				self.saveImageNameToDatabase(filename)
			}
		}
	}
	func saveImageNameToDatabase(filename:String){
		print("UPLOAD SUCCESS: copying \(filename) into images database")
		let key = database.child("images").childByAutoId().key
		database.child("images").updateChildValues([key:filename])
	}
}

