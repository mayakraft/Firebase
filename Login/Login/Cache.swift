//
//  Cache.swift
//  Login
//
//  Created by Robby on 8/8/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

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
		
		imageRef.dataWithMaxSize(3 * 1024 * 1024) { (data, error) in
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
	
	public func profileImageFromUID(uid: String){
		if(Cache.shared.profileImage[uid] != nil){
			print("shortcut, we already have an image")
			self.image = Cache.shared.profileImage[uid]!
			return
		}
		Fire.shared.getUser { (userUID, userData) in
			if(userData != nil){
				if let urlString = userData!["image"]{
					if let url = NSURL(string: urlString as! String){
//						print("downloaded request \(url)")
						let request = NSMutableURLRequest(URL: url)
						let session = NSURLSession.sharedSession()
						let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
							dispatch_async(dispatch_get_main_queue()) {
								if let imageData = data as NSData? {
//									print("downloaded success")
									Cache.shared.profileImage[uid] = UIImage(data: imageData)
									self.image = UIImage(data: imageData)
								}
							}
						})
						task.resume()
					}
				}
				else{
					print("user exists, but has no image")
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

		imageRef.dataWithMaxSize(3 * 1024 * 1024) { (data, error) in
			print("we have data!")
			if(data != nil){
//				dispatch_async(dispatch_get_main_queue()) {
					if let imageData = data as NSData? {
						print("setting an image")
						Cache.shared.storageBucket[filename] = UIImage(data: imageData)
						self.image = UIImage(data: imageData)
					}
//				}
			}
		}
	}

}