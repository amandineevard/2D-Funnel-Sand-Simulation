//
//  Spere.swift
//  bachelorProjectGraphics
//
//  Created by Amandine Evard on 03.03.18.
//  Copyright © 2018 Amandine Evard. All rights reserved.
//

import Foundation

struct EnergyAndForces {
    var Ep: Double
    var forcex: Double
    var forcey: Double
}

class Sphere: Equatable, Hashable {
    var hashValue: Int {
        return self.id.hashValue
    }
    var x: Double
    var y: Double
    var Vx: Double
    var Vy: Double
    var EnergyAndForce: EnergyAndForces
    let id: Int
    private static var IdGenerator: Int = 0
    
    init(x:Double,y:Double, Vx: Double, Vy: Double){
        self.x = x
        self.y = y
        self.Vx = Vx
        self.Vy = Vy
        self.EnergyAndForce = EnergyAndForces(Ep: 0, forcex: 0, forcey: 0)
        self.id = Sphere.IdGenerator
        Sphere.IdGenerator += 1
    }
    
    //Equatable
    static func ==(one:Sphere, second:Sphere) -> Bool{
        return one.x == second.x && one.y == second.y && one.Vx == second.Vx && one.Vy == second.Vy
    }
    
    //describing
    func describing()-> String{
        return " ball position : x = \(self.x)  y = \(self.y)  forces: Fx = \(self.EnergyAndForce.forcex) Fy = \(self.EnergyAndForce.forcey) and potential Energy = \(self.EnergyAndForce.Ep) and velocity : Vx = \(self.Vx) Vy : \(self.Vy)"
    }
}



