//
//  MoreViewController.swift
//  FoodTalk
//
//  Created by Ashish on 21/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

var eventName = String()

class MoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate, UITabBarControllerDelegate {
    
    @IBOutlet var tableView : UITableView?
    var moreArray : NSMutableArray = []
    
    var dict = NSDictionary()
    var refreshControl:UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tabBarController?.tabBar.userInteractionEnabled = false
        
        dict = (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        
        moreArray.addObject((dict.objectForKey("profile")?.objectForKey("userName") as? String)!)
        moreArray.addObject("Favorites")
        moreArray.addObject("Delhi-NCR")
        moreArray.addObject("Options")
        moreArray.addObject("Events and contests")
        
        showLoader(self.view)
        dispatch_async(dispatch_get_main_queue()) {
        self.webServiceCallForEvents()
        }
        
        self.refreshControl = UIRefreshControl()
        let attr = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:attr)
        self.refreshControl.tintColor = UIColor.whiteColor()
        
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView!.addSubview(refreshControl)

        Flurry.logEvent("More Screen")
      //  self.title = "More"
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        tableView!.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 45/255, alpha: 1.0)
        tableView?.separatorColor = UIColor(red: 47/255, green: 51/255, blue: 60/255, alpha: 1.0)
        let tblView =  UIView(frame: CGRectZero)
        tableView!.tableFooterView = tblView
        tableView!.tableFooterView!.hidden = true
    }
    
    //MARK:- RefreshControl Method
    func refresh(sender:AnyObject)
    {
        moreArray = NSMutableArray()
        moreArray.addObject((dict.objectForKey("profile")?.objectForKey("userName") as? String)!)
        moreArray.addObject("Favorite")
        moreArray.addObject("Delhi-NCR")
        moreArray.addObject("Options")
        moreArray.addObject("Events and contests")
        dispatch_async(dispatch_get_main_queue()) {
        self.webServiceCallForEvents()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        selectedTabBarIndex = 4
        self.navigationController?.navigationBarHidden = false
    }
    
    //MARK:- TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        
        self.addViewsOnCell(cell, index: indexPath.row)
        if(indexPath.row == 4){
            cell.backgroundColor = UIColor.blackColor()
            cell.textLabel?.textColor = UIColor.lightGrayColor()
            if(moreArray.count > 0){
            cell.textLabel?.text = moreArray.objectAtIndex(indexPath.row) as? String
            }
        }
        else{
            cell.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 45/255, alpha: 1.0)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 4){
            return 22
        }
        return 58
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.row == 0){
            isUserInfo = true
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("userProfileVC") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else if(indexPath.row == 1){
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("favorite") as! FavoriteViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else if(indexPath.row == 3){
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("Options") as! OptionsViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else if(indexPath.row == 4){
            
        }
        else if(indexPath.row == 2){
            
        }
        else{
            if(isConnectedToNetwork()){
                webViewCallingLegal = false
                if(self.moreArray.count > 0){
            eventName = (self.moreArray.objectAtIndex(indexPath.row).objectForKey("name") as? String)!
            webViewLink = self.moreArray.objectAtIndex(indexPath.row).objectForKey("url") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("webLink") as! WebLinkViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                }
            }
        }
        
    }
    
    func addViewsOnCell(cell : UITableViewCell, index : Int){
        if(index != 4){
            
        if(index == 0){
                let imgView = UIImageView()
                imgView.frame = CGRectMake(18, 9, 40, 40)
            imgView.contentMode = UIViewContentMode.ScaleAspectFit
              //  loadImageAndCache(imgView,url: (dict.objectForKey("profile")?.objectForKey("thumb") as? String)!)
            dispatch_async(dispatch_get_main_queue()) {
                imgView.hnk_setImageFromURL(NSURL(string: (self.dict.objectForKey("profile")?.objectForKey("thumb") as? String)!)!)
            }
                imgView.layer.cornerRadius = 20
                imgView.layer.masksToBounds = true
                cell.contentView.addSubview(imgView)
        }
        else{
            
        let optionIcon = UIImageView()
        let optionViewBook = UIView()
        let imgBookMark = UIImageView()
            if(index != 1){
                if(index == 2){
                optionViewBook.frame = CGRectMake(18, 9, 40, 40)
                optionViewBook.backgroundColor = UIColor(red: 28/255, green: 103/255, blue: 204/255, alpha: 1.0)
                optionViewBook.layer.cornerRadius = 20
                optionIcon.layer.masksToBounds = true
                cell.contentView.addSubview(optionViewBook)
                
                imgBookMark.frame = CGRectMake(10, 10, 20, 20)
                imgBookMark.image = UIImage(named: "location.png")
                optionViewBook.addSubview(imgBookMark)
                }
                else if(index == 3){
                    optionViewBook.frame = CGRectMake(18, 9, 40, 40)
                    optionViewBook.backgroundColor = UIColor(red: 111/255, green: 29/255, blue: 213/255, alpha: 1.0)
                    optionViewBook.layer.cornerRadius = 20
                    optionIcon.layer.masksToBounds = true
                    cell.contentView.addSubview(optionViewBook)
                    
                    imgBookMark.frame = CGRectMake(10, 10, 20, 20)
                    imgBookMark.image = UIImage(named: "settings.png")
                    optionViewBook.addSubview(imgBookMark)
                }
                else{
                    optionViewBook.frame = CGRectMake(18, 9, 40, 40)
                    optionViewBook.backgroundColor = UIColor(red: 45/255, green: 170/255, blue: 30/255, alpha: 1.0)
                    optionViewBook.layer.cornerRadius = 20
                    optionIcon.layer.masksToBounds = true
                    cell.contentView.addSubview(optionViewBook)
                    
                    imgBookMark.frame = CGRectMake(10, 10, 20, 20)
                    imgBookMark.image = UIImage(named: "eventsImage.png")
                    optionViewBook.addSubview(imgBookMark)
                }
            }
            else{
                optionViewBook.frame = CGRectMake(18, 9, 40, 40)
                optionViewBook.backgroundColor = UIColor.redColor()
                optionViewBook.layer.cornerRadius = 20
                optionIcon.layer.masksToBounds = true
                cell.contentView.addSubview(optionViewBook)
                
                imgBookMark.frame = CGRectMake(10, 10, 20, 20)
                imgBookMark.image = UIImage(named: "bookMarkNew.png")
                optionViewBook.addSubview(imgBookMark)
            }
        
        }
            
        if(index == 0){
           let statuslabel = UILabel()
           statuslabel.frame = CGRectMake(74, 2, UIScreen.mainScreen().bounds.size.width - 128, 25)
           statuslabel.textColor = UIColor.whiteColor()
           statuslabel.numberOfLines = 0
           statuslabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
            if(moreArray.count > 0){
           statuslabel.text = moreArray.objectAtIndex(index) as? String
            }
           cell.contentView.addSubview(statuslabel)
            
            let statuslabel1 = UILabel()
            statuslabel1.frame = CGRectMake(74, 25, UIScreen.mainScreen().bounds.size.width - 128, 23)
            statuslabel1.textColor = UIColor.grayColor()
            statuslabel1.font = UIFont(name:"HelveticaNeue", size: 15.0)
            statuslabel1.numberOfLines = 0
            statuslabel1.text = (dict.objectForKey("profile")?.objectForKey("fullName") as? String)!
            cell.contentView.addSubview(statuslabel1)
            
        }
        else{
            let statuslabel = UILabel()
            statuslabel.frame = CGRectMake(74, 5, UIScreen.mainScreen().bounds.size.width - 128, 40)
            if(index == 2){
                statuslabel.textColor = UIColor.grayColor()
            }
            else{
               statuslabel.textColor = UIColor.whiteColor()
            }
            
            statuslabel.numberOfLines = 0
            statuslabel.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
            if(index < 5){
            statuslabel.text = moreArray.objectAtIndex(index) as? String
            }
            else{
                if(moreArray.count > 0){
                if(moreArray.count > 5){
            statuslabel.text = moreArray.objectAtIndex(index).objectForKey("name") as? String
                }
                }
                statuslabel.tag = 3333
            }
            if((cell.contentView.viewWithTag(3333)) != nil){
                cell.contentView.viewWithTag(3333)?.removeFromSuperview()
            }
            cell.contentView.addSubview(statuslabel)
            }
        }
    }
    
    //MARK:- CallWebServiceForEvents
    
    func webServiceCallForEvents(){
        if (isConnectedToNetwork()){
            
            let url = "http://api.foodtalkindia.com/getfeeds"
            
            webServiceGet(url)
            delegate = self
        }
        else{
            internetMsg(view)
            stopLoading(self.view)
            self.refreshControl.endRefreshing()
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        if(dict.objectForKey("code") as! String == "200"){
            var arr = NSArray()
            arr = dict.objectForKey("result")?.objectForKey("data") as! NSArray
            for(var index : Int = 0; index < arr.count; index++){
                moreArray.addObject(arr.objectAtIndex(index))
            }
        }
        

        self.tabBarController?.tabBar.userInteractionEnabled = true
        
        tableView?.reloadData()
        self.refreshControl.endRefreshing()
        stopLoading(self.view)
    }
    
    func serviceFailedWitherror(error : NSError){
        stopLoading(self.view)
        self.tabBarController?.tabBar.userInteractionEnabled = true
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:- TabBarController Delegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        self.navigationController?.popToRootViewControllerAnimated(false)
        selectedTabBarIndex = 4
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
