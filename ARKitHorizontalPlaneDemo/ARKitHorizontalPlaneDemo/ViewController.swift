//
//  ViewController.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Jayven Nhan on 11/14/17.
//  Copyright © 2017 Jayven Nhan. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, SCNPhysicsContactDelegate {

    
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment to configure lighting
         configureLighting()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, SCNDebugOptions.showPhysicsShapes, SCNDebugOptions.showBoundingBoxes]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
}

extension ViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            print("era cilada")
            return }
        print("achou plano")
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.y)
        let plane = SCNPlane(width: width, height: height)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.geometry?.materials.first?.diffuse.contents = UIColor.clear
        
        dividePlane(width: width, height: height, planeNode: planeNode)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    func dividePlane(width: CGFloat, height:CGFloat, planeNode: SCNNode){
        for child in sceneView.scene.rootNode.childNodes{
            for kid in child.childNodes{
                for baby in kid.childNodes{
                    if baby.name == "tileNode"{
                        baby.removeFromParentNode()
                    }
                }
            }
        }
        
        if width == 0 || height == 0{
            return
        }
        
        let tileSize:CGFloat = 0.3
        let numberOfRows:CGFloat = width/tileSize
        let numberOfColumns:CGFloat = height/tileSize
        
        let plane = SCNPlane(width: tileSize, height: tileSize)
        plane.materials.first?.diffuse.contents = UIColor.darkGray
        
        let startingX:CGFloat = (CGFloat(planeNode.position.x) - (width/2 - (tileSize/2)))
        let startingY:CGFloat = (CGFloat(planeNode.position.y) - (height/2 - (tileSize/2)))
        
        for i in 0...Int(numberOfColumns-1){
            for j in 0...Int(numberOfRows-1){
                let tileNode = SCNNode(geometry: plane)
                tileNode.name = "tileNode"
                tileNode.position.y = Float(startingY + CGFloat(j)*tileSize)
                tileNode.position.x = Float(startingX + CGFloat(i)*tileSize)
                tileNode.position.y += 0.1
                
                planeNode.addChildNode(tileNode)
            }
        }
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
        
        let planeNode = node.childNodes.first, let plane = planeNode.geometry as? SCNPlane else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        
        dividePlane(width: width, height: height, planeNode: planeNode)
    }
    
}
