//
//  XMCCameraViewController.swift
//  dojo-custom-camera
//
//  Created by David McGraw on 11/13/14.
//  Copyright (c) 2014 David McGraw. All rights reserved.
//

import UIKit
import AVFoundation

var imageSelected = UIImage()
var picMethod : String = ""
var choosePicMethod : String = ""

class XMCCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,XMCCameraDelegate {

    @IBOutlet weak var cameraStill: UIImageView!
    @IBOutlet weak var cameraPreview: UIView!
//    @IBOutlet weak var cameraStatus: UILabel!
    @IBOutlet var cameraCapture: UIButton!
    @IBOutlet var btngallary : UIButton?
    @IBOutlet var cancelBtn : UIButton?
//    @IBOutlet weak var cameraCaptureShadow: UILabel!
    
    @IBOutlet var flashBtn : UIButton?
    
    var preview: AVCaptureVideoPreviewLayer?
    var imagePicker : UIImagePickerController?
    
    var camera: XMCCamera?
    var status: Status = .Preview
    
    var isCameraOn : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "dishTagCall")
        self.initializeCamera()
    }
    
    func dishTagCall(){
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishTag") as! DishTagViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    
    override func viewWillAppear(animated: Bool) {
        isCameraOn = false
        let image = UIImage(named: "flash.png")
        flashBtn?.setImage(image, forState: UIControlState.Normal)
        self.view.userInteractionEnabled = true
        self.navigationController?.navigationBarHidden = true
        
        UIView.animateWithDuration(0, animations: { () -> Void in
            self.cameraStill.alpha = 0.0;
         //   self.cameraStatus.alpha = 0.0;
            self.cameraPreview.alpha = 1.0;
            self.cameraCapture.setTitle("", forState: UIControlState.Normal)
            }, completion: { (done) -> Void in
                self.cameraStill.image = nil;
                self.status = .Preview
        })
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
  
    }
    
    func initializeCamera() {
     //   self.cameraStatus.text = ""
        self.camera = XMCCamera(sender: self)
        self.establishVideoPreviewArea()
    }
    
    func establishVideoPreviewArea() {
        self.preview = AVCaptureVideoPreviewLayer(session: self.camera?.session)
        self.preview?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.preview?.frame = self.cameraPreview.bounds
        self.preview?.cornerRadius = 8.0
        self.cameraPreview.layer.addSublayer(self.preview!)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: Button Actions
    
    @IBAction func captureFrame(sender: AnyObject) {
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        if(isCameraOn == true){
            do{
            try device.lockForConfiguration()
            do {
                try device.setTorchModeOnWithLevel(1.0)
                }
                catch {
                    print(error)
                }
            
           device.unlockForConfiguration()
            }
            catch {
                print(error)
                }
        }
        else{
            
        }
        
        if self.status == .Preview {
     //       self.cameraStatus.text = ""
            UIView.animateWithDuration(0, animations: { () -> Void in
                self.cameraPreview.alpha = 0.0;
      //          self.cameraStatus.alpha = 1.0
            })
            
            self.camera?.captureStillImage({ (image) -> Void in
                if image != nil {
                   // self.cameraStill.image = image;
                    imageSelected = image!
                    
                    let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("cropped") as! CroppingImageViewController;
                    openPost.checkBounds = true;
                    openPost.rotateEnabled = true;
                    openPost.sourceImage = image;
                    openPost.previewImage = image;
                    openPost.reset(false);
                    
                     if(self.isCameraOn == true){
                        do{
                            try device.lockForConfiguration()
                         
                                device.torchMode = AVCaptureTorchMode.Off

                            
                            device.unlockForConfiguration()
                        }
                        catch {
                            print(error)
                        }
                        self.isCameraOn = false
                    }
                    
                    self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                    
                    UIView.animateWithDuration(0, animations: { () -> Void in
                        self.cameraStill.alpha = 1.0;
    //                    self.cameraStatus.alpha = 0.0;
                    })
                    self.status = .Still
                } else {
   //                 self.cameraStatus.text = "Uh oh! Something went wrong. Try it again."
                    self.status = .Error
                }
                
                self.cameraCapture.setTitle("Reset", forState: UIControlState.Normal)
            })
        } else if self.status == .Still || self.status == .Error {
            UIView.animateWithDuration(0, animations: { () -> Void in
                self.cameraStill.alpha = 0.0;
  //              self.cameraStatus.alpha = 0.0;
                self.cameraPreview.alpha = 1.0;
                self.cameraCapture.setTitle("", forState: UIControlState.Normal)
            }, completion: { (done) -> Void in
                self.cameraStill.image = nil;
                self.status = .Preview
            })
        }
        picMethod = "Retake"
        choosePicMethod = "Use photo"
    }
    
    // MARK: Camera Delegate
    
    func cameraSessionConfigurationDidComplete() {
        self.camera?.startCamera()
    }
    
    func cameraSessionDidBegin() {
 //       self.cameraStatus.text = ""
        UIView.animateWithDuration(0, animations: { () -> Void in
  //          self.cameraStatus.alpha = 0.0
            self.cameraPreview.alpha = 1.0
            self.cameraCapture.alpha = 1.0
  //          self.cameraCaptureShadow.alpha = 0.4;
        })
    }
    
    func cameraSessionDidStop() {
 //       self.cameraStatus.text = "Camera Stopped"
        UIView.animateWithDuration(0, animations: { () -> Void in
 //           self.cameraStatus.alpha = 1.0
            self.cameraPreview.alpha = 0.0
        })
    }
    
    //BackzbuttonAction
    
    @IBAction func cameraBackAction(sender : UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func openGallary(sender : UIButton){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            imagePicker = UIImagePickerController()
            imagePicker!.delegate = self
            imagePicker!.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            self.presentViewController(imagePicker!, animated: true, completion: nil)
        }
    }
    
    @IBAction func openFlash(sender : UIButton){
        
        if( isCameraOn == false){
            isCameraOn = true
            let image = UIImage(named: "flashYellow.png")
            flashBtn?.setImage(image, forState: UIControlState.Normal)
        }
        else{
            isCameraOn = false
            let image = UIImage(named: "flash.png")
            flashBtn?.setImage(image, forState: UIControlState.Normal)
        }
        
    }
    
    func flashFunction(){
        
    }
    
    func callDelay(){
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("cropped") as! CroppingImageViewController;
        openPost.checkBounds = true;
        openPost.rotateEnabled = true;
        openPost.sourceImage = cameraStill.image;
        openPost.previewImage = cameraStill.image;
        openPost.reset(false);
        self.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        cameraStill.image = image
        
        showLoader(view)
        imageSelected = image
        picMethod = "Cancel"
        choosePicMethod = "Choose"
        
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("cropped") as! CroppingImageViewController;
        openPost.checkBounds = true;
        openPost.rotateEnabled = true;
        openPost.sourceImage = image;
        openPost.previewImage = image;
        openPost.reset(false);
        self.navigationController!.pushViewController(openPost, animated:true);
        
       self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
}

