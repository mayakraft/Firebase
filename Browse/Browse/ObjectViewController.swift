//
//  StringViewController.swift
//  Browse
//
//  Created by Robby on 8/10/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

enum JSONDataType {
	case isBool, isInt, isFloat, isString, isURL, isNULL
	// isURL technically is still a String. a special kind
}
let imageExtensions = ["png", "jpg", "jpeg"]


class ObjectViewController: UIViewController {

	var dataType:JSONDataType?
	
	var data:AnyObject?{
		didSet{
			if(data != nil){
				self.dataType = getDataType(data!)
				if(self.dataType != nil){
					self.title = stringForDataType(self.dataType!)
				}
				
				if(self.dataType != nil && self.dataType! == .isURL && urlIsImage(NSURL(string: data! as! String)!)){
					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
						let data = NSData(contentsOfURL: NSURL(string: self.data! as! String)!)
						dispatch_async(dispatch_get_main_queue(), {
							self.imageView.image = UIImage(data: data!)
						});
					}
				} else{
					textView.text = String(data!)
				}
			}
		}
	}
	
	let textView:UITextView = UITextView()
	let imageView:UIImageView = UIImageView()

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		self.view.backgroundColor = UIColor.whiteColor()

		textView.frame = view.frame
		textView.font = UIFont.systemFontOfSize(18)
		textView.backgroundColor = UIColor.clearColor()
		self.view.addSubview(textView)

		imageView.frame = view.frame
		imageView.contentMode = .ScaleAspectFit
		imageView.backgroundColor = UIColor.clearColor()
		self.view.addSubview(imageView)
	}
	
	
	func stringForDataType(dataType:JSONDataType) -> String{
		switch self.dataType! {
			case .isBool: return "Bool"
			case .isInt: return "Int"
			case .isFloat: return "Float"
			case .isURL: return "URL"
			case .isString: return "String"
			case .isNULL: return "NULL"
		}
	}
	
	func getDataType(object:AnyObject) -> JSONDataType {
		// BOOL and INT type detection is not working
//		if(data! is Bool){
//			self.dataType = .isBool
//		} else if(data! is Int){
//			return .isInt
//		}
		if(object is Float){
			return .isFloat
		} else if(object is String){
			if let url: NSURL = NSURL(string: object as! String) {
				if UIApplication.sharedApplication().canOpenURL(url) {
					return .isURL
				} else{
					return .isString
				}
			} else{
				return .isString
			}
		}
		return .isNULL
	}
	
	func urlIsImage(url:NSURL) -> Bool{
		let ext:String? = url.pathExtension
		if (ext != nil && imageExtensions.contains(ext!)) {
			return true
		}
		return false
	}
	
}
