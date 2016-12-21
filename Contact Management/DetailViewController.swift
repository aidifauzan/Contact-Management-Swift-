//
//  DetailViewController.swift
//  Contact Management
//
//  Created by Aidi Fauzan on 2/12/16.
//  Copyright © 2016 Aidi Fauzan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var fname = ""
    var lname = ""
    var phone = ""
    var email = ""
    let phonebutton = UIButton()
    let emailbutton = UIButton()
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            
            if let label = self.detailDescriptionLabel {
                
                
                // GET JSON
                let urlPath: String = detail.description
                let url: NSURL = NSURL(string: urlPath)!
                let request1: NSURLRequest = NSURLRequest(URL: url)
                let queue:NSOperationQueue = NSOperationQueue()
                NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                    do {
                        if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as? NSDictionary {
                            
                            self.fname = (jsonResult["first_name"] as? String)!
                            self.lname = (jsonResult["last_name"] as? String)!
                            self.phone = (jsonResult["phone_number"] as? String)!
                            self.email = (jsonResult["email"] as? String)!
                            label.text = self.fname + " " + self.lname
                            
                            self.emailbutton.setTitle(self.email, forState: .Normal)
                            self.emailbutton.setTitleColor(UIColor.blueColor(), forState: .Normal)
                            self.emailbutton.frame = CGRectMake(60 , 430, 300, 25)
                            self.emailbutton.addTarget(self, action: #selector(DetailViewController.pressedEmail(_:)), forControlEvents: .TouchUpInside)
                            self.view.addSubview(self.emailbutton)
                            
                            self.phonebutton.setTitle(self.phone, forState: .Normal)
                            self.phonebutton.setTitleColor(UIColor.blueColor(), forState: .Normal)
                            self.phonebutton.frame = CGRectMake(60 , 400, 300, 25)
                            self.phonebutton.addTarget(self, action: #selector(DetailViewController.pressedPhone(_:)), forControlEvents: .TouchUpInside)
                            self.view.addSubview(self.phonebutton)
                            
                            var imageView : UIImageView
                            imageView  = UIImageView(frame:CGRectMake(120, 120, 120, 120))
                            imageView.center = CGPointMake(self.view.center.x, 260)
                            imageView.image = UIImage(named:"avatar")
                            self.view.addSubview(imageView)
                            
                        }else{
                            print("Json object format incompatible")
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
            
        }
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.configureView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pressedPhone(sender: UIButton!) {
        //callNumber(self.phone)
        if let url = NSURL(string: "tel://\(self.phone)") where UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
        var alertView = UIAlertView();
        alertView.addButtonWithTitle("Ok");
        alertView.title = "Warning";
        alertView.message = "Some emulator does not have Phone app, please try it on real device.";
        alertView.show();
    }

    func pressedEmail(sender: UIButton!) {
        let mailURL = NSURL(string: "message://")!
        if UIApplication.sharedApplication().canOpenURL(mailURL) {
            UIApplication.sharedApplication().openURL(mailURL)
        }
        var alertView = UIAlertView();
        alertView.addButtonWithTitle("Ok");
        alertView.title = "Warning";
        alertView.message = "Some emulator does not have Mail app, please try it on real device.";
        alertView.show();
    }
}

