import Foundation
import SceneKit
import SwiftUI

// MARK: - Kawaii Creature Node (WITHOUT UIKit dependency)
class CreatureNode: SCNNode {
    // MARK: - Private Properties
    private var bodyNode: SCNNode!
    private var leftEyeNode: SCNNode!
    private var rightEyeNode: SCNNode!
    private var leftPupilNode: SCNNode!
    private var rightPupilNode: SCNNode!
    
    private var isBlinking = false
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupCreature()
        startAnimations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper: Convert SwiftUI Color to CGColor
    private func cgColor(from color: Color) -> CGColor {
        #if canImport(UIKit)
        return UIColor(color).cgColor
        #else
        return NSColor(color).cgColor
        #endif
    }
    
    // MARK: - Setup Creature Geometry
    private func setupCreature() {
        // BODY: Squishy slime (flattened sphere)
        let bodyGeometry = SCNSphere(radius: 1.5)
        bodyGeometry.segmentCount = 64
        
        let bodyMaterial = SCNMaterial()
        bodyMaterial.diffuse.contents = cgColor(from: .ventralTeal)
        bodyMaterial.lightingModel = .physicallyBased
        bodyMaterial.transparency = 0.9
        bodyMaterial.specular.contents = cgColor(from: .white)
        bodyMaterial.roughness.contents = 0.1
        bodyMaterial.metalness.contents = 0.0
        bodyMaterial.fresnelExponent = 1.5
        bodyMaterial.reflective.contents = cgColor(from: .white)
        bodyMaterial.reflective.intensity = 0.3
        
        bodyGeometry.materials = [bodyMaterial]
        
        bodyNode = SCNNode(geometry: bodyGeometry)
        bodyNode.scale = SCNVector3(1.2, 0.7, 1.0)
        addChildNode(bodyNode)
        
        // LEFT EYE
        let eyeWhiteGeometry = SCNSphere(radius: 0.35)
        let eyeWhiteMaterial = SCNMaterial()
        eyeWhiteMaterial.diffuse.contents = cgColor(from: .white)
        eyeWhiteMaterial.lightingModel = .physicallyBased
        eyeWhiteMaterial.metalness.contents = 0.9
        eyeWhiteMaterial.roughness.contents = 0.05
        eyeWhiteGeometry.materials = [eyeWhiteMaterial]
        
        leftEyeNode = SCNNode(geometry: eyeWhiteGeometry)
        leftEyeNode.position = SCNVector3(-0.5, 0.3, 1.2)
        bodyNode.addChildNode(leftEyeNode)
        
        // Left Pupil
        let pupilGeometry = SCNSphere(radius: 0.15)
        let pupilMaterial = SCNMaterial()
        pupilMaterial.diffuse.contents = cgColor(from: .black)
        pupilGeometry.materials = [pupilMaterial]
        leftPupilNode = SCNNode(geometry: pupilGeometry)
        leftPupilNode.position = SCNVector3(0, 0, 0.15)
        leftEyeNode.addChildNode(leftPupilNode)
        
        // Eye Shine
        let shineGeometry = SCNSphere(radius: 0.08)
        let shineMaterial = SCNMaterial()
        shineMaterial.diffuse.contents = cgColor(from: .white)
        shineMaterial.emission.contents = cgColor(from: .white)
        shineGeometry.materials = [shineMaterial]
        let shineNode = SCNNode(geometry: shineGeometry)
        shineNode.position = SCNVector3(0.08, 0.08, 0.2)
        leftEyeNode.addChildNode(shineNode)
        
        // RIGHT EYE
        rightEyeNode = SCNNode(geometry: eyeWhiteGeometry)
        rightEyeNode.position = SCNVector3(0.5, 0.3, 1.2)
        bodyNode.addChildNode(rightEyeNode)
        
        rightPupilNode = SCNNode(geometry: pupilGeometry)
        rightPupilNode.position = SCNVector3(0, 0, 0.15)
        rightEyeNode.addChildNode(rightPupilNode)
        
        let shineRight = SCNNode(geometry: shineGeometry)
        shineRight.position = SCNVector3(-0.08, 0.08, 0.2)
        rightEyeNode.addChildNode(shineRight)
    }
    
    // MARK: - Start Animations
    private func startAnimations() {
        // BREATHING
        let breathe = SCNAction.repeatForever(
            SCNAction.sequence([
                SCNAction.scale(to: 1.1, duration: 2.0),
                SCNAction.scale(to: 0.95, duration: 2.0)
            ])
        )
        bodyNode.runAction(breathe, forKey: "breathe")
        
        // FLOATING
        let float = SCNAction.repeatForever(
            SCNAction.sequence([
                SCNAction.moveBy(x: 0, y: 0.3, z: 0, duration: 1.5),
                SCNAction.moveBy(x: 0, y: -0.3, z: 0, duration: 1.5)
            ])
        )
        runAction(float, forKey: "float")
        
        // JIGGLE
        let jiggle = SCNAction.repeatForever(
            SCNAction.sequence([
                SCNAction.rotateBy(x: 0, y: 0, z: CGFloat.pi / 30, duration: 0.4),
                SCNAction.rotateBy(x: 0, y: 0, z: -CGFloat.pi / 15, duration: 0.8),
                SCNAction.rotateBy(x: 0, y: 0, z: CGFloat.pi / 30, duration: 0.4)
            ])
        )
        runAction(jiggle, forKey: "jiggle")
        
        // BLINKING
        startBlinking()
    }
    
    // MARK: - Blinking Animation
    private func startBlinking() {
        let randomDelay = Double.random(in: 2.0...5.0)
        
        let closeEyes = SCNAction.customAction(duration: 0.1) { [weak self] node, elapsed in
            guard let self = self else { return }
            let progress = Float(elapsed / 0.1)
            let newScale = 1.0 - (0.9 * progress)
            self.leftEyeNode.scale.y = newScale
            self.rightEyeNode.scale.y = newScale
        }
        
        let keepClosed = SCNAction.wait(duration: 0.15)
        
        let openEyes = SCNAction.customAction(duration: 0.1) { [weak self] node, elapsed in
            guard let self = self else { return }
            let progress = Float(elapsed / 0.1)
            let newScale = 0.1 + (0.9 * progress)
            self.leftEyeNode.scale.y = newScale
            self.rightEyeNode.scale.y = newScale
        }
        
        let blinkSequence = SCNAction.sequence([closeEyes, keepClosed, openEyes])
        
        let fullCycle = SCNAction.sequence([
            SCNAction.wait(duration: randomDelay),
            blinkSequence,
            SCNAction.run { [weak self] _ in
                self?.startBlinking()
            }
        ])
        
        bodyNode.runAction(fullCycle, forKey: "blinkingCycle")
    }
    
    // MARK: - Color Update
    func updateColor(_ color: Color) {
        guard let material = bodyNode.geometry?.materials.first else { return }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        material.diffuse.contents = cgColor(from: color)
        SCNTransaction.commit()
    }
    
    // MARK: - Celebration Jump
    func celebrate() {
        let jump = SCNAction.sequence([
            SCNAction.moveBy(x: 0, y: 1.5, z: 0, duration: 0.4),
            SCNAction.moveBy(x: 0, y: -1.5, z: 0, duration: 0.4)
        ])
        runAction(SCNAction.repeat(jump, count: 3))
    }
}
