//
//  MasterTableViewController.swift
//  Notes
//
//  Created by TranMinh Tuan on 5/16/15.
//  Copyright (c) 2015 Tran Minh Tuan. All rights reserved.
//

import UIKit

class MasterTableViewController: UITableViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var noteObjects: NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (PFUser.currentUser() == nil) {
            
            var logInViewController = PFLogInViewController()
            logInViewController.delegate = self
            
            var signUpViewController = PFSignUpViewController()
            signUpViewController.delegate = self
            
            logInViewController.signUpController = signUpViewController
            
            self.presentViewController(logInViewController, animated: true, completion: nil)
        } else {
            self.fetchAllObjectsFromLocalDatastore()
            self.fetchAllObjects()
        }
    }
    
    func fetchAllObjectsFromLocalDatastore() {
    
        if let user = PFUser.currentUser() {
            var query: PFQuery = PFQuery(className: "Note")
            query.fromLocalDatastore()
            query.whereKey("username", equalTo: user.username!)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if (error == nil) {
                    println("Success fetch data from local datastore. Count: \(objects?.count)")
                    var temp: NSArray = objects as! NSArray
                    self.noteObjects = temp.mutableCopy() as! NSMutableArray
                    self.tableView.reloadData()
                } else {
                    println(error!.userInfo)
                }
            }
        }
    }
    
    func fetchAllObjects() {
        
        PFObject.unpinAllObjectsInBackgroundWithBlock(nil)
        var query: PFQuery = PFQuery(className: "Note")
        if let user = PFUser.currentUser() {
            query.whereKey("username", equalTo: user.username!)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if (error == nil) {
                    println("Success fetch data from server. Count: \(objects?.count)")
                    PFObject.pinAllInBackground(objects, block: { (success, error) -> Void in
                        if (error == nil) {
                            println("Success pin all data to local datastore. Success: \(success)")
                            self.fetchAllObjectsFromLocalDatastore()
                        } else {
                            println("Pin Query Result", msg: "\(query.parseClassName) failed")
                        }
                    })
                } else {
                    println(error!.userInfo)
                }
            }
            
        }


    }
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        
        if (!username.isEmpty || !password.isEmpty) {
            return true
        } else {
            return false
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        println("Failed to log in...")
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
        
        if let password = info["password"] as? String {
            return count(password.utf16) >= 8
        } else {
            return false
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        println("Failed to sign up...")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        println("User dismissed sign up.")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.noteObjects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MasterTableViewCell

        var object: PFObject = (self.noteObjects.objectAtIndex(indexPath.row) as? PFObject)!
        cell.masterTitleLabel?.text = object["title"] as? String
        cell.masterTextLabel?.text = object["text"] as? String

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("editNote", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var upcoming: AddNoteTableViewController = segue.destinationViewController as! AddNoteTableViewController
        if (segue.identifier == "editNote") {
            let indexPath = self.tableView.indexPathForSelectedRow()!
            var object: PFObject = (self.noteObjects.objectAtIndex(indexPath.row) as? PFObject)!
            upcoming.object = object
            upcoming.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
