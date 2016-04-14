//
//  FavoriteViewController.swift
//  FoodTalk
//
//  Created by Ashish on 15/01/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var favTableView : UITableView?
    var arrFavList : NSMutableArray = []
    var pageList : Int = 0
    
    var lblNoFav = UILabel()
    var imgNoFav = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Favorites"
        Flurry.logEvent("Favorite Screen")
        
        imgNoFav.frame = CGRectMake(self.view.frame.size.width / 2 - 11, 150, 22, 26)
        imgNoFav.image = UIImage(named: "bookMarkNew.png")
        self.view.addSubview(imgNoFav)
        
        lblNoFav.frame = CGRectMake(0, 200, self.view.frame.size.width, 20)
        lblNoFav.text = "You have no Favorites yet."
        lblNoFav.textColor = UIColor.whiteColor()
        lblNoFav.textAlignment = NSTextAlignment.Center
        lblNoFav.font = UIFont(name: fontBold, size: 15)
        self.view.addSubview(lblNoFav)
        
        imgNoFav.hidden = true
        lblNoFav.hidden = true
        
        favTableView?.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 46/255, alpha: 1.0)
        favTableView?.separatorColor = UIColor(red: 47/255, green: 51/255, blue: 60/255, alpha: 1.0)
        let tblView =  UIView(frame: CGRectZero)
        favTableView!.tableFooterView = tblView
        favTableView!.tableFooterView!.hidden = true
        dispatch_async(dispatch_get_main_queue()) {
          self.callWebServiceMethods()
        }
    }
    
    //MARK:- WebServices and Delegates
    
    func callWebServiceMethods(){
        if(isConnectedToNetwork()){
            pageList++
            showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl,controllerBookmark,postListMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(pageList, forKey: "page")
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(view)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        stopLoading(self.view)
        if(dict.objectForKey("status") as! String == "OK"){
            let arr = dict.objectForKey("dish")?.mutableCopy() as! NSMutableArray
            for(var index: Int = 0; index < arr.count; index++){
                arrFavList.addObject(arr.objectAtIndex(index))
            }
            favTableView?.reloadData()
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
        hideProcessLoader(self.view)
        if(arrFavList.count < 1){
            imgNoFav.hidden = false
            lblNoFav.hidden = false
        }
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:- Tableview datasource and delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFavList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundColor = UIColor.clearColor()
        
        if(arrFavList.count > 0){
        let iconView = UIView()
        iconView.frame = CGRectMake(15, 5, 40, 40)
        iconView.backgroundColor = UIColor(red: 236/255, green: 237/255, blue: 238/255, alpha: 1.0)
        iconView.tag = 29
        iconView.layer.cornerRadius = iconView.frame.size.width/2
        iconView.clipsToBounds = true
        
        
        let cellIcon = UIImageView()
        cellIcon.frame = CGRectMake(7, 7, 25, 25)
        cellIcon.layer.cornerRadius = cellIcon.frame.size.width/2
        cellIcon.image = UIImage(named: "dishIcon.png")
        cellIcon.clipsToBounds = true
        iconView.addSubview(cellIcon)
        
        let favName = UILabel()
        favName.frame = CGRectMake(60, 0, cell.frame.size.width - 60, 50)
        favName.tag = 1022
        favName.text = arrFavList.objectAtIndex(indexPath.row).objectForKey("dishName") as? String
        favName.textColor = UIColor.whiteColor()
        
        cell.contentView.addSubview(iconView)
        
            
            if((cell.contentView.viewWithTag(1022)) != nil){
                cell.contentView.viewWithTag(1022)?.removeFromSuperview()
            }
            cell.contentView.addSubview(favName)
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    //MARK:- ScrollView Delegates
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom as CGFloat
        let h = size.height as CGFloat
        let reload_distance = 15.0 as CGFloat
        if(y > h + reload_distance) {
            dispatch_async(dispatch_get_main_queue()) {
             showProcessLoder(self.view)
             self.callWebServiceMethods()
            }
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
