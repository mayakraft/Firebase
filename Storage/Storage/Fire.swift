//
//  Fire.swift
//  Browse
//
//  Created by Robby on 8/11/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import Firebase

let IMAGE_DIRECTORY:String = "images/"
let DOCUMENT_DIRECTORY:String = "documents/"

enum StorageFileType {
	case IMAGE_JPG, IMAGE_PNG, DOCUMENT_PDF
}

func stringForStorageFileType(fileType:StorageFileType) -> String {
	switch fileType {
	case .IMAGE_JPG:    return "JPG"
	case .IMAGE_PNG:    return "PNG"
	case .DOCUMENT_PDF: return "PDF"
	}
}

class Fire {
	
	static let shared = Fire()
	
	let database : FIRDatabaseReference = FIRDatabase.database().reference()
	let storage = FIRStorage.storage().reference()
	
	// snapshot from the last call to "loadData"
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
				self.data = snapshot.value
				completionHandler(snapshot.value)
			}
		}
	}
	
	// specify a UUIDFilename, or it will generate one for you
	func uploadFileAndMakeRecord(data:NSData, fileType:StorageFileType, UUIDFilename:String?, completionHandler: (filename:String?, downloadURL:NSURL?) -> ()) {

		// prep file info
		var filename:String = NSUUID.init().UUIDString
		if(UUIDFilename != nil){
			filename = UUIDFilename!
		}
		var storagePath:String
		var databaseDirectory:String
		switch fileType {
			case .IMAGE_JPG:
				filename = filename + ".jpg"
				storagePath = IMAGE_DIRECTORY + filename
				databaseDirectory = "files/" + IMAGE_DIRECTORY
				break
			case .IMAGE_PNG:
				filename = filename + ".png"
				storagePath = IMAGE_DIRECTORY + filename
				databaseDirectory = "files/" + IMAGE_DIRECTORY
				break
			case .DOCUMENT_PDF:
				filename = filename + ".pdf"
				storagePath = DOCUMENT_DIRECTORY + filename
				databaseDirectory = "files/" + DOCUMENT_DIRECTORY
				break
		}
		
		// STEP 1 - upload file to storage
		currentUpload = storage.child(storagePath).putData(data, metadata: nil) { metadata, error in
			// TODO: make currentUpload an array, if upload in progress add this to array
			if (error != nil) {
				print(error)
				completionHandler(filename: nil, downloadURL: nil)
			} else {
				// STEP 2 - record new file in database
				let downloadURL = metadata!.downloadURL()!
				let key = self.database.child(databaseDirectory).childByAutoId().key
				let entry:Dictionary = ["file":storagePath,
				                        "type":stringForStorageFileType(fileType),
				                        "url":downloadURL.absoluteString]
				self.database.child(databaseDirectory).updateChildValues([key:entry]) { (error, ref) in
					completionHandler(filename: filename, downloadURL: downloadURL)
				}
			}
		}
	}
}

