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
            let plane = SCNPlane(width: width, height: height)
            
            // 3
            plane.materials.first?.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
            
            // 4
            var planeNode = SCNNode(geometry: plane)
            
            // 5
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x,y,z)
            planeNode.eulerAngles.x = -.pi / 2
            
            // 6
            main = node
            node.addChildNode(planeNode)
            update(&planeNode, geometry: plane, type: .static)
            didAddNode = true
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            var planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        planePosition = planeNode.position
        update(&planeNode, geometry: plane, type: .static)
    }
    
    func update(_ node: inout SCNNode, geometry: SCNGeometry, type: SCNPhysicsBodyType){
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        let body = SCNPhysicsBody(type: type, shape: shape)
        
        node.physicsBody = body
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
        
        if !hasTouched {
            boxNode.position = SCNVector3(planePosition.x, planePosition.y + 0.5, planePosition.z)
            main.addChildNode(boxNode)
            update(&boxNode, geometry: box, type: .dynamic)
           
        } else {
            var touch = touches.first as! UITouch
            var point = touch.location(in: self.view)
            
            if point.x < view.frame.width / 2 {
                boxNode.physicsBody?.applyForce(SCNVector3(-0.1, 10, 0), asImpulse: true)
            } else {
                boxNode.physicsBody?.applyForce(SCNVector3(0.1, 1, 0), asImpulse: true)
            }
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
