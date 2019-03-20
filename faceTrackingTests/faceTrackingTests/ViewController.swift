//
//  ViewController.swift
//  faceTrackingTests
//
//  Created by Manuella Valença on 20/03/19.
//  Copyright © 2019 Manuella Valença. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import ARKit

class ViewController: UIViewController {
    
    let wooshCometImage = UIImage()
    
    @IBOutlet weak var arSceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        
        arSceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        arSceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arSceneView.session.pause()
    }
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        
        let woosh = node.childNode(withName: "woosh", recursively: false) as? SCNNode
        
        // Vertice with index 9 -> nose
        //let vertices = [anchor.geometry.vertices[9])]
        let vertices = SCNVector3(anchor.geometry.vertices[9])
        
        //woosh?.updatePosition(for: vertices)
        woosh?.position = vertices
    }

}

extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let device = arSceneView.device else {
                return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        
        let node = SCNNode(geometry: faceGeometry)
        
        
        node.geometry?.firstMaterial?.fillMode = .lines
        
        node.geometry?.firstMaterial?.transparency = 0.0
        
        
        let wooshPlane = SCNPlane(width: 0.035, height: 0.035)
        
        wooshPlane.firstMaterial?.diffuse.contents = self.wooshCometImage
        
        let wooshNode = SCNNode(geometry: wooshPlane)
        
        wooshNode.name = "wooshComet"
        
        node.addChildNode(wooshNode)
        
        updateFeatures(for: node, using: faceAnchor)
        
        return node
    }
    
    func renderer(
        _ renderer: SCNSceneRenderer,
        didUpdate node: SCNNode,
        for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
        
        updateFeatures(for: node, using: faceAnchor)
    }
    
}
