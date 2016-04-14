//
//  AddRestaurantViewController.swift
//  FoodTalk
//
//  Created by Ashish on 22/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

class AddRestaurantViewController: UIViewController, UITextFieldDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var txtRestaurantName : UITextField?
    @IBOutlet var txtAddress : UITextField?
    @IBOutlet var moving : UISwitch?
    @IBOutlet var lblImage : UILabel?
    @IBOutlet var lblDescription : UILabel?
    @IBOutlet var viewH : UIView?
    @IBOutlet var addressArea : UILabel?
    var params = NSMutableDictionary()
    var activeTextField = UITextField()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Add Restaurant"
        Flurry.logEvent("AddRestaurant Screen")
        lblImage?.layer.cornerRadius = 17
        lblImage?.layer.masksToBounds = true
        
        UITextField.appearance().tintColor = UIColor.blackColor()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "CheckIn", style: .Plain, target: self, action: "addTapped")
        self.navigationItem.rightBarButtonItem!.enabled = false;
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
    }
    
    @IBAction func isSwitchOnOrOff(sender : UISwitch){
        if(sender.on){
            params = NSMutableDictionary()
            params.setObject(dictLocations.valueForKey("latitude") as! NSNumber, forKey: "latitude")
            params.setObject(dictLocations.valueForKey("longitute") as! NSNumber, forKey: "longitude")
            
            self.navigationItem.rightBarButtonItem!.enabled = true;
            
            txtAddress?.text = ""
            txtAddress?.hidden = true
            addressArea?.hidden = true
            viewH?.frame = CGRectMake((viewH?.frame.origin.x)!, (viewH?.frame.origin.y)! - 70, (viewH?.frame.size.width)!, (viewH?.frame.size.height)!)
            lblDescription?.frame = CGRectMake((lblDescription?.frame.origin.x)!, (lblDescription?.frame.origin.y)! - 70, (lblDescription?.frame.size.width)!, (lblDescription?.frame.size.height)!)
        }
        else{
            self.navigationItem.rightBarButtonItem!.enabled = false;
                        
            txtAddress?.hidden = false
            addressArea?.hidden = false
            viewH?.frame = CGRectMake((viewH?.frame.origin.x)!, (viewH?.frame.origin.y)! +
                70, (viewH?.frame.size.width)!, (viewH?.frame.size.height)!)
            lblDescription?.frame = CGRectMake((lblDescription?.frame.origin.x)!, (lblDescription?.frame.origin.y)! +
                70, (lblDescription?.frame.size.width)!, (lblDescription?.frame.size.height)!)
        }
    }
    
    //MARK:- webServiceCall & Delegate
    
    func webServiceCall(){
        var restaurantName = txtRestaurantName?.text
        if (isConnectedToNetwork()){
            showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl, controllerRestaurant, addlikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            restaurantName = restaurantName!.stringByReplacingOccurrencesOfString("\"", withString: "")
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(restaurantName!, forKey: "restaurantName")
            if(txtAddress?.text?.characters.count > 0){
                params.setObject((txtAddress?.text)!, forKey: "address")
            }
            
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(view)
        }

    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("status") as! String == "OK"){
            restaurantId = dict.objectForKey("restaurantId") as! String
            selectedRestaurantName = (txtRestaurantName?.text)!
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("imagePicker") as! XMCCameraViewController;
            self.navigationController!.pushViewController(openPost, animated:true);
        }
        else if(dict.objectForKey("status")!.isEqual("error")){
            if(dict.objectForKey("errorCode")!.isEqual(6)){
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                self.dismissViewControllerAnimated(true, completion: nil)
                
                let nav = (self.navigationController?.viewControllers)! as NSArray
                if(!nav.objectAtIndex(0).isKindOfClass(LoginViewController)){
                    for viewController in nav {
                        // some process
                        if viewController.isKindOfClass(LoginViewController) {
                            self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                            break
                        }
                    }
                }
                let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            }
        }
        stopLoading(self.view)
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    func addTapped(){
        
        if(txtRestaurantName?.text?.characters.count > 1){
            self.webServiceCall()
        }
    }
    
    
    
    //MARK:- textfield delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.characters.count < 2){
            self.navigationItem.rightBarButtonItem!.enabled = false;
        }
        else{
            self.navigationItem.rightBarButtonItem!.enabled = true;
        }
        return true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if(activeTextField == txtAddress){
          self.view.frame.origin.y -= 120
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if(activeTextField == txtAddress){
            
          self.view.frame.origin.y += 120
        }
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
