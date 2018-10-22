//
//  ViewController.swift
//  ChickenFight
//
//  Created by Tushar Chopra on 10/20/18.
//  Copyright © 2018 Tushar Chopra. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var didAddNode = false
    var planePosition = SCNVector3(0, 0, 0)
    var main = SCNNode()
    var hasTouched = false
    var player1 = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.debugOptions = .showFeaturePoints
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !didAddNode{
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            // 2
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            let plane = SCNBox(width: width, height: 0.001, length: height, chamferRadius: 0)
            
            // 3
            plane.materials.first?.diffuse.contents = UIColor.blue.withAlphaComponent(0.7)
            
            // 4
            var planeNode = SCNNode(geometry: plane)
            
            // 5
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x,y,z)
            
            // 6
            main = node
            node.addChildNode(planeNode)
            planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            didAddNode = true
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if !hasTouched{
            guard let planeAnchor = anchor as?  ARPlaneAnchor,
                var planeNode = node.childNodes.first,
                let plane = planeNode.geometry as? SCNBox
                else { return }
            
            // 2
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            plane.width = width
            plane.length = height
            
            // 3
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x, y, z)
            planePosition = planeNode.position
        }
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        box.materials.first?.diffuse.contents = UIColor.red
        
        var boxNode = SCNNode(geometry: box)
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        if !hasTouched {
            boxNode.position = SCNVector3(planePosition.x, planePosition.y + 0.11, planePosition.z)
            player1 = boxNode
            main.addChildNode(boxNode)
            
            
        }
        var touch = touches.first as! UITouch
        var point = touch.location(in: self.view)
        
        if point.x < view.frame.width / 2 {
            player1.physicsBody?.applyForce(SCNVector3(0, 3, 0), asImpulse: true)
        } else {
            print(player1.physicsBody?.type)
            
        }
        
        hasTouched = true
    }
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
