//
//  LocalCache.swift
//  Login
//
//  Created by Robby on 8/8/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

class Storage {
	static let shared = Storage()
	private init() { }
	
	var profileImage : Dictionary<String, UIImage> = Dictionary()
	
	
}



extension UIImageView {
	
	public func profileImageFromUID(uid: String){
		if(Storage.shared.profileImage[uid] != nil){
			print("shortcut, we already have an image")
			self.image = Storage.shared.profileImage[uid]!
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
									//								print("downloaded success")
									Storage.shared.profileImage[uid] = UIImage(data: imageData)
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
}