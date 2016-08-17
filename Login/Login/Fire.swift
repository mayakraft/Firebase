//
//  FireUser.swift
//  Login
//
//  Created by Robby on 8/6/16.
//  Copyright © 2016 Robby. All rights reserved.
//

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
	case IMAGE_JPG, IMAGE_PNG, DOCUMENT_PDF
}

class Fire {
	static let shared = Fire()
	
	let database: FIRDatabaseReference = FIRDatabase.database().reference()
	let storage = FIRStorage.storage().reference()
	
	// snapshot from the last call to "loadData"
	var data: AnyObject?
	
	// can monitor, pause, resume the current upload task
	var currentUpload:FIRStorageUploadTask?
	
	var myUID:String?
	
	private init() {
		// setup USER listener
		FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
			if user != nil {
				print("   AUTH LISTENER: user \(user?.email!) signed in")
				self.myUID = user?.uid
				self.checkIfUserExists(user!, completionHandler: { (exists) in
					if(exists){ }
					else{
						self.createUserInDatabase(user!)
					}
				})
			} else {
				self.myUID = nil
				print("   AUTH LISTENER: no user")
			}
		}
	}

	
	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  DATABASE
	
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
	

	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  USER
	
	func checkIfUserExists(user: FIRUser, completionHandler: (Bool) -> ()) {
		database.child("users").child(user.uid).observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(false)
			} else {
				completionHandler(true)
			}
//			print("all the users:")
//			print(everything)
		}
	}
	
	func updateUserWithKeyAndValue(key:String, value:AnyObject, completionHandler: ((success:Bool) -> ())? ) {
		print("saving \(value) into \(key)")
		let user = FIRAuth.auth()?.currentUser
		database.child("users").child(user!.uid).updateChildValues([key:value]) { (error, ref) in
			if (error == nil){
				if(completionHandler != nil){
					completionHandler!(success: true)
				}
			} else{
				if(completionHandler != nil){
					completionHandler!(success: false)
				}
			}
		}
	}
	
	func createUserInDatabase(user:FIRUser){
		let emailString:String = user.email!
		let newUser = [
			"email": emailString,
			"createdAt": NSDate.init().timeIntervalSince1970
		]
		database.child("users").child(user.uid).setValue(newUser)
		print("added \(emailString) to the database")
	}
	
	func getUser(completionHandler: (String?, NSDictionary?) -> ()) {
		let user = FIRAuth.auth()?.currentUser
		database.child("users").child(user!.uid).observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil, nil)
			} else {
				let userData:NSDictionary? = snapshot.value as! NSDictionary?
				completionHandler(user!.uid, userData)
			}
		}
	}
	
	func user() -> FIRUser {
		return (FIRAuth.auth()?.currentUser)!
	}
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  STORAGE
	
	// specify a UUIDFilename, or it will generate one for you
	func uploadFileAndMakeRecord(data:NSData, fileType:StorageFileType, description:String?, completionHandler: (downloadURL:NSURL?) -> ()) {
		
		// prep file info
		var filename:String = NSUUID.init().UUIDString
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
				completionHandler(downloadURL: nil)
			} else {
				// STEP 2 - record new file in database
				let downloadURL = metadata!.downloadURL()!
				let key = self.database.child(databaseDirectory).childByAutoId().key
				var descriptionString:String = ""
				if(description != nil){
					descriptionString = description!
				}
				let entry:Dictionary = ["file":storagePath,
				                        "type":stringForStorageFileType(fileType),
				                        "description":descriptionString,
				                        "url":downloadURL.absoluteString]
				self.database.child(databaseDirectory).updateChildValues([key:entry]) { (error, ref) in
					completionHandler(downloadURL: downloadURL)
				}
			}
		}
	}
}

func stringForStorageFileType(fileType:StorageFileType) -> String {
	switch fileType {
	case .IMAGE_JPG:    return "JPG"
	case .IMAGE_PNG:    return "PNG"
	case .DOCUMENT_PDF: return "PDF"
	}
}

