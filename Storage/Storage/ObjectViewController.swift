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
				self.dataType = getDataType(object: data!)
				if(self.dataType != nil){
					self.title = stringForDataType(dataType: self.dataType!)
				}
				if(self.dataType != nil && self.dataType! == .isURL && urlIsImage(url: URL(string: data! as! String)!)){
					DispatchQueue.global(qos: .default).async {
						do{
							let imageURL:URL = URL(string: self.data! as! String)!
							let data = try Data(contentsOf: imageURL)
							DispatchQueue.main.async {
								self.imageView.image = UIImage(data: data)
							}
						}
						catch{
							
						}
					}
				} else{
					textView.text = String(describing: data!)
				}
			}
		}
	}
	
	let textView:UITextView = UITextView()
	let imageView:UIImageView = UIImageView()

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.view.backgroundColor = UIColor.white

		textView.frame = view.frame
		textView.font = UIFont.systemFont(ofSize: 18)
		textView.backgroundColor = UIColor.clear
		self.view.addSubview(textView)

		imageView.frame = view.frame
		imageView.contentMode = .scaleAspectFit
		imageView.backgroundColor = UIColor.clear
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
			if let url: URL = URL(string: object as! String) {
				if UIApplication.shared.canOpenURL(url){
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
	
	func urlIsImage(url:URL) -> Bool{
		let ext:String? = url.pathExtension
		if (ext != nil && imageExtensions.contains(ext!)) {
			return true
		}
		return false
	}
	
}
