//  Fire.swift
//  Created by Robby on 8/6/16.
//  Copyright © 2016 Robby. All rights reserved.

/////////////////////////////////////////////////////////////////////////
// THREE PARTS: DATABASE, USER, STORAGE

// DATABASE:
// guards for setting and retrieving data
// handling all types of JSON data: nil, bool, int, float, string, array, dictionary
// Firebase uses Arrays which takes some extra safeguarding to manage
//
// getData() get data from database
// setData() overwrite data at a certain location in the database
// addData() generate a new key and add data as a child
// doesDataExist() check if data exists at a certain location


// USER:
// Firebase comes with FireAuth with a "user" class, but you can't edit it.
// solution: "users" entry in database with copies of User entries but with more info
//  - each user is stored under their user.uid
//  - can add as many fields as you want (nickname, photo, etc..)
// all the references to "user" are to our database's user entries, not the proper FIRAuth entry
//
//
// getCurrentUser() get all your profile information
// updateCurrentUserWith() update your profile with new information
// newUser() create a new entry for a user (usually for yourself after 1st login)
// userExists() check if a user exists

// STORAGE:
// firebase storage doesn't let you ask for the contents of its folder
// 1) everytime you save an image, it creates an entry for it in your database
//    now you are manually maintaining a list of the contents of your firebase storage
//      (unless you upload by some other means)
//
// 2) this class also maintains a cache of already-loaded images


import Firebase

enum JSONDataType {
	case isBool, isInt, isFloat, isString, isArray, isDictionary, isURL, isNULL
	// isURL is a special kind of string, kind of weird design i know, but it ends up being helpful
}

let STORAGE_IMAGE_DIR:String = "images/"
let STORAGE_DOCUMENT_DIR:String = "documents/"
enum StorageFileType : String{
	case JPG, PNG, PDF
}

struct StorageFileMetadata {
	var filename:String
	var fullpath:String
	var directory:String
	var contentType:String
	var type:StorageFileType
	var size:Int
	var url:URL?
	var description:String?
}

