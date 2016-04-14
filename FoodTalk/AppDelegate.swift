

//
//  AppDelegate.swift
//  FoodTalk
//
//  Created by Ashish on 02/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import CoreLocation

import Parse
import Bolts

var dictLocations = NSMutableDictionary()
var badgeNumber : Int = 0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UITabBarDelegate,UIAlertViewDelegate, WebServiceCallingDelegate, UITabBarControllerDelegate {

    var window: UIWindow?
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    var currentAppVarsion = String()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
//        if(newUpdates() == false){
//            if (isConnectedToNetwork()){
//                updateCall()
//            }
//        }
//        else{
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            self.addLocationManager()
            self.application(application, didReceiveRemoteNotification: remoteNotification as NSDictionary as [NSObject : AnyObject])
            
            FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
            NSUserDefaults.standardUserDefaults().setObject("98087765412342562728", forKey: "DeviceToken")
//            
            window?.frame = UIScreen.mainScreen().bounds
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            
            let barAppearace = UIBarButtonItem.appearance()
            barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics:UIBarMetrics.Default)
            
            let navigationItem = UINavigationItem()
            let myBackButton:UIButton = UIButton(type: UIButtonType.Custom) as UIButton
            myBackButton.frame = CGRectMake(20, 20, 30, 30)
            myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
            myBackButton.setImage(UIImage(named: "Back icon.png"), forState: UIControlState.Normal)
            myBackButton.setTitle("", forState: UIControlState.Normal)
            myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            myBackButton.sizeToFit()
            let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
            navigationItem.leftBarButtonItem  = myCustomBackButtonItem
            
            Parse.setApplicationId("RBOZIK8Vti138uqPIucaBherLAB16JFa3ITi4kDu",
                clientKey: "Kavc924t4PGsZzQdwUoLS6nz3q3Wm5PfRUjEDj9a")
            
            
            let notificationType: UIUserNotificationType = [.Alert, .Badge, .Sound]
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            let oldPushHandlerOnly = !self.respondsToSelector(Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"))
            let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
            
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        
        }
       else{
            
            self.addLocationManager()
            FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
            NSUserDefaults.standardUserDefaults().setObject("98087765412342562728", forKey: "DeviceToken")
            
            window?.frame = UIScreen.mainScreen().bounds
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            
//            
            let barAppearace = UIBarButtonItem.appearance()
            barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics:UIBarMetrics.Default)
            
            let navigationItem = UINavigationItem()
            let myBackButton:UIButton = UIButton(type: UIButtonType.Custom) as UIButton
            myBackButton.frame = CGRectMake(20, 20, 30, 30)
            myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
            myBackButton.setImage(UIImage(named: "Back icon.png"), forState: UIControlState.Normal)
            myBackButton.setTitle("", forState: UIControlState.Normal)
            myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            myBackButton.sizeToFit()
            let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
            navigationItem.leftBarButtonItem  = myCustomBackButtonItem
            
            if(NSUserDefaults.standardUserDefaults().objectForKey("sessionId") == nil){
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                var tbc : UIViewController
                tbc = storyBoard!.instantiateViewControllerWithIdentifier("LoginVC");
                
                nav.visibleViewController?.navigationController?.pushViewController(tbc, animated: false)
            }
            else if(NSUserDefaults.standardUserDefaults().objectForKey("userName") == nil){
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                var tbc : UIViewController
                tbc = storyBoard!.instantiateViewControllerWithIdentifier("Unnamed");
                
                nav.visibleViewController?.navigationController?.pushViewController(tbc, animated: false)
            }
            else{
            
            self.addLocationManager()
            

//            
            let barAppearace = UIBarButtonItem.appearance()
            barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics:UIBarMetrics.Default)
                
                let navigationItem = UINavigationItem()
                let myBackButton:UIButton = UIButton(type: UIButtonType.Custom) as UIButton
                myBackButton.frame = CGRectMake(20, 20, 30, 30)
                myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
                myBackButton.setImage(UIImage(named: "Back icon.png"), forState: UIControlState.Normal)
                myBackButton.setTitle("", forState: UIControlState.Normal)
                myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
                myBackButton.sizeToFit()
                let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
                navigationItem.leftBarButtonItem  = myCustomBackButtonItem
            
            Parse.setApplicationId("RBOZIK8Vti138uqPIucaBherLAB16JFa3ITi4kDu",
                clientKey: "Kavc924t4PGsZzQdwUoLS6nz3q3Wm5PfRUjEDj9a")
            
            
            let notificationType: UIUserNotificationType = [.Alert, .Badge, .Sound]
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            let oldPushHandlerOnly = !self.respondsToSelector(Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"))
            let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
            
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
            }
        }
        
        Flurry.setCrashReportingEnabled(true)
        Flurry.startSession("KNCBBSX6RCMBNV8FP2TQ")
        
        return true
    }
    
    //MARK:- checkForNewVersion
    
    func newUpdates() -> Bool{
        let infoDict = NSBundle.mainBundle().infoDictionary! as NSDictionary
        
        let appId = infoDict.objectForKey("CFBundleIdentifier") as! String
        let url = NSURL(string: String(format: "http://itunes.apple.com/lookup?bundleId=%@", appId))
        let data = NSData(contentsOfURL: url!)
        
        do {
            let lookUp = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSMutableDictionary
            if(lookUp?.objectForKey("resultCount")?.integerValue == 1){
                let appStoreVersion = lookUp?.objectForKey("results")?.objectAtIndex(0).objectForKey("version") as! String
                currentAppVarsion = infoDict.objectForKey("CFBundleShortVersionString") as! String
                if (appStoreVersion == currentAppVarsion){
                    return true;
                }
            }
            else{
                
            }
        } catch {
            
        }
        return false
    }
    
    func updateCall(){
        currentAppVarsion = "1.0"
        let url = String(format: "http://52.74.136.146/index.php/service/auth/appversion")
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let params = NSMutableDictionary()
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(currentAppVarsion, forKey: "app_version")
        webServiceCallingPost(url, parameters: params)
    }
    
    
    func popToRoot(sender : UIButton){
        let navigationController = UINavigationController()
        navigationController.popViewControllerAnimated(true)
    }
    
    func addLocationManager(){
        locationManager = CLLocationManager()
        locationManager!.delegate = self;
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    //MARK:- UserLocations Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] 
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
        
        dictLocations.setObject(long, forKey: "longitute")
        dictLocations.setObject(lat, forKey: "latitude")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    //MARK:- Push Notification Delegate Methods
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        
        badgeNumber = badgeNumber + 1
        NSNotificationCenter.defaultCenter().postNotificationName("addBadge", object: nil)
   
        let state = application.applicationState;
        if (state == UIApplicationState.Active) {
            dispatch_async(dispatch_get_main_queue()) {

                
            }
        }
        else{
        if application.applicationState == UIApplicationState.Inactive {
           // PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            PFPush.handlePush(userInfo)
            let currentInstallation = PFInstallation.currentInstallation()
            if (currentInstallation.badge != 0) {
                currentInstallation.badge = 0
                currentInstallation.saveEventually()
            }
            
            if application.applicationState == .Inactive  {
                PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            }
            
            
            let dict = (userInfo as NSDictionary)
            if(dict.objectForKey("eventType") as! String == "1" || dict.objectForKey("eventType") as! String == "2" || dict.objectForKey("eventType") as! String == "4"){
                
                self.performSelector("openOpenPostScreen:", withObject: dict, afterDelay: 3)
                
            }
                
            else if(dict.objectForKey("eventType") as! String == "5"){
               dispatch_async(dispatch_get_main_queue()) {
                self.performSelector("openUserProfile:", withObject: dict, afterDelay: 1)
                }
            }
            
            else if(dict.objectForKey("eventType") as! String == "6"){
                
                self.performSelector("openRestaurantProfile:", withObject: dict, afterDelay: 1)
            }
            
            else if(dict.objectForKey("eventType") as! String == "50"){
                
                let nav = self.window!.rootViewController as! UINavigationController;
                
                if((nav.visibleViewController?.isKindOfClass(Home)) != nil){
                    let viewControllers = nav.viewControllers
                    for viewController in viewControllers {
                        // some process
                        if viewController.isKindOfClass(Home) {
                            nav.visibleViewController?.navigationController?.popToViewController(viewController, animated: false)
                        }
                    }
                }
            }
            
            else if(dict.objectForKey("eventType") as! String == "51"){
                
               self.performSelector("openDiscoverProfile:", withObject: dict, afterDelay: 2)
                
            }
            
            else if(dict.objectForKey("eventType") as! String == "52"){
                self.performSelector("openUserProfile1:", withObject: dict, afterDelay: 1)
            }
        }
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
        
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        if(userId != nil){
        currentInstallation.setObject(userId!, forKey: "userId")
        }
        currentInstallation.setObject("development", forKey: "work")
        currentInstallation.addUniqueObject("FoodTalk", forKey: "channels")
        currentInstallation.saveInBackground()
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
    }
    
    //MARK:- ClosePushAction
    
    func closePush(pushBtn : UIButton){
        let superView = pushBtn.superview! as UIView
        UIView.animateWithDuration(0.5, delay: 1.0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
            
            superView.frame = CGRectMake(0, -64, pushBtn.frame.size.width, pushBtn.frame.size.height)
            
            }, completion: { (finished: Bool) -> Void in
                
        })
    }
    
    //MARK:- OpenAllPosts
    
    func openOpenPostScreen(dict : NSDictionary){
        let storyBoard = self.window!.rootViewController!.storyboard;
        let nav = self.window!.rootViewController as! UINavigationController;
        
        if((nav.visibleViewController?.isKindOfClass(OpenPostViewController)) != nil){
            
            let viewControllers = nav.viewControllers
            for viewController in viewControllers {
                // some process
                if viewController.isKindOfClass(OpenPostViewController) {
                    nav.visibleViewController?.navigationController?.popToViewController(viewController, animated: false)
                }
            }
        }
        
        stopLoading(self.window!)
        print(dict.objectForKey("elementId") as? String)
        postIdOpenPost = (dict.objectForKey("elementId") as? String)!
        let openPost = storyBoard!.instantiateViewControllerWithIdentifier("OpenPostVC") as! OpenPostViewController;
        nav.visibleViewController?.navigationController?.pushViewController(openPost, animated:true);
    }
    
    func openUserProfile(dict : NSDictionary){
        let storyBoard = self.window!.rootViewController!.storyboard;
        let nav = self.window!.rootViewController as! UINavigationController;
        
        if((nav.visibleViewController?.isKindOfClass(UserProfileViewController)) != nil){
            
            let viewControllers = nav.viewControllers
            for viewController in viewControllers {
                // some process
                if viewController.isKindOfClass(UserProfileViewController) {
                    nav.visibleViewController?.navigationController?.popToViewController(viewController, animated: false)
                }
            }
        }
        isUserInfo = false
        stopLoading(self.window!)
        openProfileId = (dict.objectForKey("elementId") as? String)!
        
        let openPost = storyBoard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
        nav.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func openUserProfile1(dict : NSDictionary){
        let storyBoard = self.window!.rootViewController!.storyboard;
        let nav = self.window!.rootViewController as! UINavigationController;
        
        if((nav.visibleViewController?.isKindOfClass(UserProfileViewController)) != nil){
            
            let viewControllers = nav.viewControllers
            for viewController in viewControllers {
                // some process
                if viewController.isKindOfClass(UserProfileViewController) {
                    nav.visibleViewController?.navigationController?.popToViewController(viewController, animated: false)
                }
            }
        }
        isUserInfo = false
        stopLoading(self.window!)
        openProfileId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        
        let openPost = storyBoard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
        nav.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func openRestaurantProfile(dict : NSDictionary){
        let storyBoard = self.window!.rootViewController!.storyboard;
        let nav = self.window!.rootViewController as! UINavigationController;
        if((nav.visibleViewController?.isKindOfClass(RestaurantProfileViewController)) != nil){
            
            let viewControllers = nav.viewControllers
            for viewController in viewControllers {
                // some process
                if viewController.isKindOfClass(RestaurantProfileViewController) {
                    nav.visibleViewController?.navigationController?.popToViewController(viewController, animated: false)
                }
            }
        }
        
        restaurantProfileId = (dict.objectForKey("elementId") as? String)!
        let openPost = storyBoard!.instantiateViewControllerWithIdentifier("restaurant") as! RestaurantProfileViewController;
        nav.visibleViewController?.navigationController?.pushViewController(openPost, animated:true);
    }
    
    func openDiscoverProfile(dict : NSDictionary){
        let storyBoard = self.window!.rootViewController!.storyboard;
        let nav = self.window!.rootViewController as! UINavigationController;
        if((nav.visibleViewController?.isKindOfClass(DiscoverViewController)) != nil){
            
            let viewControllers = nav.viewControllers
            for viewController in viewControllers {
                // some process
                if viewController.isKindOfClass(DiscoverViewController) {
                    nav.visibleViewController?.navigationController?.popToViewController(viewController, animated: false)
                }
            }
        }
        
       // restaurantProfileId = (dict.objectForKey("elementId") as? String)!
        let tab = storyBoard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
        tab.selectedIndex = 1
        nav.visibleViewController?.navigationController?.pushViewController(tab, animated:true);
    }
    
    //MARK:- DishWebService
    func webServiceForDishDetails(){
       if (isConnectedToNetwork()){
        let url = String(format: "%@%@%@", baseUrl, controllerDish, restaurantListMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let params = NSMutableDictionary()
        params.setObject(sessionId!, forKey: "sessionId")
        
        webServiceCallingPost(url, parameters: params)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        if(dict.objectForKey("api") as! String == "auth/appversion"){
          let minimumVersion = dict.objectForKey("app_version")?.objectForKey("allowed") as! Float
            let numberFormatter = NSNumberFormatter()
            let number = numberFormatter.numberFromString(currentAppVarsion)
            let numberFloatValue = number!.floatValue
            if((numberFloatValue) < minimumVersion){
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                
                let openPost = storyBoard!.instantiateViewControllerWithIdentifier("updateVersion") as! UpdateVersionViewController;
                nav.visibleViewController?.navigationController?.pushViewController(openPost, animated:true);
                openPost.updateLabel?.text = dict.objectForKey("app_version")?.objectForKey("text") as? String
            }
        }
        else{
        var dishnameArray = NSArray()
        let dishNames = NSMutableArray()
        if(dict.objectForKey("status") as! String == "OK"){
            dishnameArray = dict.objectForKey("result") as! NSArray
        }
        
        for(var index : Int = 0; index < dishnameArray.count; index++){
            dishNames.addObject(dishnameArray.objectAtIndex(index).objectForKey("name") as! String)
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let path = (paths as NSString).stringByAppendingPathComponent("DishName.plist")

        
        if let plistArray = NSMutableArray(contentsOfFile: path) {

            for(var indx : Int = 0; indx < dishNames.count; indx++){
               plistArray.addObject(dishNames.objectAtIndex(indx))
            }
            plistArray.writeToFile(path, atomically: false)
        }
        
        loadDataPlist()
        }
    }
    
    
    func loadDataPlist(){
        var myArray = NSMutableArray()
        let rootPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true)[0]
        // 2
        let plistPathInDocument = rootPath.stringByAppendingString("/DishName.plist")
        if !NSFileManager.defaultManager().fileExistsAtPath(plistPathInDocument){
            let plistPathInBundle = NSBundle.mainBundle().pathForResource("DishName", ofType: "plist") as String!
            // 3
            do {
                try NSFileManager.defaultManager().copyItemAtPath(plistPathInBundle, toPath: plistPathInDocument)
                myArray = NSMutableArray(contentsOfFile: plistPathInDocument)!
               
            }catch{
                print("Error occurred while copying file to document \(error)")
            }
        }
        
    }
    
    func serviceFailedWitherror(error : NSError){
        stopLoading(self.window!)
    }
    
    func serviceUploadProgress(myprogress : float_t){
        stopLoading(self.window!)
    }
    
    //MARK:- Parse delegates

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let nav = UINavigationController()
        nav.popToRootViewControllerAnimated(false)
    }
    

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        let currentInstallation = PFInstallation.currentInstallation()
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

