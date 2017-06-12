//  Fire.swift
//  Created by Robby on 8/6/16.
//  Copyright © 2016 Robby. All rights reserved.

/////////////////////////////////////////////////////////////////////////
// THREE PARTS: DATABASE, USER, STORAGE

// DATABASE:
// guards for setting and retrieving data
// handling all types of JSON data: nil, bool, int, float, string, array, dictionary
// Firebase uses Arrays which takes some extra safeguarding to manage

// USER:
// Firebase comes with FireAuth with a "user" class, but you can't edit it.
// this singleton is for making and managing a separate "users" class
//  - each user is stored under their user.uid
//  - can add as many fields as you want (nickname, photo, etc..)

// STORAGE:
// since Firebase Storage doesn't keep track of the files you upload,
// this maintains a record of the uploaded files in your database

import Firebase

let STORAGE_IMAGE_DIR:String = "images/"
let STORAGE_DOCUMENT_DIR:String = "documents/"

enum JSONDataType {
	case isBool, isInt, isFloat, isString, isArray, isDictionary, isURL, isNULL
	// isURL is a special kind of string, kind of weird design i know, but it ends up being helpful
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
	
	var myUID:String?  // if you are logged in, if not, == nil
	
	fileprivate init() {
		// setup USER listener
		FIRAuth.auth()?.addStateDidChangeListener { auth, listenerUser in
			if let user = listenerUser {
				print("SIGN IN: \(user.email ?? user.uid)")
				self.myUID = user.uid
				self.userExists(user, completionHandler: { (exists) in
					if(!exists){
						self.newUser(user, completionHandler: nil)
					}
				})
			} else {
				self.myUID = nil
				print("SIGN OUT: no user")
			}
		}
		
		let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
		connectedRef.observe(.value, with: { snapshot in
			if let connected = snapshot.value as? Bool , connected {
				// internet connected
				// banner alert
			} else {
				// internet disconnected
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
	func setData(_ object:Any, at path:String, completionHandler: ((Bool, FIRDatabaseReference) -> ())?) {
		self.database.child(path).setValue(object) { (error, ref) in
			if let e = error{
				print(e.localizedDescription)
				if let completion = completionHandler{
					completion(false, ref)
				}
			} else{
				if let completion = completionHandler{
					completion(true, ref)
				}
			}
		}
	}
	
	// add an object AS A CHILD to the path, returns the key to that object
	//   ONLY if the object at path is a dictionary or array
	//   if it is a leaf (String, Number, Bool) it doesn't do anything (prevents overwriting)
	func addData(_ object:Any, asChildAt path:String, completionHandler: ((_ success:Bool, _ newKey:String?, FIRDatabaseReference?) -> ())?) {
		self.doesDataExist(at: path) { (exists, dataType, data) in
			switch dataType{
			//  1) if array, it MAINTAINS the array structure (number key, not dictionary string key)
			case .isArray:
				let dbArray = data as! NSMutableArray
				dbArray.add(object)
				self.database.child(path).setValue(dbArray) { (error, ref) in
					if let e = error{
						print(e.localizedDescription)
						if let completion = completionHandler{
							completion(false, nil, nil)
						}
					} else{
						if let completion = completionHandler{
							completion(true, String(describing:dbArray.count-1), ref)
						}
					}
				}
			// 2) if dictionary, or doesn't exist, makes a new string key like usual
			case .isDictionary, .isNULL:
				self.database.child(path).childByAutoId().setValue(object) { (error, ref) in
					if let e = error{
						print(e.localizedDescription)
						if let completion = completionHandler{
							completion(false, nil, nil)
						}
					} else{
						if let completion = completionHandler{
							completion(true, ref.key, ref)
						}
					}
				}
			// 3) if object at path is a String or Int etc..(leaf node), return without doing anything
			default:
				if let completion = completionHandler{
					completion(false, nil, nil);
				}
			}
		}
	}


	func doesDataExist(at path:String, completionHandler: @escaping (_ doesExist:Bool, _ dataType:JSONDataType, _ data:Any?) -> ()) {
		database.child(path).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			if let data = snapshot.value{
				completionHandler(true, self.typeOf(FirebaseData: data), data)
			} else{
				completionHandler(false, .isNULL, nil)
			}
		}
	}

	
	func typeOf(FirebaseData object:Any) -> JSONDataType {
		if object is NSNumber{
			let nsnum = object as! NSNumber
			let boolID = CFBooleanGetTypeID() // the type ID of CFBoolean
			let numID = CFGetTypeID(nsnum) // the type ID of num
			if numID == boolID{
				return .isBool
			}
			if nsnum.floatValue == Float(nsnum.intValue){
				return .isInt
			}
			return .isFloat
		} else if object is String {
			if let url: URL = URL(string: object as! String) {
				if UIApplication.shared.canOpenURL(url){
					return .isURL
				} else{
					return .isString
				}
			} else{
				return .isString
			}
		} else if object is NSArray || object is NSMutableArray{
			return .isArray
		} else if object is NSDictionary || object is NSMutableDictionary{
			return .isDictionary
		}
		return .isNULL
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
			storagePath = STORAGE_IMAGE_DIR + filename
			databaseDirectory = "files/" + STORAGE_IMAGE_DIR
			break
		case .PNG:
			filename = filename + ".png"
			storagePath = STORAGE_IMAGE_DIR + filename
			databaseDirectory = "files/" + STORAGE_IMAGE_DIR
			break
		case .PDF:
			filename = filename + ".pdf"
			storagePath = STORAGE_DOCUMENT_DIR + filename
			databaseDirectory = "files/" + STORAGE_DOCUMENT_DIR
			break
		}
		
		// STEP 1 - upload file to storage
		currentUpload = storage.child(storagePath).put(data, metadata: nil) { metadata, error in
			// TODO: make currentUpload an array, if upload in progress add this to array
			if let e = error {
				print(e.localizedDescription)
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
