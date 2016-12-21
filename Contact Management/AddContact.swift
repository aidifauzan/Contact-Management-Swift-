//
//  AddContact.swift
//  Contact Management
//
//  Created by Aidi Fauzan on 4/12/16.
//  Copyright © 2016 Aidi Fauzan. All rights reserved.
//

import Foundation
import UIKit

class AddContact : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var Imageview: UIImageView!
    
    @IBOutlet weak var Fname: UITextField!
    
    @IBOutlet weak var Lname: UITextField!
    
    @IBOutlet weak var Phone: UITextField!
    
    @IBOutlet weak var Email: UITextField!
    
    @IBOutlet weak var Submitbtn: UIButton!
    
    var lastid = 0
    let profpic = "/images/missing.png"
    let fav = false
    let date = NSDate()
    var imagePicker = UIImagePickerController()

    
    override func viewDidLoad() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddContact.imagePick(_:)))
        Imageview.addGestureRecognizer(tap)
        Imageview.userInteractionEnabled = true
        
        Submitbtn.addTarget(self, action: #selector(AddContact.pressed(_:)), forControlEvents: .TouchUpInside)
        
        let urlPath: String = "http://gojek-contacts-app.herokuapp.com/contacts.json"
        let url: NSURL = NSURL(string: urlPath)!
        let request1: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as?
                    Array<AnyObject>  {
                    
                    for anItem in jsonResult as! [Dictionary<String, AnyObject>] {
                        if(self.lastid < anItem["id"] as! Int){
                            self.lastid = anItem["id"] as! Int
                        }
                    }
                }else{
                    print("Json array incompatible")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                var alertView = UIAlertView();
                alertView.addButtonWithTitle("Ok");
                alertView.title = "Error";
                alertView.message = error.localizedDescription;
                alertView.show();
            }
            
        })
        
    }
    
    func pressed(sender: UIButton!) {
        
        var alertView = UIAlertView();
        alertView.addButtonWithTitle("Ok");
        alertView.title = "Warning";
        
        if(Fname.text != "" && Lname.text != ""){
            if(Phone.text != "" && Email.text != ""){

                if(Fname.text!.characters.count > 2){
                    
                    if (Phone.text!.isPhoneNumber && Phone.text!.characters.count > 9){
                        
                        if Email.text!.isEmail{
                            
                            lastid += 1
                            
                            let json = [ "id": String(lastid), "first_name": Fname.text!, "last_name": Lname.text!, "email": Email.text!, "phone_number": Phone.text!, "profile_pic": profpic, "favorite": String(fav), "created_at": String(date), "updated_at": String(date) ] as Dictionary<String, AnyObject>
                            
                            do {
                                
                                let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .Alert)
                                
                                alert.view.tintColor = UIColor.blackColor()
                                let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
                                loadingIndicator.hidesWhenStopped = true
                                loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                                loadingIndicator.startAnimating();
                                
                                alert.view.addSubview(loadingIndicator)
                                self.presentViewController(alert, animated: true, completion: nil)
                                
                                let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
                                
                                // create post request
                                let url = NSURL(string: "http://gojek-contacts-app.herokuapp.com/contacts.json")!
                                let request = NSMutableURLRequest(URL: url)
                                request.HTTPMethod = "POST"
                                
                                // insert json data to the request
                                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                                request.HTTPBody = jsonData
                                
                                let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                                    if error != nil{
                                        print("Error -> \(error)")
                                        alertView.message = error?.localizedDescription;
                                        alertView.show();
                                        return
                                    }
                                    
                                    do {
                                        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                                        
                                        print("Result -> \(result)")
                                        if String(result).rangeOfString("Phone") != nil{
                                            alertView.message = "Mobile phone number is invalid";
                                            alertView.show();
                                            self.lastid -= 1
                                        }
                                        else{
                                            alertView.message = "User successfully added!";
                                            alertView.show();
                                        }
                                        
                                    } catch {
                                        print("Error -> \(error)")
                                        alertView.message = "Error -> \(error)"
                                        alertView.show();
                                        self.lastid -= 1
                                    }
                                }
                                
                                task.resume()
                                
                            } catch {
                                print(error)
                                self.lastid -= 1
                            }
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }
                        else{
                            alertView.message = "Invalid email address";
                            alertView.show();
                        }
                    }
                    else{
                        alertView.message = "Mobile phone number is not valid";
                        alertView.show();
                    }
                }
                else{
                    alertView.message = "First Name is not valid";
                    alertView.show();
                }
            }
            else{
                alertView.message = "Input cannot be empty";
                alertView.show();
            }
        }
        else{
            alertView.message = "Input cannot be empty";
            alertView.show();
        }
    }
    
    func imagePick(img: AnyObject)
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
           
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
        Imageview.image = image
        
    }
    
}

extension String {

    //Validate Email
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    //validate PhoneNumber
    var isPhoneNumber: Bool {
        
        let charcter  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
        var filtered:NSString!
        let inputString:NSArray = self.componentsSeparatedByCharactersInSet(charcter)
        filtered = inputString.componentsJoinedByString("")
        return  self == filtered
        
    }
}