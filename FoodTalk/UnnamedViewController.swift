//
//  UnnamedViewController.swift
//  FoodTalk
//
//  Created by Ashish on 23/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

class UnnamedViewController: UIViewController, UITextFieldDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var btnCheck : UIButton?
    @IBOutlet var txtName : UITextField?
    @IBOutlet var lblAlreadyTakenname : UILabel?
    
    var charactesAllowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btnCheck?.enabled = false
        lblAlreadyTakenname?.hidden = true
        Flurry.logEvent("Enter Username Screen")
        self.navigationController?.navigationBarHidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    @IBAction func moveToNew(sender : UIButton){
        var dictV = NSMutableDictionary()
        dictV = NSUserDefaults.standardUserDefaults().objectForKey("AllLogindetails")?.mutableCopy() as! NSMutableDictionary
        let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken")
        dispatch_async(dispatch_get_main_queue()) {
        dictV.setObject((self.txtName?.text)!, forKey: "userName")
        dictV.setObject(deviceToken!, forKey: "deviceToken")
        self.webServicecall(dictV)
        }
    }
    
    
    //MARK:- WebService Calling
    func webServicecall (params : NSMutableDictionary){
        if (isConnectedToNetwork()){
            let url = String(format: "%@%@%@", baseUrl,controllerAuth,signinMethod)
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    //MARK:- WebService Delegates
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("status") as! String == "OK"){
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "LoginDetails")
            self.afterLogindetails(dict)
        }
        else{
           txtName?.text = ""
           btnCheck?.enabled = false
           lblAlreadyTakenname?.hidden = false
        }
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:- Additional Action After Login
    
    func afterLogindetails(infoDict : NSDictionary){
        if(infoDict.objectForKey("status")!.isEqual("OK")){
            
            let sessionId = infoDict.objectForKey("sessionId") as! String
            let userId = infoDict.objectForKey("userId") as! String
            NSUserDefaults.standardUserDefaults().setObject(sessionId, forKey: "sessionId")
            NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "userId")
            NSUserDefaults.standardUserDefaults().setObject(txtName?.text, forKey: "userName")
            
            
            let currentInstallation = PFInstallation.currentInstallation()
            currentInstallation.setObject(userId, forKey: "userId")
            currentInstallation.saveInBackground()
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("appInvite") as! InviteViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else{
            
        }
    }

    
    //MARK:- TextField Delegates
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let aSet = NSCharacterSet(charactersInString:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.").invertedSet
        let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
        let numberFiltered = compSepByCharInSet.joinWithSeparator("")
        if((range.length + range.location > 3) || (range.length + range.location < 16)){
            btnCheck?.enabled = true
        }
        return string == numberFiltered
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        self.view.frame.origin.y -= 120
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 120
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
