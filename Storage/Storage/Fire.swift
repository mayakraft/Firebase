//  Fire.swift
//  Created by Robby on 8/6/16.
//  Copyright © 2016 Robby. All rights reserved.

/////////////////////////////////////////////////////////////////////////
// THREE PARTS: STORAGE, USER, DATABASE

// STORAGE:
// since Firebase Storage doesn't keep track of the files you upload,
// this maintains a record of the uploaded files in your database

// USER:
// Firebase comes with FireAuth with a "user" class, but you can't edit it.
// this singleton is for making and managing a separate "users" class
//  - each user is stored under their user.uid
//  - can add as many fields as you want (nickname, photo, etc..)


import Firebase

let IMAGE_DIRECTORY:String = "images/"
let DOCUMENT_DIRECTORY:String = "documents/"

enum StorageFileType {
	case image_JPG, image_PNG, document_PDF
}

class Fire {
	static let shared = Fire()
	
	let database: FIRDatabaseReference = FIRDatabase.database().reference()
	let storage = FIRStorage.storage().reference()
	
	// this is up to you to manage - but cache database calls here if you want.
	var databaseCache: AnyObject?
	
	// can monitor, pause, resume the current upload task
	var currentUpload:FIRStorageUploadTask?
	
	var myUID:String?
	
	fileprivate init() {
		let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
		connectedRef.observe(.value, with: { snapshot in
			if let connected = snapshot.value as? Bool , connected {
				print("INTERNET CONNECTION ESTABLISHED")
			} else {
				print("INTERNET CONNECTION DOWN")
			}
		})
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  DATABASE
	
	// childURL = nil returns the root of the database
	// childURL can contain multiple subdirectories separated with a slash: "one/two/three"
	func loadData(_ childURL:String?, completionHandler: @escaping (AnyObject?) -> ()) {
		var reference = database
		if(childURL != nil){
			reference = database.child(childURL!)
		}
		reference.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil)
			} else {
				completionHandler(snapshot.value as AnyObject?)
			}
		}
	}
	
	func newUniqueObjectAtPath(_ childURL:String, object:AnyObject, completionHandler: (() -> ())?) {
		database.child(childURL).childByAutoId().setValue(object) { (error, ref) in
			if(completionHandler != nil){
				completionHandler!()
			}
		}
	}

	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  STORAGE
	
	// specify a UUIDFilename, or it will generate one for you
	func uploadFileAndMakeRecord(_ data:Data, fileType:StorageFileType, description:String?, completionHandler: @escaping (_ downloadURL:URL?) -> ()) {
		
		// prep file info
		var filename:String = UUID.init().uuidString
		var storagePath:String
		var databaseDirectory:String
		switch fileType {
		case .image_JPG:
			filename = filename + ".jpg"
			storagePath = IMAGE_DIRECTORY + filename
			databaseDirectory = "files/" + IMAGE_DIRECTORY
			break
		case .image_PNG:
			filename = filename + ".png"
			storagePath = IMAGE_DIRECTORY + filename
			databaseDirectory = "files/" + IMAGE_DIRECTORY
			break
		case .document_PDF:
			filename = filename + ".pdf"
			storagePath = DOCUMENT_DIRECTORY + filename
			databaseDirectory = "files/" + DOCUMENT_DIRECTORY
			break
		}
		
		// STEP 1 - upload file to storage
		currentUpload = storage.child(storagePath).put(data, metadata: nil) { metadata, error in
			// TODO: make currentUpload an array, if upload in progress add this to array
			if (error != nil) {
				print(error)
				completionHandler(nil)
			} else {
				// STEP 2 - record new file in database
				let downloadURL = metadata!.downloadURL()!
				let key = self.database.child(databaseDirectory).childByAutoId().key
				var descriptionString:String = ""
				if(description != nil){
					descriptionString = description!
				}
				let entry:[String:AnyObject] = ["filename":filename as AnyObject,
				                                "path":storagePath as AnyObject,
				                                "type":stringForStorageFileType(fileType) as AnyObject,
				                                "size":data.count as AnyObject,
				                                "description":descriptionString as AnyObject,
				                                "url":downloadURL.absoluteString as AnyObject]
				self.database.child(databaseDirectory).updateChildValues([key:entry]) { (error, ref) in
					completionHandler(downloadURL)
				}
			}
		}
	}
}

func stringForStorageFileType(_ fileType:StorageFileType) -> String {
	switch fileType {
	case .image_JPG:    return "JPG"
	case .image_PNG:    return "PNG"
	case .document_PDF: return "PDF"
	}
}

