//
//  NotificationsViewController.swift
//  FoodTalk
//
//  Created by Ashish on 21/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate, UITabBarControllerDelegate {
    
    @IBOutlet var tableView : UITableView?
    var notificationArray : NSArray = []
    var nameString = NSMutableAttributedString()
    var refreshControl:UIRefreshControl!
    var noNotificationAlert = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayNotification:", name: "notificationReceive", object: nil)
        
        showLoader(self.view)
        dispatch_async(dispatch_get_main_queue()) {
        self.tabBarController?.tabBar.userInteractionEnabled = false
          self.webServiceCall()
        }
        // Do any additional setup after loading the view.
        
        noNotificationAlert.frame = CGRectMake(0, 150, self.view.frame.size.width, 50)
        noNotificationAlert.text = "No one cares :("
        noNotificationAlert.textColor = UIColor.whiteColor()
        noNotificationAlert.font = UIFont(name: fontBold, size: 15)
        noNotificationAlert.textAlignment = NSTextAlignment.Center
        self.view.addSubview(noNotificationAlert)
        noNotificationAlert.hidden = true
        
        tableView!.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 45/255, alpha: 1.0)
        tableView?.separatorColor = UIColor(red: 47/255, green: 51/255, blue: 60/255, alpha: 1.0)
        let tblView =  UIView(frame: CGRectZero)
        tableView!.tableFooterView = tblView
        tableView!.tableFooterView!.hidden = true
        
        self.refreshControl = UIRefreshControl()
        let attr = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:attr)
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView!.addSubview(refreshControl)

        self.tabBarController?.delegate = self
        
        self.title = "Notifications"
        Flurry.logEvent("Notification Screen")
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    override func viewWillAppear(animated: Bool) {
        selectedTabBarIndex = 3
        self.tabBarController?.delegate = self
        self.navigationController?.navigationBarHidden = false
        let tabArray = self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(3) as! UITabBarItem
        self.tabBarController?.tabBar.userInteractionEnabled = true
        
        tabItem.badgeValue  = nil
        badgeNumber = 0
        if(notificationArray.count < 1){
            dispatch_async(dispatch_get_main_queue()) {
                self.tabBarController?.tabBar.userInteractionEnabled = false
                self.webServiceCall()
            }
        }
    }
    
    //MARK:- RefreshControl Method
    func refresh(sender:AnyObject)
    {
        notificationArray = NSArray()
        self.tabBarController?.tabBar.userInteractionEnabled = false
        dispatch_async(dispatch_get_main_queue()) {
        self.webServiceCall()
        }
    }
    
    //MARK:- TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        self.addViewsOnCell(cell, index: indexPath.row)
        cell.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 45/255, alpha: 1.0)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(notificationArray.count > 0){
        if((notificationArray.objectAtIndex(indexPath.row).objectForKey("eventType")!.intValue == 2) || (notificationArray.objectAtIndex(indexPath.row).objectForKey("eventType")!.intValue == 4) || (notificationArray.objectAtIndex(indexPath.row).objectForKey("eventType")!.intValue == 9)){
            
            let nav = (self.navigationController?.viewControllers)! as NSArray
            if(!nav.objectAtIndex(0).isKindOfClass(OpenPostViewController)){
                for viewController in nav {
                    // some process
                    if viewController.isKindOfClass(OpenPostViewController) {
                        postIdOpenPost = notificationArray.objectAtIndex(indexPath.row).objectForKey("elementId") as! String
                        self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                        break
                    }
                }
            }
            postIdOpenPost = notificationArray.objectAtIndex(indexPath.row).objectForKey("elementId") as! String
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("OpenPostVC") as! OpenPostViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
        else if(notificationArray.objectAtIndex(indexPath.row).objectForKey("eventType")!.intValue == 5){
            
            let nav = (self.navigationController?.viewControllers)! as NSArray
            if(!nav.objectAtIndex(0).isKindOfClass(UserProfileViewController)){
                for viewController in nav {
                    // some process
                    if viewController.isKindOfClass(UserProfileViewController) {
                        openProfileId = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserId") as! String
                        postImagethumb = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserThumb") as! String
                        postImageOrgnol = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserImage") as! String
                        self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                        break
                    }
                }
            }
            isUserInfo = false
            openProfileId = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserId") as! String
            postImagethumb = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserThumb") as! String
            postImageOrgnol = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserImage") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
        else if(notificationArray.objectAtIndex(indexPath.row).objectForKey("eventType")!.intValue == 6){
            
        }
        else if(notificationArray.objectAtIndex(indexPath.row).objectForKey("eventType")!.intValue == 50){
            
            var tbc : UITabBarController
            tbc = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController;
            tbc.selectedIndex=0;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(tbc, animated:true);
            
        }
        else if(notificationArray.objectAtIndex(indexPath.row).objectForKey("eventType")!.intValue == 51){
            
            var tbc : UITabBarController
            tbc = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController;
            tbc.selectedIndex=1;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(tbc, animated:true);
            
        }
            else if(notificationArray.objectAtIndex(indexPath.row).objectForKey("eventType")!.intValue == 51){
            let nav = (self.navigationController?.viewControllers)! as NSArray
            if(!nav.objectAtIndex(0).isKindOfClass(UserProfileViewController)){
                for viewController in nav {
                    // some process
                    if viewController.isKindOfClass(UserProfileViewController) {
                        openProfileId = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserId") as! String
                        postImagethumb = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserThumb") as! String
                        postImageOrgnol = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserImage") as! String
                        self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                        break
                    }
                }
            }
            isUserInfo = true
            openProfileId = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserId") as! String
            postImagethumb = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserThumb") as! String
            postImageOrgnol = notificationArray.objectAtIndex(indexPath.row).objectForKey("raiserImage") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            }
        }
    }
    
    
    func addViewsOnCell(cell : UITableViewCell, index : Int){
        let profileImage = UIImageView()
        profileImage.frame = CGRectMake(18, 9, 40, 40)
        profileImage.layer.cornerRadius = 20
        profileImage.layer.masksToBounds = true
        profileImage.tag = 33
        cell.contentView.addSubview(profileImage)
        
//        profileImage.image = nil
        profileImage.image = UIImage(named: "username.png")
//        profileImage.image = nil
        
        
        let statuslabel = UILabel()
        statuslabel.frame = CGRectMake(69, 0, UIScreen.mainScreen().bounds.size.width - 116, 55)
        statuslabel.textColor = UIColor.whiteColor()
        statuslabel.tag = 22
        statuslabel.numberOfLines = 0
        statuslabel.backgroundColor = UIColor.clearColor()
        
        if(notificationArray.count > 0){
        let notoficationdate = notificationArray.objectAtIndex(index).objectForKey("eventDate") as! String
        let diffTime = differenceDate(notoficationdate)
        let diffTimeLength = diffTime.characters.count
        
        
        let length = (notificationArray.objectAtIndex(index).objectForKey("raiserName") as! String).characters.count
        
        let wholeText = String(format: "%@ %@", notificationArray.objectAtIndex(index).objectForKey("message") as! String,diffTime)
        
        nameString = NSMutableAttributedString(string: wholeText, attributes: [NSFontAttributeName:UIFont(name: "Helvetica-Bold", size: 13.0)!])
        nameString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 28/255, green: 99/255, blue: 199/255, alpha: 1.0), range: NSRange(location:0,length:length))
        if(diffTimeLength < 3){
            nameString.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSRange(location:wholeText.characters.count - 2,length:2))
            statuslabel.attributedText = nameString
        }
        else{
        nameString.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSRange(location:wholeText.characters.count - 3,length:diffTimeLength))
        statuslabel.attributedText = nameString
        }
        }
        let iconView = UIView()
        iconView.frame = CGRectMake(self.view.frame.size.width - 48, 9, 40, 40)
        iconView.layer.cornerRadius = iconView.frame.size.width/2
        iconView.clipsToBounds = true
        iconView.tag = 29
        iconView.layer.masksToBounds = true
        
        let iconImage = UIImageView()
        iconImage.frame = CGRectMake(5, 5, 30, 30)
        iconImage.layer.cornerRadius = iconImage.frame.size.width/2
        iconImage.clipsToBounds = true
        iconImage.tag = 28
        iconImage.layer.masksToBounds = true
        iconView.addSubview(iconImage)
        
