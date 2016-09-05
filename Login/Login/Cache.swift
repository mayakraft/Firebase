//  Cache.swift
//  Created by Robby on 8/8/16.
//  Copyright © 2016 Robby. All rights reserved.


// a couple things are going on here:
// firebase storage doesn't let you ask for the contents of its folder
// this class helps out:
//
// 1) everytime you save an image, it creates an entry for it in your database
//    now you are manually maintaining a list of the contents of your firebase storage
//      (unless you upload by some other means)
//
//

import UIKit
import Firebase

// restriction on image file size
let IMG_SIZE_MAX:Int64 = 15  // megabytes

class Cache {
	static let shared = Cache()
	private init() { }
	
	// Key is userUID
	var profileImage : Dictionary<String, UIImage> = Dictionary()
	
	// Key is filename in the images/ folder in the bucket
	var storageBucket : Dictionary<String, UIImage> = Dictionary()
	
	func imageFromStorageBucket(filename: String, completionHandler: (image:UIImage?, didRequireDownload:Bool) -> ()) {
		if(storageBucket[filename] != nil){
			//TODO: if image on database has changed, we need a force-refresh command
			completionHandler(image: Cache.shared.storageBucket[filename]!, didRequireDownload: false)
			return
		}
		
		let storage = FIRStorage.storage().reference()
		let imageRef = storage.child("images/" + filename)
		
		imageRef.dataWithMaxSize(IMG_SIZE_MAX * 1024 * 1024) { (data, error) in
			if(data != nil){
				if let imageData = data as NSData? {
					Cache.shared.storageBucket[filename] = UIImage(data: imageData)
					completionHandler(image: Cache.shared.storageBucket[filename]!, didRequireDownload: true)
				}
			}
		}
	}
}



extension UIImageView {
	
	// UID can be found under your firebase database /files/images/
	public func imageFromFirebaseStorage(uid: String){
		Fire.shared.loadData("/files/images/\(uid)") { (data) in
			if let imgMetaData = data as! [String:AnyObject]?{
				if let urlString = imgMetaData["url"]{
					if let url = NSURL(string: urlString as! String){
						let request = NSMutableURLRequest(URL: url)
						let session = NSURLSession.sharedSession()
						let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
							dispatch_async(dispatch_get_main_queue()) {
								if let imageData = data as NSData? {
									Cache.shared.profileImage[uid] = UIImage(data: imageData)
									self.image = UIImage(data: imageData)
								}
							}
						})
						task.resume()
					}
				}
			}
		}
	}
	
	public func profileImageFromUserUID(uid: String){
		if(Cache.shared.profileImage[uid] != nil){
			self.image = Cache.shared.profileImage[uid]!
			return
		}
		Fire.shared.getUser { (userUID, userData) in
			if(userData != nil){
				if let urlString = userData!["image"]{
					if let url = NSURL(string: urlString as! String){
						let request = NSMutableURLRequest(URL: url)
						let session = NSURLSession.sharedSession()
						let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
							dispatch_async(dispatch_get_main_queue()) {
								if let imageData = data as NSData? {
									Cache.shared.profileImage[uid] = UIImage(data: imageData)
									self.image = UIImage(data: imageData)
								}
							}
						})
						task.resume()
					}
				}
				else{
//					print("user exists, but has no image")
					return
				}
			}
		}
	}

	public func imageFromUrl(urlString: String) {
		if let url = NSURL(string: urlString) {
			let request = NSMutableURLRequest(URL: url)
			let session = NSURLSession.sharedSession()
			let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
				dispatch_async(dispatch_get_main_queue()) {
					if let imageData = data as NSData? {
						self.image = UIImage(data: imageData)
					}
				}
			})
			task.resume()
		}
	}
	
	public func imageFromStorageBucket(filename: String){
		if(Cache.shared.storageBucket[filename] != nil){
			print("shortcut, we already have an image")
			self.image = Cache.shared.storageBucket[filename]!
			return
		}

		let storage = FIRStorage.storage().reference()
		let imageRef = storage.child("images/" + filename)

		imageRef.dataWithMaxSize(IMG_SIZE_MAX * 1024 * 1024) { (data, error) in
			print("we have data!")
			if(data != nil){
				if let imageData = data as NSData? {
					print("setting an image")
					Cache.shared.storageBucket[filename] = UIImage(data: imageData)
					self.image = UIImage(data: imageData)
				}
			}
		}
	}

}