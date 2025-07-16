//
//  BarcodeScannerVC.swift
//  BillingApp
//
//  Created by Tirth Shah on 16/07/25.
//

import UIKit
import AVFoundation

class BarcodeScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Variable
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var frameView: UIView!
    var onCodeScanned: ((String) -> Void)?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        addCancelButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        if let output = captureSession?.outputs.first as? AVCaptureMetadataOutput {
            let rectOfInterest = previewLayer!.metadataOutputRectConverted(fromLayerRect: frameView.frame)
            output.rectOfInterest = rectOfInterest
        }
    }
    
    // MARK: - Setup Camera
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession?.canAddInput(videoInput) == true else {
            GeneralUtility.showAlert(on: self, title: "Camera Error", message: "Device doesn't support camera.")
            return
        }
        captureSession?.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession?.canAddOutput(metadataOutput) == true else {
            GeneralUtility.showAlert(on: self, title: "Error", message: "Cannot scan barcode.")
            return
        }
        captureSession?.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .code128, .code39]
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
        if let layer = previewLayer {
            view.layer.insertSublayer(layer, at: 0)
        }
        
        addFrameOverlay()
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }
    
    // MARK: - Barcode Detection
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let code = metadata.stringValue {
            captureSession?.stopRunning()
            dismiss(animated: true) {
                self.onCodeScanned?(code)
            }
        }
    }

    // MARK: - Overlay Frame
    func addFrameOverlay() {
        frameView = UIView()
        frameView.layer.borderColor = UIColor.green.cgColor
        frameView.layer.borderWidth = 2
        frameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(frameView)
        
        NSLayoutConstraint.activate([
            frameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            frameView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            frameView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    // MARK: - Cancel Button
    func addCancelButton() {
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cancelBtn.layer.cornerRadius = 8
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelBtn)
        
        NSLayoutConstraint.activate([
            cancelBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancelBtn.widthAnchor.constraint(equalToConstant: 80),
            cancelBtn.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func cancelTapped() {
        captureSession?.stopRunning()
        dismiss(animated: true, completion: nil)
    }
}
