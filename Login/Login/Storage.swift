//  Storage.swift
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

class Storage {
	static let shared = Storage()
	fileprivate init() { }
	
	// Key is userUID
	var profileImage : Dictionary<String, UIImage> = Dictionary()
	
	// Key is filename in the images/ folder in the bucket
	var storageBucket : Dictionary<String, UIImage> = Dictionary()
	
	func imageFromStorageBucket(_ filename: String, completionHandler: @escaping (_ image:UIImage?, _ didRequireDownload:Bool) -> ()) {
		if(storageBucket[filename] != nil){
			//TODO: if image on database has changed, we need a force-refresh command
			completionHandler(Storage.shared.storageBucket[filename]!, false)
			return
		}
		
		let storage = FIRStorage.storage().reference()
		let imageRef = storage.child("images/" + filename)
		
		imageRef.data(withMaxSize: IMG_SIZE_MAX * 1024 * 1024) { (data, error) in
			if(data != nil){
				if let imageData = data as Data? {
					self.storageBucket[filename] = UIImage(data: imageData)
					completionHandler(self.storageBucket[filename]!, true)
				}
			}
		}
	}
}



extension UIImageView {
	
	// UID can be found under your firebase database /files/images/
	public func imageFromFirebaseStorage(_ uid: String){
		Fire.shared.loadData("/files/images/\(uid)") { (data) in
			if let imgMetaData = data as! [String:AnyObject]?{
				if let urlString = imgMetaData["url"]{
					if let url = URL(string: urlString as! String){
						let request:URLRequest = URLRequest(url: url)
						let session:URLSession = URLSession.shared
						let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
							DispatchQueue.main.async {
								if let imageData = data as Data? {
									Storage.shared.profileImage[uid] = UIImage(data: imageData)
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
	
	public func profileImageFromUserUID(_ uid: String){
		if(Cache.shared.profileImage[uid] != nil){
			self.image = Cache.shared.profileImage[uid]!
			return
		}
		Fire.shared.getUser { (userUID, userData) in
			if(userData != nil){
				if let urlString = userData!["image"]{
					if let url = URL(string: urlString as! String){
						let request:URLRequest = URLRequest(url: url)
						let session:URLSession = URLSession.shared
						let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
							DispatchQueue.main.async {
								if let imageData = data as Data? {
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
	
	public func imageFromStorageBucket(_ filename: String){
		if(Cache.shared.storageBucket[filename] != nil){
			print("shortcut, we already have an image")
			self.image = Cache.shared.storageBucket[filename]!
			return
		}

		let storage = FIRStorage.storage().reference()
		let imageRef = storage.child("images/" + filename)

		imageRef.data(withMaxSize: IMG_SIZE_MAX * 1024 * 1024) { (data, error) in
			print("we have data!")
			if(data != nil){
				if let imageData = data as Data? {
					print("setting an image")
					Cache.shared.storageBucket[filename] = UIImage(data: imageData)
					self.image = UIImage(data: imageData)
				}
			}
		}
	}

}
