//
//  VedioCallShowVc.swift
//  ios-swift-pjsua2
//
//  Created by Magictech on 03/03/23.
//

import UIKit

class VedioCallShowVc: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let captureSession = AVCaptureSession()

        // Create a video data output
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        // Add the output to the session
        captureSession.beginConfiguration()
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        captureSession.commitConfiguration()
        
        // Create a preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill

        // Add the preview layer to a view on your UI
        let previewView = UIView(frame: view.bounds)
        view.addSubview(previewView)
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)
        // Do any additional setup after loading the view.
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Create a CIImage from the pixel buffer
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        // Convert the CIImage to a UIImage for display on the preview layer
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let uiImage = UIImage(cgImage: cgImage)

        DispatchQueue.main.async {
            // Display the UIImage on the preview layer
            // Note: this code assumes that previewLayer is an instance variable holding your AVCaptureVideoPreviewLayer
//            previewLayer.contents = uiImage.cgImage
        }
    }
   

    
    //MARK: Btn Click
    @IBAction func btnCancle(_ sender: UIButton) {
    }
    
    @IBAction func btnAccept(_ sender: UIButton) {
        
    }
    
    

}