//        loadImageAndCache(profileImage,url: notificationArray.objectAtIndex(index).objectForKey("raiserThumb") as! String)
        if(notificationArray.count > 0){
        dispatch_async(dispatch_get_main_queue()) {
        profileImage.hnk_setImageFromURL(NSURL(string: self.notificationArray.objectAtIndex(index).objectForKey("raiserThumb") as! String)!)
        }
        }
        
        if(notificationArray.count > 0){
        if(notificationArray.objectAtIndex(index).objectForKey("eventType") as? String == "2"){
           iconImage.image = UIImage(named: "likeIcon.png")
           iconView.backgroundColor = UIColor.redColor()
        }
        else if(notificationArray.objectAtIndex(index).objectForKey("eventType") as? String == "4"){
            iconImage.image = UIImage(named: "commentIcon.png")
            iconView.backgroundColor = UIColor(red: 29/255, green: 107/255, blue: 213/255, alpha: 1.0)
        }
        else if(notificationArray.objectAtIndex(index).objectForKey("eventType") as? String == "5"){
            iconImage.image = UIImage(named: "followIcon.png")
            iconView.backgroundColor = UIColor(red: 29/255, green: 107/255, blue: 213/255, alpha: 1.0)
        }
        else if(notificationArray.objectAtIndex(index).objectForKey("eventType") as? String == "9"){
            iconImage.image = UIImage(named: "mentionIcon.png")
            iconView.backgroundColor = UIColor(red: 55/255, green: 200/255, blue: 37/255, alpha: 1.0)
        }
        cell.contentView.addSubview(iconView)
        }
        if((cell.contentView.viewWithTag(22)) != nil){
            cell.contentView.viewWithTag(22)?.removeFromSuperview()
            cell.contentView.viewWithTag(28)?.removeFromSuperview()
            cell.contentView.viewWithTag(29)?.removeFromSuperview()
            cell.contentView.viewWithTag(33)?.removeFromSuperview()
        }
                
        cell.contentView.addSubview(statuslabel)
    }
    
    //MARK:- WebServiceCall
    
    func webServiceCall(){
        if (isConnectedToNetwork()){
        let url = String(format: "%@%@%@", baseUrl,controllerNotification,searchListMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject("1", forKey: "notificationGroup")
        
        webServiceCallingPost(url, parameters: params)
        delegate = self
        }
        else{
            internetMsg(view)
            stopLoading(self.view)
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        notificationArray = dict.objectForKey("notifications") as! NSArray
        if(notificationArray.count < 1){
            noNotificationAlert.hidden = false
        }
        else{
        tableView?.reloadData()
        }
        stopLoading(self.view)
        self.refreshControl.endRefreshing()
        
        self.tabBarController?.tabBar.userInteractionEnabled = true
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    func displayNotification(notification : NSNotification){
        if let info = notification.userInfo as? NSMutableDictionary {
            // Check if value present before using it
            
            AGPushNoteView.showWithNotificationMessage(info.objectForKey("aps")?.objectForKey("alert") as! String)
            self.performSelector("hideNotification", withObject: nil, afterDelay: 5)

        }
        else {
            print("wrong userInfo type")
        }
        
    }
    
    func hideNotification()
    {
    AGPushNoteView.close()
    }
    
    //MARK:- TabBarController Delegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.navigationController?.popToRootViewControllerAnimated(false)
        if(notificationArray.count > 0){
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tabBarController?.tabBar.userInteractionEnabled = true
        tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }
        selectedTabBarIndex = 3
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
