//
//  WebLinkViewController.swift
//  FoodTalk
//
//  Created by Ashish on 05/02/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

var webViewLink = String()

class WebLinkViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView : UIWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        // Do any additional setup after loading the view.
        if(webViewCallingLegal == false){
        Flurry.logEvent("Event Screen on Web")
       let dict = (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        let uname = (dict.objectForKey("profile")?.objectForKey("fullName") as? String)
        
        let fbId = NSUserDefaults.standardUserDefaults().objectForKey("fbId") as! String
        
        let webLink = String(format: "%@source=APP&uname=%@&fbid=%@", webViewLink, uname!, fbId)
            print(webLink)
        let  urlString = webLink.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        showLoader(self.view)
        
        if(isConnectedToNetwork()){
        dispatch_async(dispatch_get_main_queue()) {
         self.webView!.loadRequest(NSURLRequest(URL: NSURL(string: urlString)!))
        }
        }
        else{
           internetMsg(self.view)
        }
            self.title = eventName
        }
        else{
            let webLink = String(format: "http://www.foodtalkindia.com/document.html")
            let  urlString = webLink.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            showLoader(self.view)
            
            if(isConnectedToNetwork()){
                dispatch_async(dispatch_get_main_queue()) {
                    self.webView!.loadRequest(NSURLRequest(URL: NSURL(string: urlString)!))
                }
            }
            else{
                internetMsg(self.view)
            }
            self.title = "Legal"
        }
        
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        stopLoading(self.view)
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
