//
//  LocalCache.swift
//  Login
//
//  Created by Robby on 8/8/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit
import Firebase

class LocalCache {
	static let shared = LocalCache()
	private init() { }
	
	var profileImage : Dictionary<String, UIImage> = Dictionary()
}

extension UIImageView {
	
	public func profileImageFromUID(uid: String){
		if(LocalCache.shared.profileImage[uid] != nil){
			print("shortcut, we already have an image")
			self.image = LocalCache.shared.profileImage[uid]!
			return
		}
		let userRef = FIRDatabase.database().reference().child("users").child(uid)
		userRef.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
			if snapshot.value is NSNull {
				print("trying to get user picture, but user doesn't even exist")
			} else {
				let userData:NSDictionary? = snapshot.value as! NSDictionary?
				let urlString :String? = userData!["image"] as? String
				if(urlString == nil){
					print("user exists, but has no image")
					return
				}
				if let url = NSURL(string: urlString!){
//					print("downloaded request \(url)")
					let request = NSMutableURLRequest(URL: url)
					let session = NSURLSession.sharedSession()
					let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
						dispatch_async(dispatch_get_main_queue()) {
							if let imageData = data as NSData? {
//								print("downloaded success")
								LocalCache.shared.profileImage[uid] = UIImage(data: imageData)
								self.image = UIImage(data: imageData)
							}
						}
					})
					task.resume()
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