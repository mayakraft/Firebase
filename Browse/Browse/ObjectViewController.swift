//
//  StringViewController.swift
//  Browse
//
//  Created by Robby on 8/10/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

enum ObjectDataType {
	case isBool, isInt, isFloat, isString, isURL, isNULL
}
let imageExtensions = ["png", "jpg", "jpeg"]


class ObjectViewController: UIViewController {

	var dataType:ObjectDataType?
	
	var data:AnyObject?{
		didSet{
			if(data != nil){
				textView.text = String(data!)
				self.dataType = getDataType(data!)
				if(self.dataType != nil){
					self.title = stringForDataType(self.dataType!)
				}
			}
		}
	}
	
	let textView:UITextView = UITextView()

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		textView.frame = view.frame
		textView.font = UIFont.systemFontOfSize(18)
		self.view.addSubview(textView)
	}
	
	
	func stringForDataType(dataType:ObjectDataType) -> String{
		switch self.dataType! {
			case .isBool: return "Bool"
			case .isInt: return "Int"
			case .isFloat: return "Float"
			case .isURL: return "URL"
			case .isString: return "String"
			case .isNULL: return "NULL"
		}
	}
	
	func getDataType(object:AnyObject) -> ObjectDataType {
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
	
}
