//
//  ViewController.swift
//  Drowsy Driving
//
//  Created by Ethan Wong on 10/26/19.
//  Copyright © 2019 Ethan Wong. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AudioToolbox
import AVFoundation
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var faceLabel: UILabel!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var screen1: UIImageView!
    @IBOutlet weak var screen2: UIImageView!
    @IBAction func swipeButton(_ sender: TGFlingActionButton) {
    }
    
    var awakeText: UILabel!
    var analysis = ""
    var timer = [String]()
    var button: UIButton!
    private var audioPlayer: AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        //createButton()
        labelView.layer.cornerRadius = 10
        sceneView.delegate = self
        sceneView.showsStatistics = true
        constraints()
        screen2.isHidden = true
        
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        
        
        let sound = Bundle.main.path(forResource: "alarm", ofType: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        }
        catch {
            print(error)
        }
    }

    func createButton() {
        button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle("Test Button", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @IBAction func flingActionCallback(_ sender: TGFlingActionButton) {
        audioPlayer.stop()
        self.screen1.isHidden = false
        self.screen2.isHidden = true
    }
    @objc func buttonAction(sender: UIButton!) {
        audioPlayer.stop()
        self.screen1.isHidden = false
        self.screen2.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    func constraints() {
        screen1.widthAnchor.constraint(equalToConstant: 180).isActive = true
        screen1.heightAnchor.constraint(equalToConstant: 180).isActive = true
        screen1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        screen1.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 28).isActive = true
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor)
            
            DispatchQueue.main.async {
                self.faceLabel.text = self.analysis
              
            }
            
        }
    }
    func expression(anchor: ARFaceAnchor) {
        let leftEye = anchor.blendShapes[.eyeBlinkLeft]
        let rightEye = anchor.blendShapes[.eyeBlinkRight]
        self.analysis = ""
     
        if(leftEye?.decimalValue ?? 0.0 > 0.8) && (rightEye?.decimalValue ?? 0.0 > 0.8){
            self.analysis += "AWAKE"
            self.timer.append("closed")
            print("closed")
            if self.timer.count > 30{
                audioPlayer.play()
                DispatchQueue.main.async {
                    self.screen1.isHidden = true
                    self.screen2.isHidden = false
                }
                
            }
        } else {
            self.timer = []
            DispatchQueue.main.async {
                self.audioPlayer.stop()
                self.screen1.isHidden = false
                self.screen2.isHidden = true
            }
            
        }
    }
}
