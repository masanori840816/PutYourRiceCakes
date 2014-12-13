//
//  ViewController.swift
//  PutYourRiceCakes
//
//  Created by Masui Masanori on 2014/12/13.
//  Copyright (c) 2014年 masanori_msl. All rights reserved.
//

import AVFoundation
import UIKit
import SceneKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate
{
    @IBOutlet weak var imvCameraView: UIImageView!
    @IBOutlet weak var scvRiceCakeView: SCNView!
    var cpsSession: AVCaptureSession!
    var imcImageController: ImageController!

    override func viewDidLoad() {
        super.viewDidLoad()
        imcImageController = ImageController()
        // 初期化.
        imcImageController.initImageController()
        
        self.initSceneView()
        self.initCameraView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initSceneView()
    {
        // シーンを作り、daeファイルを読み込む.
        let scnRiceCake = SCNScene(named: "RiceCake.dae")!
        
        // オブジェクトを映すカメラを作り、シーンに追加する.
        let nodCamera = SCNNode()
        nodCamera.camera = SCNCamera()
        scnRiceCake.rootNode.addChildNode(nodCamera)
        // カメラの位置を指定する.
        nodCamera.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // ライトを作成し、シーンに追加する.
        let nodLight = SCNNode()
        nodLight.light = SCNLight()
        // ライトの種類を指定する(全方位照射).
        nodLight.light!.type = SCNLightTypeOmni
        nodLight.position = SCNVector3(x: 0, y: 10, z: 10)
        nodLight.light!.color = UIColor.whiteColor()
        scnRiceCake.rootNode.addChildNode(nodLight)

        // 環境光を作成し、シーンに追加する.
        let nodAmbiendLight = SCNNode()
        nodAmbiendLight.light = SCNLight()
        nodAmbiendLight.light!.type = SCNLightTypeAmbient
        nodAmbiendLight.light!.color = UIColor.darkGrayColor()
        scnRiceCake.rootNode.addChildNode(nodAmbiendLight)
        
        scvRiceCakeView.scene = scnRiceCake
        // カメラ操作を有効にする.
        scvRiceCakeView.allowsCameraControl = true
        // 背景色の設定(透明にする).
        scvRiceCakeView.backgroundColor = UIColor(white:1, alpha:0)
    }
    func initCameraView()
    {
        var cpdCaptureDevice: AVCaptureDevice!
        
        // 背面カメラの検索
        for device: AnyObject in AVCaptureDevice.devices()
        {
            if device.position == AVCaptureDevicePosition.Back
            {
                cpdCaptureDevice = device as AVCaptureDevice
            }
        }
        // カメラが見つからなければリターン
        if (cpdCaptureDevice == nil) {
            println("Camera couldn't found")
            return
        }
        cpdCaptureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 30)
        
        // 入力データの取得
        var deviceInput: AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(cpdCaptureDevice, error: nil) as AVCaptureDeviceInput
        
        // 出力データの取得
        var videoDataOutput:AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        
        // カラーチャンネルの設定.
        let dctPixelFormatType : Dictionary<NSString, NSNumber> = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA]
        videoDataOutput.videoSettings = dctPixelFormatType
        
        // 画像をキャプチャするキューの指定
        //var videoDataOutputQueue: dispatch_queue_t = dispatch_queue_create("CtrlVideoQueue", DISPATCH_QUEUE_SERIAL)
        videoDataOutput.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        // セッションの使用準備
        self.cpsSession = AVCaptureSession()
        
        if(self.cpsSession.canAddInput(deviceInput))
        {
            self.cpsSession.addInput(deviceInput as AVCaptureDeviceInput)
        }
        else
        {
            NSLog("Failed adding Input")
        }
        if(self.cpsSession.canAddOutput(videoDataOutput))
        {
            self.cpsSession.addOutput(videoDataOutput)
        }
        else
        {
            NSLog("Failed adding Output")
        }
        self.cpsSession.sessionPreset = AVCaptureSessionPresetMedium
        
        self.cpsSession.startRunning()
    }
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        // SampleBufferから画像を取得してUIImageViewにセット.
        imvCameraView.image = imcImageController.createImageFromBuffer(sampleBuffer)
        
    }
}

