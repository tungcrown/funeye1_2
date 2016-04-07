//
//  ReviewVideoVC.swift
//  Custom Camera
//
//  Created by Lê Thanh Tùng on 3/27/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ReviewVideoVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var uivNavigate: UIView!
    @IBOutlet weak var uivReviewVideo: UIView!
    @IBOutlet weak var uivInput: UIView!
    @IBOutlet weak var uivInputMain: UIView!
    
    @IBOutlet weak var txtShowText: UITextView!
    @IBOutlet weak var txtInputText: UITextView!
    
    private var Observer: NSObjectProtocol!
    
    var dataPass: [String: [NSURL]]!
    var player: AVPlayer!
    
    var urlVideos: [NSURL]!
    var urlAudio: [NSURL]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dataPass != nil {
            urlVideos = dataPass["video"]
            urlAudio = dataPass["audio"]
        } else {
            print("nil data pass")
        }
        
        mergerVideos(urlVideos)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ReviewVideoVC.showInputTextField(_:)))
        tap.numberOfTapsRequired = 1
        
        txtShowText.addGestureRecognizer(tap)
        
        let tapVideoView = UITapGestureRecognizer(target: self, action: #selector(ReviewVideoVC.tappedVideoView(_:)))
        tapVideoView.numberOfTapsRequired = 1
        uivReviewVideo.addGestureRecognizer(tapVideoView)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func keyboardWillShow() {
        uivInputMain.hidden = false
        uivNavigate.hidden = true
        txtInputText.becomeFirstResponder()
        if txtShowText.text == "Enter your caption" {
            txtInputText.text = ""
        } else {
            txtInputText.text = txtShowText.text
        }
        
    }
    
    func keyboardHideShow() {
        uivNavigate.hidden = false
        txtInputText.resignFirstResponder()
        if txtInputText.text == "" {
            txtShowText.text = "Enter your caption"
            txtShowText.textColor = UIColor.lightGrayColor()
        } else {
            txtShowText.text = txtInputText.text
            txtShowText.textColor = UIColor.darkTextColor()
        }
        
    }
    
    func showInputTextField(sender: UITapGestureRecognizer) {
        keyboardWillShow()
        txtInputText.becomeFirstResponder()
    }
    
    func tappedVideoView(sender: UITapGestureRecognizer) {
        if ((player.rate != 0) && (player.error == nil)) {
            player.pause()
        }else {
            player.play()
        }
    }
    
    @IBAction func btnCancelInputText(sender: UIButton) {
        keyboardHideShow()
    }
    @IBAction func tappedHideInputText(sender: UITapGestureRecognizer) {
        keyboardHideShow()
    }
    
    func mergerVideos(videos: [NSURL] ){
        let composition = AVMutableComposition()
        composition.naturalSize = CGSizeMake(300, 300)
        let track = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID:Int32(kCMPersistentTrackID_Invalid))
        
        var index = 0
        for video in videos {
            let NsUrlVideo = video
            let videoAsset = AVAsset(URL: NsUrlVideo)
            
            if index == 0 {
                do {
                    try track.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack, atTime: kCMTimeZero)
                } catch let err as NSError {
                    print("error merger \(err.debugDescription)")
                }
            }else {
                do {
                    try track.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack, atTime: composition.duration)
                } catch let err as NSError {
                    print("error merger 2 \(err.debugDescription)")
                }
            }
            
            index += 1
        }
        CutVideoRecordingSquare(composition)
    }
    
    func CutVideoRecordingSquare(composition: AVAsset) {
        
        let asset: AVAsset = composition
        let videoAsset: AVAsset = composition
        
        let clipVideoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first! as AVAssetTrack
        
        let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        
        videoComposition.frameDuration = CMTimeMake(1, 60)
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
        
        
        let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        let transformer: AVMutableVideoCompositionLayerInstruction =
            AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        let t1: CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0)
        let t2: CGAffineTransform = CGAffineTransformRotate(t1, CGFloat(M_PI_2))
        
        let finalTransform: CGAffineTransform = t2
        
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        
        instruction.layerInstructions = NSArray(object: transformer) as! [AVVideoCompositionLayerInstruction]
        videoComposition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
        
        let tempPath = createTempPath(PATH_SAVE_RCORDING_VIDEO)
        
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exporter.videoComposition = videoComposition
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.outputURL = tempPath
        exporter.shouldOptimizeForNetworkUse = true
    
        exporter.exportAsynchronouslyWithCompletionHandler({
            let outputURL:NSURL = exporter.outputURL!
            dispatch_async(dispatch_get_main_queue(), {
                self.mergerAudioAndVideo(outputURL, pathAudio: self.urlAudio[0])
            })
            
        })
    }
    
    func mergerAudioAndVideo(pathVideo: NSURL, pathAudio: NSURL) {
        let videoAsset = AVAsset(URL: pathVideo)
        let audioAsset = AVAsset(URL: pathAudio)
        
        let mixComposition = AVMutableComposition()
        mixComposition.naturalSize = CGSizeMake(300, 300)
        
        let videoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID:Int32(kCMPersistentTrackID_Invalid))
        let audioTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: 0)
        
        do {
            try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack, atTime: kCMTimeZero)
        } catch let err as NSError {
            print("error merger \(err.debugDescription)")
        }
        
        do {
            try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: audioAsset.tracksWithMediaType(AVMediaTypeAudio)[0] as AVAssetTrack, atTime: kCMTimeZero)
        } catch let err as NSError {
            print("error merger \(err.debugDescription)")
        }
        
        
         let tempPath = createTempPath(PATH_SAVE_RCORDING_VIDEO)
         
         let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
         exporter.outputFileType = AVFileTypeQuickTimeMovie
         exporter.outputURL = tempPath
         exporter.shouldOptimizeForNetworkUse = true
         
         exporter.exportAsynchronouslyWithCompletionHandler({
         
         //display video after export is complete, for example...
         let outputURL:NSURL = exporter.outputURL!
         print("outpur nsurl: \(outputURL)")
         dispatch_async(dispatch_get_main_queue(), {
            
            self.player = AVPlayer(URL: outputURL)
            let playerController = AVPlayerViewController()
            
            playerController.view.frame = self.uivReviewVideo.bounds
            playerController.view.sizeToFit()
            
            playerController.showsPlaybackControls = false
            playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            self.uivReviewVideo.addSubview(playerController.view)
            playerController.player = self.player
            self.player.play()
            self.loopVideo(self.player)
         })
         
         })
    }
    private func loopVideo(videoPlayer: AVPlayer) {
        self.Observer = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { notification in
            videoPlayer.seekToTime(kCMTimeZero)
            videoPlayer.play()
            
            print("loop video review :\(videoPlayer)")
        }
    }
    
    private func removeLoopVideo() {
        if self.Observer != nil {
            NSNotificationCenter.defaultCenter().removeObserver(self.Observer)
        }
    }
    @IBAction func btnBackACTION(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
        //performSegueWithIdentifier("BackToNewFeeds", sender: nil)
        
        removeLoopVideo()
    }
    
    @IBAction func btnBackToNewfeeds(sender: UIButton) {
//        performSegueWithIdentifier("BackToNewfeeds", sender: nil)
        removeLoopVideo()
    }
}
