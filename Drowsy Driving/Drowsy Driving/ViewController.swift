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
    var analysis = ""
    var timer = [String]()
    private var audioPlayer: AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // 1
        labelView.layer.cornerRadius = 10
     
        sceneView.delegate = self
        sceneView.showsStatistics = true
     
        // 2
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        
        
        let sound = Bundle.main.path(forResource: "DJ Airhorn Sound Effect", ofType: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        }
        catch {
            print(error)
        }
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
            self.analysis += "Your eyes are closed."
                
            self.timer.append("penis")
            if self.timer.count > 70{
                audioPlayer.play()
            //AudioServicesPlaySystemSound(SystemSoundID(1005))
            }
        } else {
            self.timer = []
        }
    }
}
