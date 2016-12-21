//
//  MasterViewController.swift
//  Contact Management
//
//  Created by Aidi Fauzan on 2/12/16.
//  Copyright © 2016 Aidi Fauzan. All rights reserved.
//

//
// IMPORTANT NOTES!!
//
// There are many bugs on Xcode emulator, you may encounter lag or freeze on loading,
// so please test it on real device to achieve maximum performance.
//
// Thank you :)
//
// - Aidi
//

import UIKit
import Foundation

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()
    var fullnameArray = [String]()
    var reversedArray = [String]()
    var addcont = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        retrieveContacts()
    }
    
    func retrieveContacts(){
        // GET JSON
        
        let urlPath: String = "http://gojek-contacts-app.herokuapp.com/contacts.json"
        let url: NSURL = NSURL(string: urlPath)!
        let request1: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options:[]) as?
                    Array<AnyObject>  {
                    
                    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .Alert)
                    
                    alert.view.tintColor = UIColor.blackColor()
                    let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
                    loadingIndicator.hidesWhenStopped = true
                    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                    loadingIndicator.startAnimating();
                    
                    alert.view.addSubview(loadingIndicator)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    for anItem in jsonResult as! [Dictionary<String, AnyObject>] {
                        let fname = anItem["first_name"] as! String
                        let lname = anItem["last_name"] as! String
                        let urlitem = anItem["url"] as! String
                        var joined = fname + " " + lname + ";" + urlitem
                        let firstChar = joined[joined.startIndex]
                        if firstChar == "\n"{
                            joined = String(joined.characters.dropFirst())
                        }
                        
                        self.fullnameArray.append(joined)
                    }
                    
                    // insert to table view
                    
                    self.fullnameArray = self.fullnameArray.sort { $0.lowercaseString > $1.lowercaseString }
                    self.reversedArray = self.fullnameArray.reverse()
                    
                    for var y in 0..<(self.fullnameArray.count) {
                        var name = self.fullnameArray[y].characters.split{$0 == ";"}.map(String.init)
                        self.objects.insert(name[0], atIndex: 0)
                        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    }
                    
                    self.dismissViewControllerAnimated(false, completion: nil)
                    
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

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        if(addcont){
            fullnameArray.removeAll()
            reversedArray.removeAll()
            tableView.reloadData()
            retrieveContacts()
            addcont = false
        }
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        addcont = true
        self.performSegueWithIdentifier("addContact", sender: self)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let url = self.reversedArray[indexPath.row].characters.split{$0 == ";"}.map(String.init)
                let object = url[1]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

