//
//  TakePhotoViewController.swift
//  Quick & Easy Photo ID
//
//  Created by bhavin on 22/05/18.
//  Copyright © 2018 Busy. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import RealmSwift

class TakePhotoViewController : BaseViewController {
    
    @IBOutlet var cropAreaView: UIView!
    @IBOutlet fileprivate var previewView: PreviewView!
    @IBOutlet fileprivate var toggleFlashButton: UIBarButtonItem!
    //@IBOutlet fileprivate var cameraButton: UIBarButtonItem!
    @IBOutlet weak var photoButton : UIButton!
    @IBOutlet weak var lblCropSize : UILabel!
    @IBOutlet var conHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBottomBlack : UIView!
    
    var selectedRatio:String?
    var country:String?
    var selectedType:String?
    var picker:UIImagePickerController? = UIImagePickerController()
    var IDSize : Int = 280
    var tmpSelectedImage : UIImage?
    var aspectHeightHead : String = ""
    //var isCaptureMultiplePic = false
    //var isRedictToCodeGen : Bool = false
    
    // MARK: Session Management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.
    
    private var setupResult: SessionSetupResult = .success
    
    var videoDeviceInput: AVCaptureDeviceInput!
    private let photoOutput = AVCapturePhotoOutput()
    
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera],
                                                                               mediaType: .video, position: .unspecified)
    
    //MARK: - custom methods
    
    func setupView(){
        
        picker?.delegate = self
        self.lblCropSize.text = self.aspectHeightHead
        self.addNavBackBtn(withSelector: #selector(goBack))
        self.conHeight.constant = CGFloat(self.IDSize)
        
        if !Platform.isSimulator {
            self.setupButtons()
        }
        
        
        self.viewBottomBlack.layer.borderColor = UIColor.white.cgColor
        self.viewBottomBlack.layer.borderWidth = 1.0
    }
    
    func setupButtons() {
        
        //cameraButton.isEnabled = false
        photoButton.isEnabled = false
        // Set up the video preview view.
        previewView.session = session
        
        /*
         Check video authorization status. Video access is required and audio
         access is optional. If audio access is denied, audio is not recorded
         during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        
        sessionQueue.async {
            self.configureSession()
        }
        
    }
    
    // Call this on the session queue.
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        /*
         We do not create an AVCaptureMovieFileOutput when setting up the session because the
         AVCaptureMovieFileOutput does not support movie recording with AVCaptureSession.Preset.Photo.
         */
        session.sessionPreset = .photo
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the back dual camera if available, otherwise default to a wide angle camera.
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // If the back dual camera is not available, default to the back wide angle camera.
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                /*
                 In some cases where users break their phones, the back wide angle camera is not available.
                 In this case, we should default to the front wide angle camera.
                 */
                defaultVideoDevice = frontCameraDevice
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: statusBarOrientation) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
//        // Add audio input.
//        do {
//            let audioDevice = AVCaptureDevice.default(for: .audio)
//            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
//            
//            if session.canAddInput(audioDeviceInput) {
//                session.addInput(audioDeviceInput)
//            } else {
//                print("Could not add audio device input to the session")
//            }
//        } catch {
//            print("Could not create audio device input: \(error)")
//        }
        
        // Add photo output.
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
            photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
            
            
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    
    private enum CaptureMode: Int {
        case photo = 0
        case movie = 1
    }
    
    private var inProgressLivePhotoCapturesCount = 0
    
    //MARK: - Action Method
    @IBAction func capturePhoto(_ sender: UIButton) {
        /*
         Retrieve the video preview layer's video orientation on the main queue before
         entering the session queue. We do this to ensure UI elements are accessed on
         the main thread and session configuration is done on the session queue.
         */
        let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            // Update the photo output's connection to match the video orientation of the video preview layer.
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            }
            
            var photoSettings = AVCapturePhotoSettings()
            // Capture HEIF photo when supported, with flash set to auto and high resolution photo enabled.
            if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
                
            }
            
            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = .auto
            }
            
            photoSettings.isHighResolutionPhotoEnabled = true
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }
            
            
            // Use a separate object for the photo capture delegate to isolate each capture life cycle.
            let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
                DispatchQueue.main.async {
                    self.previewView.videoPreviewLayer.opacity = 0
                    UIView.animate(withDuration: 0.25) {
                        self.previewView.videoPreviewLayer.opacity = 1
                    }
                }
            }, livePhotoCaptureHandler: { capturing in
                /*
                 Because Live Photo captures can overlap, we need to keep track of the
                 number of in progress Live Photo captures to ensure that the
                 Live Photo label stays visible during these captures.
                 */
                self.sessionQueue.async {
                    if capturing {
                        self.inProgressLivePhotoCapturesCount += 1
                    } else {
                        self.inProgressLivePhotoCapturesCount -= 1
                    }
                }
            }, completionHandler: { photoCaptureProcessor in
                // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
                
                
                self.sessionQueue.async {
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                    
                    
                    DispatchQueue.main.async {
                        if let data = photoCaptureProcessor.photoData{
                            
                            let bcf = ByteCountFormatter()
                            bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
                            bcf.countStyle = .file
                            let string = bcf.string(fromByteCount: Int64(data.count))
                            print("MB:- \(string)")
                            
                            var croppedImage = UIImage(data: data)
                            let imgData = croppedImage?.jpeg
                            croppedImage = UIImage(data: imgData!)
                            CropUser.shared.image = croppedImage
                            
                            //CropUser.shared.ratio = self.selectedRatio
                            if CropUser.shared.isCaptureMultiplePic {
                                let addContact = AddContact()
                                addContact.FullName = "Person"
                                addContact.imageData = imgData!
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.add(addContact)
                                }
                                let homeVC = MultiplePersonVC.instantiate(fromAppStoryboard: .Main)
                                self.navigationController?.pushViewController(homeVC, animated: true)
                            }else {
                                if CropUser.shared.isRedictToCodeGen {
                                    let previewVC = PreviewViewController.instantiate(fromAppStoryboard: .Main)
                                    previewVC.image = croppedImage
                                    self.navigationController?.pushViewController(previewVC, animated: true)
                                }else{
                                    let previewVC = PreviewViewController.instantiate(fromAppStoryboard: .Main)
                                    previewVC.image = croppedImage
                                    self.navigationController?.pushViewController(previewVC, animated: true)
                                    
                                }
                            }
                            
                        }
                    }
                }
            }
            )
            
            /*
             The Photo Output keeps a weak reference to the photo capture delegate so
             we store it in an array to maintain a strong reference to this object
             until the capture is completed.
             */
            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
        }
    }
    
    @IBAction func btnGalleryTapped(_ sender : UIButton){
        self.openLibrary()
        //let galleryVC = self.storyboard?.instantiateViewController(withIdentifier: "CropImageViewController") as! CropImageViewController
//        self.navigationController?.pushViewController(galleryVC, animated: true)
    }
    
    @IBAction func btnSettingsTapped(_ sender : UIButton){
        
    }
    
    @IBAction func toggleFlash(_ sender: UIBarButtonItem) {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureDevice.TorchMode.on) {
                    device?.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try device?.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func switchCameras(_ sender: UIBarButtonItem) {
        //cameraButton.isEnabled = false
        
        photoButton.isEnabled = false
        
        
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
                
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInWideAngleCamera
            }
            
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            // First, look for a device with both the preferred position and device type. Otherwise, look for a device with only the preferred position.
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    
                    // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        
                        
                        
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    
                    
                    
                    /*
                     Set Live Photo capture and depth data delivery if it is supported. When changing cameras, the
                     `livePhotoCaptureEnabled and depthDataDeliveryEnabled` properties of the AVCapturePhotoOutput gets set to NO when
                     a video device is disconnected from the session. After the new video device is
                     added to the session, re-enable them on the AVCapturePhotoOutput if it is supported.
                     */
                    self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported
                    self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
                    
                    self.session.commitConfiguration()
                } catch {
                    print("Error occured while creating video device input: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                //self.cameraButton.isEnabled = true
                
                self.photoButton.isEnabled = true
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        if CropUser.shared.isRedictToCodeGen {
            cropAreaView.isHidden = true
        }else{
            cropAreaView.isHidden = false
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //let colors = [UIColor(red: 136.0/255.0, green: 1.0/255.0, blue: 13.0/255.0, alpha: 1.0),UIColor(red: 44.0/255.0, green: 50.0/255.0, blue: 67.0/255.0, alpha: 1.0)]
        //self.navigationController?.navigationBar.setGradientBackground(colors: colors)
        navigationItem.title = "Take Photo"
        
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                            style: .`default`,
                                                            handler: { _ in
                                                                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private var keyValueObservations = [NSKeyValueObservation]()
    
}


extension TakePhotoViewController {
    
    // MARK: KVO and Notifications
    
    
    
    private func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            let isLivePhotoCaptureSupported = self.photoOutput.isLivePhotoCaptureSupported
            let isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureEnabled
            let isDepthDeliveryDataSupported = self.photoOutput.isDepthDataDeliverySupported
            let isDepthDeliveryDataEnabled = self.photoOutput.isDepthDataDeliveryEnabled
            
            DispatchQueue.main.async {
                // Only enable the ability to change camera if the device has more than one camera.
                //self.cameraButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
                
                self.photoButton.isEnabled = isSessionRunning
                
            }
        }
        keyValueObservations.append(keyValueObservation)
        
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
}


extension TakePhotoViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func openLibrary() {
        
        Utility.getPhotoLibraryAuthorizationStatus { (status, error) in
            if status {
                DispatchQueue.main.async {
                    self.picker?.sourceType = .photoLibrary
                    self.present(self.picker!, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if CropUser.shared.isCaptureMultiplePic {
            picker.dismiss(animated: true) {
                let addContact = AddContact()
                addContact.FullName = "Person"
                if let data = image?.jpeg {
                    addContact.imageData = data
                }else {
                    
                }
                
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(addContact)
                }
                let homeVC = MultiplePersonVC.instantiate(fromAppStoryboard: .Main)
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
        }else {
            if CropUser.shared.isRedictToCodeGen {
                let previewVC = PreviewViewController.instantiate(fromAppStoryboard: .Main)
                previewVC.image = image
                picker.dismiss(animated: true) {
                    self.navigationController?.pushViewController(previewVC, animated: true)
                }
            }else{
                let previewVC = PreviewViewController.instantiate(fromAppStoryboard: .Main)
                previewVC.image = image
                picker.dismiss(animated: true) {
                    self.navigationController?.pushViewController(previewVC, animated: true)
                }
            }
        }
        /*let image = info[UIImagePickerControllerOriginalImage] as! UIImage
         
         CropUser.shared.image = image
         CropUser.shared.ratio = self.selectedRatio
         let cropVC = CropViewController.instantiate(fromAppStoryboard: .Main)
         cropVC.image = image
         cropVC.country = self.country
         cropVC.selectedType = self.selectedType
         
         
         
         
         picker.dismiss(animated: true) {
         self.navigationController?.pushViewController(cropVC, animated: true)
         }*/
        
        
    }
}


struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
}

extension UIImage {
    func upOrientationImage() -> UIImage? {
        switch imageOrientation {
        case .up:
            return self
        default:
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(in: CGRect(origin: .zero, size: size))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result
        }
    }
}
