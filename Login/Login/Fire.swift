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

enum FireError: Error {
	case notLoggedIn
	case error1(reason: String)
}

enum StorageFileType : String{
	case JPG, PNG, PDF
}

class Fire {
	static let shared = Fire()
	
	let database: FIRDatabaseReference = FIRDatabase.database().reference()
	let storage = FIRStorage.storage().reference()
	
	// can monitor, pause, resume the current upload task
	var currentUpload:FIRStorageUploadTask?
	
	var myUID:String?
	
	fileprivate init() {
		// setup USER listener
		FIRAuth.auth()?.addStateDidChangeListener { auth, listenerUser in
			if let user = listenerUser {
				print("AUTH LISTENER: user \(user.email!) signed in")
				self.myUID = user.uid
				self.userExists(user, completionHandler: { (exists) in
					if(!exists){
						self.newUser(user, completionHandler: nil)
					}
				})
			} else {
				self.myUID = nil
				print("AUTH LISTENER: no user")
			}
		}
		
		let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
		connectedRef.observe(.value, with: { snapshot in
			if let connected = snapshot.value as? Bool , connected {
				// internet connected :)
				// banner alert
			} else {
				// internet disconnected :(
				// banner alert
			}
		})
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  DATABASE
	
	// childURL = nil returns the root of the database
	// childURL can contain multiple subdirectories separated with a slash: "one/two/three"
	func getData(_ childURL:String?, completionHandler: @escaping (Any?) -> ()) {
		var reference = self.database
		if let url = childURL{
			reference = self.database.child(url)
		}
		reference.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			completionHandler(snapshot.value)
		}
	}
	
	// add an object to the database at a childURL, function returns the auto-generated key to that object
	func setData(_ object:Any, atPath:String, completionHandler: ((Error?, FIRDatabaseReference) -> ())?) {
		self.database.child(atPath).childByAutoId().setValue(object) { (error, ref) in
			if let completion = completionHandler{
				completion(error, ref)
			}
		}
	}


	func dataExists(atPath:String, completionHandler: @escaping (Bool) -> ()) {
		database.child(atPath).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value != nil{
				completionHandler(true)
			} else{
				completionHandler(false)
			}
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  USER
	
	func getUser(_ completionHandler: @escaping (String?, [String:AnyObject]?) -> ()) {
		guard let user = FIRAuth.auth()?.currentUser else{
			completionHandler(nil, nil)
			return
		}
		database.child("users").child(user.uid).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				completionHandler(nil, nil)
			} else {
				let userData:[String:AnyObject]? = snapshot.value as! [String:AnyObject]?
				completionHandler(user.uid, userData)
			}
		}
	}
	
	func newUser(_ user:FIRUser, completionHandler: ((_ success:Bool) -> ())? ) {
		// copy user data over from AUTH
		let emailString:String = user.email!
		let newUser:[String:Any] = [
//			"name"     : user.displayName! ,
//			"image"    : user.photoURL!,
			"email": emailString,
			"createdAt": Date.init().timeIntervalSince1970
		]
		database.child("users").child(user.uid).updateChildValues(newUser) { (error, ref) in
			if error == nil{
				if(completionHandler != nil){
					print("added \(emailString) to the database")
					completionHandler!(true)
				}
			} else{
				// error creating user
				completionHandler!(false)
			}
		}
	}
	
	func userExists(_ user: FIRUser, completionHandler: @escaping (Bool) -> ()) {
		database.child("users").child(user.uid).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value != nil{
				completionHandler(true)
			} else{
				completionHandler(false)
			}
		}
	}
	
	func updateUserWithKeyAndValue(_ key:String, value:Any, completionHandler: ((_ success:Bool) -> ())? ) {
		guard let user = FIRAuth.auth()?.currentUser else{
			if let completion = completionHandler{
				completion(false)
			}
			return
		}
		database.child("users").child(user.uid).updateChildValues([key:value]) { (error, ref) in
			if (error == nil){
				print("saving \(value) into \(key)")
				if(completionHandler != nil){
					completionHandler!(true)
				}
			} else{
				if(completionHandler != nil){
					completionHandler!(false)
				}
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
		case .JPG:
			filename = filename + ".jpg"
			storagePath = IMAGE_DIRECTORY + filename
			databaseDirectory = "files/" + IMAGE_DIRECTORY
			break
		case .PNG:
			filename = filename + ".png"
			storagePath = IMAGE_DIRECTORY + filename
			databaseDirectory = "files/" + IMAGE_DIRECTORY
			break
		case .PDF:
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
				                                "type":fileType.rawValue as AnyObject,
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
