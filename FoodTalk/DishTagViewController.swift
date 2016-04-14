//
//  DishTagViewController.swift
//  FoodTalk
//
//  Created by Ashish on 22/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

var dishNameSelected = String()


class DishTagViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate {
    
    @IBOutlet var imageView : UIImageView?
    @IBOutlet var txtDishName : UITextField?
    var filtered : NSArray = []
    var searchActive : Bool = false
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setu
        self.title = "Dish Name"
        Flurry.logEvent("Dish Tag Screen")
        imageView?.image = imageSelected
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "addTapped")
        navigationItem.rightBarButtonItem?.enabled = false

        
        txtDishName!.autocorrectionType = UITextAutocorrectionType.No
        self.tabBarController?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        txtDishName?.becomeFirstResponder()
        self.view.frame.origin.y -= 120
    }
    
    func addTapped(){
        dishNameSelected = (txtDishName?.text)!
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("RatingVC") as! RatingViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
            self.navigationController?.navigationBarHidden = true
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKindOfClass(XMCCameraViewController) {
                    self.navigationController?.popToViewController(((self.navigationController?.viewControllers)! as NSArray).objectAtIndex(1) as! UIViewController, animated: true)
                    break
                }
            }
        }
    }
    
    //MARK:- uitextfield delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField.text == ""){
            textField.text = ""
        }
        searchActive = false
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        searchActive = true;
        tableView = UITableView()
        tableView.frame = CGRectMake(0, 165, self.view.frame.size.width, 220)
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        
      //  textField.text = ""
    }

    func textFieldDidEndEditing(textField: UITextField) {
        searchActive = false
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        tableView.hidden = false
        
        if(NSString(string: textField.text!).length > 3){
            navigationItem.rightBarButtonItem?.enabled = true
        }
        else{
            navigationItem.rightBarButtonItem?.enabled = false
        }
        if(NSString(string: textField.text!).length < 2){
            navigationItem.rightBarButtonItem?.enabled = false
        }
        else{
            navigationItem.rightBarButtonItem?.enabled = true
        }
        
        let aSet = NSCharacterSet(charactersInString:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_. ").invertedSet
        let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
        let numberFiltered = compSepByCharInSet.joinWithSeparator("")
        
        
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[cd] %@", textField.text!.stringByAppendingString(numberFiltered))
            let array = (arrDishNameList).filteredArrayUsingPredicate(searchPredicate)
            
            filtered = []
            filtered = array
            
            if(filtered.count == 0){
                searchActive = false;
            } else {
                searchActive = true;
            }
            self.tableView.reloadData()
            
        textField.text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: numberFiltered.lowercaseString)
        
        
        
        return false
    }

    //MARK:- tableViewDatasourceDelegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        
        if(searchActive){
          cell.textLabel?.text = filtered.objectAtIndex(indexPath.row) as? String
        }
        else{
           if(searchActive){
            
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        dishNameSelected = filtered.objectAtIndex(indexPath.row) as! String
        txtDishName?.text = (filtered.objectAtIndex(indexPath.row) as! String).stringByReplacingCharactersInRange(dishNameSelected.rangeOfString(dishNameSelected)!, withString: dishNameSelected.lowercaseString)
        navigationItem.rightBarButtonItem?.enabled = true
    //    tableView.removeFromSuperview()
        tableView.hidden = true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
