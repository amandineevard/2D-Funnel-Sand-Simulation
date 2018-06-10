//
//  RightView.swift
//  bachelorProjectGraphics
//
//  Created by Amandine Evard on 02.03.18.
//  Copyright © 2018 Amandine Evard. All rights reserved.
//

import Cocoa


class SimulationView: NSView {
    var simulation: Simulation?
    var positions: [[Double]]?
    var showGridCheck: Bool = true
    //minY of the system
    private(set) static var generalMinY : Double?
    private(set) static var  generalMaxY : Double?
    private(set) static var generalMinX : Double?
    private(set) static var  generalMaxX : Double?

    //Main function to draw
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let bPath:NSBezierPath = NSBezierPath(rect: dirtyRect)
        let fillColor = NSColor(red: 163/255, green: 220/255, blue: 236/255, alpha: 1.0)
        fillColor.set()
        bPath.fill()
        if let simulation = simulation{
            if showGridCheck{
                drawGrid(bounds.size, simulation)
            }
            if let positions = positions{
                showResults(bounds.size, simulation, positions)
                drawWallWithSize(bounds.size,simulation)
            } else{
                drawSpheresWithSize(bounds.size,simulation)
                drawWallWithSize(bounds.size,simulation)
            }
        }
    }
    
    
    //draw spheres
    func drawSpheresWithSize(_ size : NSSize, _ simulation : Simulation){
        guard let (scale, minX, minY, frame) = scaleForInterface(size,simulation) else {return}
        simulation.listOfSpheres.forEach{ sphere in
            let circleFillColor = NSColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
            let origin = CGPoint(x: (frame.minX + CGFloat(sphere.x - simulation.radiusSphere - minX) * scale ), y: (frame.minY + CGFloat(sphere.y - simulation.radiusSphere - minY) * scale))
            let size = CGSize(width: CGFloat(2*simulation.radiusSphere) * scale, height: CGFloat(2*simulation.radiusSphere) * scale)
            let rect = CGRect(origin: origin, size: size)
            circleFillColor.set()
            NSBezierPath(ovalIn: rect).fill()
        }
    }
    
    //draw walls
    func drawWallWithSize(_ size : NSSize, _ simulation : Simulation) {
        guard let (scale, minX, minY, frame) = scaleForInterface(size,simulation) else {return}
        simulation.listOfWalls.forEach{ wall in
            let blackColor = NSColor(red: 33/255, green: 42/255, blue: 71/255, alpha: 1.0)
            blackColor.set()
            let pointA = NSPoint(x: frame.minX + CGFloat(wall.Xa - minX) * scale, y: frame.minY + CGFloat(wall.Ya - minY) * scale)
            let pointB = NSPoint(x: frame.minX + CGFloat(wall.Xb - minX) * scale, y: frame.minY + CGFloat(wall.Yb - minY) * scale)
                
            let bPath: NSBezierPath = NSBezierPath()
            bPath.move(to: pointA)
            bPath.line(to: pointB)
            bPath.lineWidth = 1
            bPath.stroke()
        }
    }
    
    // responsive sceen
    func scaleForInterface(_ size: CGSize, _ simulation : Simulation) -> (scale : CGFloat, minX: Double, minY: Double, frame:CGRect )? {
        guard let minAxisX = (simulation.listOfWalls.map{wall in return min(wall.Xa, wall.Xb)}).min() else {return nil}
        guard let maxAxisX = (simulation.listOfWalls.map{wall in return max(wall.Xa, wall.Xb)}).max() else {return nil }
        guard let minAxisY = (simulation.listOfWalls.map{wall in return min(wall.Ya, wall.Yb)}).min() else {return nil}
        guard let maxAxisY = (simulation.listOfWalls.map{wall in return max(wall.Ya, wall.Yb)}).max() else {return nil }
        SimulationView.generalMinY = minAxisY
        SimulationView.generalMinX = minAxisX
        SimulationView.generalMaxY = maxAxisY
        SimulationView.generalMaxX = maxAxisX
        let edgeLenght = min(size.width, size.height)
        let padding = edgeLenght/10
        let frame = CGRect(x:0+padding, y:0+padding, width: size.width-2*padding, height: size.height-2*padding)
        let scaleX = frame.width/CGFloat(maxAxisX - minAxisX)
        let scaleY = frame.height/CGFloat(maxAxisY - minAxisY)
        if(scaleX < scaleY ){
            return (scaleX, minAxisX, minAxisY,frame)
        } else {
            return (scaleY, minAxisX, minAxisY,frame)
        }
    }
   
    //show results
    func showResults(_ size: CGSize, _ simulation : Simulation, _ positions : [[Double]]){
        guard let (scale, minX, minY, frame) = self.scaleForInterface(size,simulation) else {return}
        positions.forEach{ position in
            //draw spheres
            let circleFillColor = NSColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
            let origin = CGPoint(x: (frame.minX + CGFloat(position[0] - simulation.radiusSphere - minX) * scale ), y: (frame.minY + CGFloat(position[1] - simulation.radiusSphere - minY) * scale))
            let size = CGSize(width: CGFloat(2*simulation.radiusSphere) * scale, height: CGFloat(2*simulation.radiusSphere) * scale)
            let rect = CGRect(origin: origin, size: size)
            circleFillColor.set()
            NSBezierPath(ovalIn: rect).fill()
        }
    }
    
    //drawgrid
    func drawGrid(_ size : NSSize, _ simulation : Simulation){
        guard let (scale, minX, minY, frame) = scaleForInterface(size,simulation) else {return}
        let color = NSColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
        color.set()
        //draw columns
        for i in 0...simulation.grid.nbColumn{
            let pointA = NSPoint(x: frame.minX + CGFloat(simulation.grid.sizeCell*Double(i) - minX) * scale, y: frame.minY + CGFloat(0 - minY) * scale)
            let pointB = NSPoint(x: frame.minX + CGFloat(simulation.grid.sizeCell*Double(i) - minX) * scale, y: frame.minY + CGFloat(simulation.grid.height - minY) * scale)
            let bPath: NSBezierPath = NSBezierPath()
            bPath.move(to: pointA)
            bPath.line(to: pointB)
            bPath.lineWidth = 1
            bPath.stroke()
        }
        //draw rows
        for i in 0...simulation.grid.nbRow{
            let pointA = NSPoint(x: frame.minX + CGFloat(0 - minX) * scale, y: frame.minY + CGFloat(simulation.grid.sizeCell*Double(i) - minY) * scale)
            let pointB = NSPoint(x: frame.minX + CGFloat(simulation.grid.length - minX) * scale, y: frame.minY + CGFloat(simulation.grid.sizeCell*Double(i) - minY) * scale)
            let bPath: NSBezierPath = NSBezierPath()
            bPath.move(to: pointA)
            bPath.line(to: pointB)
            bPath.lineWidth = 1
            bPath.stroke()
        }
    }
}