// getting an image requires restriction on anticipated image file size
let IMG_SIZE_MAX:Int64 = 15  // megabytes


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
	
	func getCurrentUser(_ completionHandler: @escaping (String, [String:Any]) -> ()) {
		guard let user = FIRAuth.auth()?.currentUser else{
			return
		}
		database.child("users").child(user.uid).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
			if let userData = snapshot.value as? [String:Any]{
				completionHandler(user.uid, userData)
			} else{
				print("user has no data")
			}
		}
	}
	
	func getUser(UID:String, _ completionHandler: @escaping ([String:Any]) -> ()){
		database.child("users").child(UID).observeSingleEvent(of: .value, with: { (snapshot) in
			if let userData = snapshot.value as? [String:Any]{
				completionHandler(userData)
			}
		})
	}
	
	func updateCurrentUserWith(key:String, object value:Any, completionHandler: ((_ success:Bool) -> ())? ) {
		guard let user = FIRAuth.auth()?.currentUser else{
			if let completion = completionHandler{
				completion(false)
			}
			return
		}
		database.child("users").child(user.uid).updateChildValues([key:value]) { (error, ref) in
			if let e = error{
				print(e.localizedDescription)
				if let completion = completionHandler{
					completion(false)
				}
			} else{
//				print("saving \(value) into \(key)")
				if let completion = completionHandler{
					completion(true)
				}
			}
		}
	}
	
	func newUser(_ user:FIRUser, completionHandler: ((_ success:Bool) -> ())? ) {
		var newUser:[String:Any] = [
			"createdAt": Date.init().timeIntervalSince1970
		]
		// copy user data over from AUTH
		if let nameString  = user.displayName { newUser["name"] = nameString   }
		if let imageURL    = user.photoURL {    newUser["image"] = imageURL    }
		if let emailString = user.email {       newUser["email"] = emailString }
		
		database.child("users").child(user.uid).updateChildValues(newUser) { (error, ref) in
			if let e = error{
				print(e.localizedDescription)
				if let completion = completionHandler{
					completion(false)
				}
			} else{
				if let completion = completionHandler{
					completion(true)
				}
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
	
	////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////
	//
	//  STORAGE
		
	// Key is filename in the images/ folder in the Firebase storage bucket
	// example: "0C5BABB0D5CA.jpg"
	var imageCache:[String:UIImage] = [:]
	
	func imageFromStorageBucket(_ filename: String, completionHandler: @escaping (_ image:UIImage, _ didRequireDownload:Bool) -> ()) {
		if let image = imageCache[filename]{
			//TODO: check timestamp against database, force a data refresh
			completionHandler(image, false)
			return
		}
		
		let storage = FIRStorage.storage().reference()
		let imageRef = storage.child(STORAGE_IMAGE_DIR + filename)
		
		imageRef.data(withMaxSize: IMG_SIZE_MAX * 1024 * 1024) { (data, error) in
			if let e = error{
				print(e.localizedDescription)
			} else{
				if let imageData = data {
					if let image = UIImage(data: imageData){
						self.imageCache[filename] = image
						completionHandler(image, true)
					} else{
						print("problem making image out of received data")
					}
				}
			}
		}
	}
	
	// specify a UUIDFilename, or it will generate one for you
	func uploadFileAndMakeRecord(_ data:Data, fileType:StorageFileType, description:String?, completionHandler: @escaping (_ metadata:StorageFileMetadata) -> ()) {
		
		// prep file info
		var filename:String = UUID.init().uuidString
		var storageDir:String
		let uploadMetadata = FIRStorageMetadata()
		switch fileType {
		case .JPG:
			filename = filename + ".jpg"
			storageDir = STORAGE_IMAGE_DIR
			uploadMetadata.contentType = "image/jpeg"
		case .PNG:
			filename = filename + ".png"
			storageDir = STORAGE_IMAGE_DIR
			uploadMetadata.contentType = "image/png"
		case .PDF:
			filename = filename + ".pdf"
			storageDir = STORAGE_DOCUMENT_DIR
			uploadMetadata.contentType = "application/pdf"
		}
		let filenameAndPath:String = storageDir + filename
		
		// STEP 1 - upload file to storage
		currentUpload = storage.child(filenameAndPath).put(data, metadata: uploadMetadata) { metadata, error in
			// TODO: make currentUpload an array, if upload in progress add this to array
			if let e = error {
				print(e.localizedDescription)
			} else {
				if let meta = metadata{
					// STEP 2 - record new file in database
					var entry:[String:Any] = ["filename":filename,
					                          "fullpath":filenameAndPath,
					                          "directory":storageDir,
					                          "content-type":uploadMetadata.contentType ?? "",
					                          "type":fileType.rawValue,
					                          "size":data.count]

					if let downloadURL = meta.downloadURL(){
						entry["url"] = downloadURL.absoluteString
					}
					if let descriptionString = description{
						entry["description"] = descriptionString
					}
					let key = self.database.child("files/" + storageDir).childByAutoId().key
					self.database.child("files/" + storageDir).updateChildValues([key:entry]) { (error, ref) in
						let info:StorageFileMetadata = StorageFileMetadata(filename: filename, fullpath: filenameAndPath, directory: storageDir, contentType: uploadMetadata.contentType ?? "", type: fileType, size: data.count, url: meta.downloadURL(), description: description)
						completionHandler(info)
					}
				}
			}
		}
	}
}



extension UIImageView {
	
	public func imageFromStorage(_ filename: String){
		// filename:String is the filename in the Firebase Storage bucket, no directories
		// example: "0C5BABB0D5CA.jpg"
		if let image = Fire.shared.imageCache[filename]{
			self.image = image
			return
		}
		let storage = FIRStorage.storage().reference()
		let imageRef = storage.child("images/" + filename)
		imageRef.data(withMaxSize: IMG_SIZE_MAX * 1024 * 1024) { (data, error) in
			if let e = error{
				print(e.localizedDescription)
			} else{
				if let imageData = data {
					if let image = UIImage(data: imageData){
						Fire.shared.imageCache[filename] = image
						self.image = image
					}
				}
			}
		}
	}

	public func profileImageForUser(uid: String){
		Fire.shared.getUser(UID: uid) { (userData) in
			if let imageFilename = userData["image"] as? String{
				if let image = Fire.shared.imageCache[imageFilename]{
					self.image = image
					return
				}
				let storage = FIRStorage.storage().reference()
				let imageRef = storage.child("images/" + imageFilename)
				imageRef.data(withMaxSize: IMG_SIZE_MAX * 1024 * 1024) { (data, error) in
					if let e = error{
						print(e.localizedDescription)
					} else{
						if let imageData = data {
							if let image = UIImage(data: imageData){
								Fire.shared.imageCache[imageFilename] = image
								self.image = image
							}
						}
					}
				}
			}
		}
	}
	
	public func imageFromUrl(_ urlString: String) {
		if let url = URL(string: urlString) {
			let request:URLRequest = URLRequest(url: url)
			let session:URLSession = URLSession.shared
			let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
				DispatchQueue.main.async {
					if let imageData = data as Data? {
						self.image = UIImage(data: imageData)
					}
				}
			})
			task.resume()
		}
	}
	
}
