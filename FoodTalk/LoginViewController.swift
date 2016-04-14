//
//  LoginViewController.swift
//  FoodTalk
//
//  Created by Ashish on 02/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit

var loginAllDetails = NSMutableDictionary()
var webViewCallingLegal : Bool = false

class LoginViewController: UIViewController, WebServiceCallingDelegate {

    
    @IBOutlet var loginButton : UIButton?
    var fbId : String?
    var fbUserName : String?
    var dict : NSDictionary?
    var webCall : WebServiceCallingViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fbUserName = ""
        
        loginButton?.enabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBarHidden = true
        loginButton?.hidden = false
    }
    
    // Inisilize app and return delegate
    func appdelegate () -> AppDelegate{
        return  UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    //MARK:- FBLoginButton Delegate
    @IBAction func btnFBLoginPressed(sender: AnyObject){
      
        Flurry.logEvent("LoginPressed")
        loginButton?.enabled = false
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.Native
        fbLoginManager .logInWithReadPermissions(["email","user_friends","user_birthday"], fromViewController: self, handler: { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                    fbLoginManager.logOut()
                }
                else{
                    
                    self.loginButton?.enabled = true
                    let alert = UIAlertController(title: "", message: "Please allow facebook to share your email address with us.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    let deletepermission = FBSDKGraphRequest(graphPath: "me/permissions/email", parameters: nil, HTTPMethod: "DELETE")
                    deletepermission.startWithCompletionHandler({(connection,result,error)-> Void in
                        print("the delete permission is \(result)")
                        
                    })
                }
            }
        })
        
    }
    
    func getFBUserData(){
        
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email,gender"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    
                    self.dict = result as? NSDictionary
                    self.fbId = self.dict?.valueForKey("id") as? String
                    let gender = self.dict?.valueForKey("gender") as? String
                    NSUserDefaults.standardUserDefaults().setObject(self.fbId, forKey: "fbId")
                    self.fbUserName = self.dict?.valueForKey("name") as? String
                    let picUrl = String(format: "https://graph.facebook.com/%@/picture?type=large", self.fbId!)
                    
                //    let delegate = self.appdelegate()
               //     let locationDetailsDictionary = delegate.locationManager1()
                    let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken")
                    let email = self.dict?.valueForKey("email") as? String
                    
                    let params = NSMutableDictionary()
                    params.setObject("F", forKey: "signInType")
                    params.setObject(picUrl, forKey: "image")
                    params.setObject(self.fbId!, forKey: "facebookId")
                    params.setObject(self.fbUserName!, forKey: "fullName")
                    params.setObject(email!, forKey: "email")
                    params.setObject("28.6139", forKey: "latitude")
                    params.setObject("77.2090", forKey: "longitude")
                    params.setObject(deviceToken!, forKey: "deviceToken")
                    params.setObject(gender!, forKey: "gender")
                    
                    self.webServicecall(params)
                }
            })
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        
    }
    
    //MARK:- Calling WebServices
    
    func webServicecall (params : NSMutableDictionary){
        if (isConnectedToNetwork() == true){
        let url = String(format: "%@%@%@", baseUrl,controllerAuth,signinMethod)
        webServiceCallingPost(url, parameters: params)
        loginAllDetails = params
        NSUserDefaults.standardUserDefaults().setObject(loginAllDetails, forKey: "AllLogindetails")
        delegate = self
        }
        else{
            internetMsg(view)
        }
    }
    
    //MARK:- WebService Delegates
    
    func getDataFromWebService(dict : NSMutableDictionary){
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "LoginDetails")
        self.afterLogindetails(dict)
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
            
            let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.setObject(userId, forKey: "userId")
                currentInstallation.saveInBackground()

            if(infoDict.objectForKey("isNewUser")?.intValue != 0){
            let searchScreen = self.storyboard!.instantiateViewControllerWithIdentifier("Unnamed") as! UnnamedViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(searchScreen, animated:true);
            }
            else{
                let username = infoDict.objectForKey("userName")
                NSUserDefaults.standardUserDefaults().setObject(username, forKey: "userName")
                var tbc : UITabBarController
                tbc = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController;
                tbc.selectedIndex=0;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(tbc, animated:true);
                
            }
        }
        else{
            
        }
    }
    
    @IBAction func legalButtonTapped(sender : UIButton){
        webViewCallingLegal = true
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("webLink") as! WebLinkViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
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
